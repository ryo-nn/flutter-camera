import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions/v2';
import { DEVICE_ID_PEPPER, X_CLIENT_SECRET } from '../../config/secrets';
import { db } from '../../lib/admin';
import { resolvePlan, type BillingStateLike } from '../../lib/plan';
import { reasonError, errorCodeForReason } from '../../lib/errors';
import { ensurePostDoc } from './postDoc';
import { validatePattern } from './patternValidation';
import { publishToInstagram } from './instagram';
import { publishToX } from './x';
import { finalizeOverallStatus } from './overallStatus';
import type { PersistedTargetStatus, PublishPostInput, PublishPostResult } from '../types';
import type { TargetOutcome } from './outcome';

/**
 * backend章「一括投稿の実行設計(snsPublishPost)」+ quota章・retention章の追補を
 * 統合したエントリポイント。InstagramとXは Promise.allSettled で独立に実行する。
 *
 * timeoutSeconds: 540 は IGコンテナのステータスポーリング(最大5分)+ 余裕を担保する
 * (backend章の既定。クライアント側もHttpsCallableOptions(timeout: 600秒)を明示する
 * 必要があるとdesign.mdは規定しているため、architecture担当への確認事項とする)。
 * memory: '1GiB' は動画対応追補(Xチャンクアップロードの5MBチャンクバッファ+
 * IG/X両ターゲットの並行実行時のメモリ余裕を確保するため、既存512MiBから引き上げ)。
 */
export const snsPublishPost = onCall<PublishPostInput>(
  {
    secrets: [X_CLIENT_SECRET, DEVICE_ID_PEPPER],
    enforceAppCheck: true,
    timeoutSeconds: 540,
    memory: '1GiB',
  },
  async (request): Promise<PublishPostResult> => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign-in required');
    }
    const uid = request.auth.uid;
    const input = request.data;

    validateInput(input, uid);

    const pattern = await validatePattern(uid, input.patternId);
    if (pattern.isPremium) {
      const billingSnap = await db.doc(`users/${uid}/billing/state`).get();
      const plan = resolvePlan(billingSnap.exists ? (billingSnap.data() as BillingStateLike) : undefined);
      if (plan !== 'pro') {
        throw reasonError(
          'failed-precondition',
          'このパターンはProプラン限定です',
          'PATTERN_PREMIUM_REQUIRED',
        );
      }
    }

    await ensurePostDoc({ uid, input, patternName: pattern.name });

    const ctx = {
      uid,
      postId: input.postId,
      imagePath: input.imagePath,
      caption: input.caption ?? '',
      force: input.force === true,
      deviceId: input.deviceId,
      platform: input.platform,
      phoneNumberClaim: request.auth.token.phone_number as string | undefined,
      // 動画対応追補: 未指定は既存互換のため'image'として扱う
      mediaType: input.mediaType ?? 'image',
      durationSec: input.durationSec,
      fileSizeBytes: input.fileSizeBytes,
    };

    const [igSettled, xSettled] = await Promise.allSettled([
      input.targets.instagram ? publishToInstagram(ctx) : Promise.resolve(null),
      input.targets.x ? publishToX(ctx) : Promise.resolve(null),
    ]);

    const results: PublishPostResult['results'] = {};
    if (igSettled.status === 'fulfilled' && igSettled.value) {
      results.instagram = toResultSummary(igSettled.value);
    } else if (igSettled.status === 'rejected') {
      logger.error('Instagramターゲット処理で捕捉されない例外', { error: String(igSettled.reason) });
    }
    if (xSettled.status === 'fulfilled' && xSettled.value) {
      results.x = toResultSummary(xSettled.value);
    } else if (xSettled.status === 'rejected') {
      logger.error('Xターゲット処理で捕捉されない例外', { error: String(xSettled.reason) });
    }

    const overallStatus = await finalizeOverallStatus(input.postId);

    return { postId: input.postId, overallStatus, results };
  },
);

function validateInput(input: PublishPostInput, uid: string): void {
  if (!input || typeof input.postId !== 'string' || input.postId.length === 0) {
    throw new HttpsError('invalid-argument', 'postId は必須です');
  }
  if (typeof input.imagePath !== 'string' || !input.imagePath.startsWith(`users/${uid}/postImages/`)) {
    throw new HttpsError('invalid-argument', 'imagePath は本人のpostImages配下である必要があります');
  }
  if (!input.targets || (!input.targets.instagram && !input.targets.x)) {
    throw new HttpsError('invalid-argument', '投稿先を1つ以上選択してください');
  }
  if (typeof input.caption !== 'string' && input.caption !== undefined) {
    throw new HttpsError('invalid-argument', 'caption は文字列である必要があります');
  }
  // 動画対応追補: 型・形の検証のみここで行う(ターゲット別の範囲検証はクォータ消費前に
  // instagram.ts / x.ts が mediaValidation.validateVideoClaim で行う)
  if (input.mediaType !== undefined && input.mediaType !== 'image' && input.mediaType !== 'video') {
    throw new HttpsError('invalid-argument', "mediaType は 'image' または 'video' である必要があります");
  }
  if (input.durationSec !== undefined && (typeof input.durationSec !== 'number' || !Number.isFinite(input.durationSec))) {
    throw new HttpsError('invalid-argument', 'durationSec は数値である必要があります');
  }
  if (
    input.fileSizeBytes !== undefined &&
    (typeof input.fileSizeBytes !== 'number' || !Number.isFinite(input.fileSizeBytes))
  ) {
    throw new HttpsError('invalid-argument', 'fileSizeBytes は数値である必要があります');
  }
}

function toResultSummary(
  outcome: TargetOutcome,
): { status: PersistedTargetStatus; publishedId?: string; errorCode?: string } {
  if (outcome.kind === 'succeeded') {
    return { status: 'succeeded', publishedId: outcome.publishedId };
  }
  if (outcome.kind === 'alreadyRunning') {
    return { status: 'processing' };
  }
  return { status: 'failed', errorCode: errorCodeForReason(outcome.reason) ?? undefined };
}
