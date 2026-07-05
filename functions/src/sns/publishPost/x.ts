import { logger } from 'firebase-functions/v2';
import * as xClient from '../xClient';
import { detectCaptionUrls } from '../urlDetection';
import { ensureFreshXAccessToken } from '../xTokenRefresh';
import { handleTokenExpired, isXTokenInvalidError } from '../tokenLifecycle';
import { retryOnce } from '../../lib/retry';
import { hashDeviceId } from '../../lib/deviceHash';
import { reserveXQuota, refundXQuota } from './quotaX';
import { downloadPostImage, getPostImageMetadata } from './postImage';
import {
  validateStorageObjectMatchesClaim,
  validateVideoClaim,
  X_VIDEO_CONTENT_TYPES,
  X_VIDEO_LIMITS,
} from './mediaValidation';
import { uploadVideoChunked, XMediaProcessingFailedError, XMediaProcessingTimeoutError } from './xVideoUpload';
import { failedOutcome, outcomeFromUnknownError, succeededOutcome, type TargetOutcome } from './outcome';
import { finalizeTarget } from './finalize';
import type { PublishContext } from './context';
import type { QuotaSource } from '../types';

/**
 * quota章「X投稿枠の消費順序とトランザクション設計」+ backend章「投稿フロー」節 準拠。
 * (0)URL検証 →(0.5)動画メディアバリデーション(いずれも消費前)→ 予約トランザクション
 * (グラント/SMS/デバイス/日次/月次/クレジット)→ メディアアップロード → ポスト作成 の順に
 * 実行する。`POST /2/tweets` 呼び出しが「送信」の境界であり、それ以降の失敗は返還しない。
 */
export async function publishToX(ctx: PublishContext): Promise<TargetOutcome> {
  const { uid, postId, caption, imagePath, force, deviceId, platform, phoneNumberClaim, mediaType, durationSec, fileSizeBytes } =
    ctx;

  // (0) URLバリデーション(消費前・初回投稿グラント経路にも適用)
  const urls = detectCaptionUrls(caption);
  if (urls.length > 0) {
    const outcome = failedOutcome('X_URL_NOT_ALLOWED', 'retryable', 'キャプションにURLを含めることはできません');
    await finalizeTarget(postId, 'x', outcome);
    return outcome;
  }

  // (0.5) 動画メディアのサーバー側バリデーション(消費前。申告値の範囲チェック+Storage実体との突合)
  let validatedVideoSizeBytes: number | undefined;
  let validatedVideoContentType: string | undefined;
  if (mediaType === 'video') {
    const claimError = validateVideoClaim({ durationSec, fileSizeBytes }, X_VIDEO_LIMITS);
    if (claimError) {
      const outcome = failedOutcome('MEDIA_VALIDATION_FAILED', 'retryable', claimError);
      await finalizeTarget(postId, 'x', outcome);
      return outcome;
    }
    try {
      const metadata = await getPostImageMetadata(imagePath);
      const metaError = validateStorageObjectMatchesClaim('video', fileSizeBytes, metadata, X_VIDEO_CONTENT_TYPES);
      if (metaError) {
        const outcome = failedOutcome('MEDIA_VALIDATION_FAILED', 'retryable', metaError);
        await finalizeTarget(postId, 'x', outcome);
        return outcome;
      }
      validatedVideoSizeBytes = metadata.size;
      validatedVideoContentType = metadata.contentType;
    } catch (err) {
      logger.error('X動画メディアのStorageメタデータ取得に失敗', { uid, postId, error: String(err) });
      const outcome = failedOutcome('MEDIA_VALIDATION_FAILED', 'retryable', '投稿メディアの検証に失敗しました');
      await finalizeTarget(postId, 'x', outcome);
      return outcome;
    }
  }

  let quotaSource: QuotaSource;
  try {
    quotaSource = await reserveXQuota({
      uid,
      postId,
      deviceId: deviceId ? hashDeviceId(deviceId) : undefined,
      platform,
      phoneNumberClaim,
      force,
    });
  } catch (err) {
    const outcome = outcomeFromUnknownError(err, 'X_QUOTA_EXCEEDED', 'X投稿枠の判定に失敗しました');
    await finalizeTarget(postId, 'x', outcome);
    return outcome;
  }

  const compensate = () => refundXQuota(uid, postId, quotaSource);

  try {
    const accessToken = await ensureFreshXAccessToken(uid);
    if (!accessToken) {
      await handleTokenExpired(uid, 'x');
      await compensate();
      const outcome = failedOutcome('TOKEN_EXPIRED', 'permanent', 'X連携が失効しています');
      await finalizeTarget(postId, 'x', outcome);
      return outcome;
    }

    let mediaId: string;
    try {
      if (mediaType === 'video') {
        mediaId = await uploadVideoChunked(
          accessToken,
          imagePath,
          validatedVideoSizeBytes ?? (fileSizeBytes as number),
          // Storage実contentTypeを参照する(バリデーションでX_VIDEO_CONTENT_TYPESに
          // 一致することを確認済みのため実質video/mp4のみ到達するが、ハードコードを避ける)。
          validatedVideoContentType ?? 'video/mp4',
        );
      } else {
        const imageBuffer = await downloadPostImage(imagePath);
        const uploadResult = await retryOnce(
          () => xClient.uploadMedia(accessToken, imageBuffer),
          'xClient.uploadMedia',
        );
        mediaId = uploadResult.data.id;
      }
    } catch (err) {
      if (isXTokenInvalidError(err)) {
        await handleTokenExpired(uid, 'x');
        await compensate();
        const outcome = failedOutcome('TOKEN_EXPIRED', 'permanent', 'X連携が失効しています');
        await finalizeTarget(postId, 'x', outcome);
        return outcome;
      }
      await compensate();
      const message =
        err instanceof XMediaProcessingTimeoutError
          ? '動画の処理がタイムアウトしました'
          : err instanceof XMediaProcessingFailedError
            ? '動画の処理に失敗しました'
            : 'メディアのアップロードに失敗しました';
      const outcome = failedOutcome('X_MEDIA_UPLOAD_FAILED', 'retryable', message);
      await finalizeTarget(postId, 'x', outcome);
      return outcome;
    }

    // ここから「送信」(POST /2/tweets 呼び出し以降は失敗しても返還しない)
    try {
      const tweet = await xClient.createTweet(accessToken, caption, mediaId);
      const outcome = succeededOutcome(tweet.data.id);
      await finalizeTarget(postId, 'x', outcome);
      return outcome;
    } catch (err) {
      if (isXTokenInvalidError(err)) {
        await handleTokenExpired(uid, 'x');
      }
      const outcome = outcomeForPostSendError(err);
      await finalizeTarget(postId, 'x', outcome);
      return outcome;
    }
  } catch (err) {
    logger.error('Xターゲット処理で想定外の例外', { uid, postId, error: String(err) });
    await compensate();
    const outcome = failedOutcome('X_MEDIA_UPLOAD_FAILED', 'retryable', '予期しないエラーが発生しました');
    await finalizeTarget(postId, 'x', outcome);
    return outcome;
  }
}

function outcomeForPostSendError(err: unknown): TargetOutcome {
  const isConfirmed = err instanceof Error && typeof (err as { status?: number }).status === 'number';
  if (isConfirmed) {
    return failedOutcome('X_POST_FAILED', 'retryable', '投稿の送信でエラー応答を受け取りました');
  }
  return failedOutcome('UNKNOWN_RESULT', 'unknown', 'SNS側で投稿済みか確認の上、再試行してください');
}
