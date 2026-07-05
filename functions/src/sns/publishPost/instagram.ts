import { logger } from 'firebase-functions/v2';
import * as igClient from '../igClient';
import { getDecryptedToken } from '../tokenStore';
import { handleTokenExpired, isIgTokenInvalidError } from '../tokenLifecycle';
import { retryOnce } from '../../lib/retry';
import { reserveIgFairUse, refundIgFairUse } from './quotaIg';
import { copyToIgTemp, deleteIgTempFile, getIgTempSignedUrl } from './igTempImage';
import {
  IgContainerStatusError,
  IgContainerTimeoutError,
  pollContainerStatus,
  pollVideoContainerStatus,
} from './igContainerPoll';
import { getPostImageMetadata } from './postImage';
import {
  IG_VIDEO_CONTENT_TYPES,
  IG_VIDEO_LIMITS,
  validateStorageObjectMatchesClaim,
  validateVideoClaim,
} from './mediaValidation';
import { failedOutcome, outcomeFromUnknownError, succeededOutcome, type TargetOutcome } from './outcome';
import { finalizeTarget } from './finalize';
import type { PublishContext } from './context';

/**
 * backend章「Instagram連携設計」「投稿フロー」+ retention章「Instagramフェアユース上限」
 * 節 準拠。動画メディアバリデーション(クォータ消費前)→フェアユース予約(送信前失敗は返還)→
 * Meta 24h/100件チェック → 一時公開メディアの生成 → コンテナ作成 → ステータスポーリング →
 * media_publish の順に実行する。`media_publish` 呼び出しが「送信」の境界であり、
 * それ以降の失敗は返還しない。
 */
