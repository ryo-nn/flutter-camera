import { FieldValue } from 'firebase-admin/firestore';
import { db } from '../../lib/admin';
import { errorCodeForReason } from '../../lib/errors';
import type { SnsProvider } from '../types';
import type { TargetOutcome } from './outcome';

/**
 * ターゲットごとの結果をposts/{postId}.targets.<provider>へ逐次書き込む。
 * 'alreadyRunning'(X_ALREADY_RUNNING/POST_ALREADY_PROCESSING)は
 * design.mdの規定どおりターゲット状態を変更しない(保存なし)。
 */
export async function finalizeTarget(postId: string, provider: SnsProvider, outcome: TargetOutcome): Promise<void> {
  if (outcome.kind === 'alreadyRunning') return;

  const ref = db.doc(`posts/${postId}`);
  if (outcome.kind === 'succeeded') {
    await ref.update({
      [`targets.${provider}.status`]: 'succeeded',
      [`targets.${provider}.publishedId`]: outcome.publishedId,
      [`targets.${provider}.postedAt`]: FieldValue.serverTimestamp(),
      [`targets.${provider}.errorCode`]: null,
      [`targets.${provider}.errorMessage`]: null,
      updatedAt: FieldValue.serverTimestamp(),
    });
    return;
  }

  const errorCode = errorCodeForReason(outcome.reason);
  await ref.update({
    [`targets.${provider}.status`]: 'failed',
    [`targets.${provider}.failureKind`]: outcome.failureKind,
    [`targets.${provider}.errorCode`]: errorCode,
    [`targets.${provider}.errorMessage`]: outcome.message,
    updatedAt: FieldValue.serverTimestamp(),
  });
}