export async function publishToInstagram(ctx: PublishContext): Promise<TargetOutcome> {
  const { uid, postId, imagePath, caption, force, mediaType, durationSec, fileSizeBytes } = ctx;

  // 動画メディアのサーバー側バリデーション(フェアユース予約=クォータ消費前)
  if (mediaType === 'video') {
    const claimError = validateVideoClaim({ durationSec, fileSizeBytes }, IG_VIDEO_LIMITS);
    if (claimError) {
      const outcome = failedOutcome('MEDIA_VALIDATION_FAILED', 'retryable', claimError);
      await finalizeTarget(postId, 'instagram', outcome);
      return outcome;
    }
    try {
      const metadata = await getPostImageMetadata(imagePath);
      const metaError = validateStorageObjectMatchesClaim('video', fileSizeBytes, metadata, IG_VIDEO_CONTENT_TYPES);
      if (metaError) {
        const outcome = failedOutcome('MEDIA_VALIDATION_FAILED', 'retryable', metaError);
        await finalizeTarget(postId, 'instagram', outcome);
        return outcome;
      }
    } catch (err) {
      logger.error('Instagram動画メディアのStorageメタデータ取得に失敗', { uid, postId, error: String(err) });
      const outcome = failedOutcome('MEDIA_VALIDATION_FAILED', 'retryable', '投稿メディアの検証に失敗しました');
      await finalizeTarget(postId, 'instagram', outcome);
      return outcome;
    }
  }

  let outcome: TargetOutcome;
  try {
    await reserveIgFairUse({ uid, postId, force });
  } catch (err) {
    outcome = failedOutcomeFromCaught(err, 'IG_FAIR_USE_EXCEEDED', 'Instagramフェアユース上限の判定に失敗しました');
    await finalizeTarget(postId, 'instagram', outcome);
    return outcome;
  }

  const compensate = () => refundIgFairUse(uid, postId);
  let tempImageCreated = false;

  try {
    const tokenInfo = await getDecryptedToken(uid, 'instagram');
    if (!tokenInfo || !tokenInfo.doc.igUserId) {
      await compensate();
      outcome = failedOutcome('TOKEN_EXPIRED', 'permanent', 'Instagram連携が失効しています');
      await finalizeTarget(postId, 'instagram', outcome);
      return outcome;
    }
    const accessToken = tokenInfo.accessToken;
    const igUserId = tokenInfo.doc.igUserId as string;

    // Meta側 24h/100件制限の事前チェック(送信前)
    try {
      const limit = await igClient.getContentPublishingLimit(igUserId, accessToken);
      const usage = limit.data[0];
      if (usage && usage.quota_usage >= usage.config.quota_total) {
        await compensate();
        outcome = failedOutcome('IG_QUOTA_EXCEEDED', 'retryable', '24時間の投稿上限に達しました', {
          quotaDuration: usage.config.quota_duration,
        });
        await finalizeTarget(postId, 'instagram', outcome);
        return outcome;
      }
    } catch (err) {
      if (isIgTokenInvalidError(err)) {
        await handleTokenExpired(uid, 'instagram');
        await compensate();
        outcome = failedOutcome('TOKEN_EXPIRED', 'permanent', 'Instagramトークンが失効しています');
        await finalizeTarget(postId, 'instagram', outcome);
        return outcome;
      }
      await compensate();
      outcome = failedOutcome('IG_CONTAINER_ERROR', 'retryable', '投稿枠の確認に失敗しました');
      await finalizeTarget(postId, 'instagram', outcome);
      return outcome;
    }

    // 一時公開メディア(画像/動画)の生成(送信前)
    try {
      await copyToIgTemp(uid, postId, imagePath, mediaType);
      tempImageCreated = true;
    } catch (err) {
      await compensate();
      outcome = failedOutcome('IG_CONTAINER_ERROR', 'retryable', '投稿用メディアの準備に失敗しました');
      await finalizeTarget(postId, 'instagram', outcome);
      return outcome;
    }

    try {
      const signedUrl = await getIgTempSignedUrl(uid, postId, mediaType);

      // コンテナ作成・ステータス確認(送信前。5xx/ネットワークエラーは1回だけ即時再試行)
      let containerId: string;
      try {
        const container = await retryOnce(
          () =>
            mediaType === 'video'
              ? igClient.createVideoMediaContainer(igUserId, accessToken, signedUrl, caption)
              : igClient.createMediaContainer(igUserId, accessToken, signedUrl, caption),
          'igClient.createMediaContainer',
        );
        containerId = container.id;
        if (mediaType === 'video') {
          await pollVideoContainerStatus(containerId, accessToken);
        } else {
          await pollContainerStatus(containerId, accessToken);
        }
      } catch (err) {
        if (isIgTokenInvalidError(err)) {
          await handleTokenExpired(uid, 'instagram');
          await compensate();
          outcome = failedOutcome('TOKEN_EXPIRED', 'permanent', 'Instagramトークンが失効しています');
          await finalizeTarget(postId, 'instagram', outcome);
          return outcome;
        }
        if (err instanceof IgContainerTimeoutError) {
          await compensate();
          outcome = failedOutcome('IG_CONTAINER_TIMEOUT', 'retryable', 'コンテナの処理がタイムアウトしました');
          await finalizeTarget(postId, 'instagram', outcome);
          return outcome;
        }
        if (err instanceof IgContainerStatusError) {
          await compensate();
          outcome = failedOutcome('IG_CONTAINER_ERROR', 'retryable', 'コンテナの作成に失敗しました');
          await finalizeTarget(postId, 'instagram', outcome);
          return outcome;
        }
        await compensate();
        outcome = failedOutcome('IG_CONTAINER_ERROR', 'retryable', 'コンテナの作成に失敗しました');
        await finalizeTarget(postId, 'instagram', outcome);
        return outcome;
      }

      // ここから「送信」(media_publish呼び出し以降は失敗しても返還しない)
      try {
        const published = await igClient.publishMedia(igUserId, accessToken, containerId);
        outcome = succeededOutcome(published.id);
        await finalizeTarget(postId, 'instagram', outcome);
        return outcome;
      } catch (err) {
        if (isIgTokenInvalidError(err)) {
          await handleTokenExpired(uid, 'instagram');
        }
        outcome = outcomeForPostSendError(err, 'IG_PUBLISH_FAILED', '投稿の公開に失敗しました');
        await finalizeTarget(postId, 'instagram', outcome);
        return outcome;
      }
    } finally {
      if (tempImageCreated) {
        await deleteIgTempFile(uid, postId, mediaType);
      }
    }
  } catch (err) {
    logger.error('Instagramターゲット処理で想定外の例外', { uid, postId, error: String(err) });
    if (!tempImageCreated) {
      await compensate();
    }
    outcome = failedOutcome('IG_CONTAINER_ERROR', 'retryable', '予期しないエラーが発生しました');
    await finalizeTarget(postId, 'instagram', outcome);
    return outcome;
  }
}

function failedOutcomeFromCaught(err: unknown, fallbackReason: string, fallbackMessage: string): TargetOutcome {
  return outcomeFromUnknownError(err, fallbackReason, fallbackMessage);
}

/** 送信後(media_publish呼び出し後)のエラーを確定失敗(retryable)/結果不明(unknown)に分類する */
function outcomeForPostSendError(err: unknown, confirmedReason: string, message: string): TargetOutcome {
  const isConfirmed = err instanceof Error && typeof (err as { status?: number }).status === 'number';
  if (isConfirmed) {
    return failedOutcome(confirmedReason, 'retryable', message);
  }
  return failedOutcome('UNKNOWN_RESULT', 'unknown', 'SNS側で投稿済みか確認の上、再試行してください');
}
