import { FieldValue } from 'firebase-admin/firestore';
import { db } from '../../lib/admin';
import type { PublishPostResult } from '../types';

/**
 * data章「overallStatusは selected == true のターゲットのみで判定(skippedは集計対象外)」
 * 準拠。全成功=succeeded / 全失敗=failed / 混在=partial / 実行中=processing。
 */
export async function finalizeOverallStatus(postId: string): Promise<PublishPostResult['overallStatus']> {
  const ref = db.doc(`posts/${postId}`);
  const snap = await ref.get();
  const data = snap.data();
  if (!data) return 'processing';

  const providers = ['instagram', 'x'] as const;
  const selectedStatuses = providers
    .filter((p) => data.targets?.[p]?.selected === true)
    .map((p) => data.targets[p]?.status as string);

  let overallStatus: PublishPostResult['overallStatus'];
  if (selectedStatuses.length === 0) {
    overallStatus = 'succeeded';
  } else if (selectedStatuses.some((s) => s === 'pending' || s === 'processing')) {
    overallStatus = 'processing';
  } else if (selectedStatuses.every((s) => s === 'succeeded')) {
    overallStatus = 'succeeded';
  } else if (selectedStatuses.every((s) => s === 'failed')) {
    overallStatus = 'failed';
  } else {
    overallStatus = 'partial';
  }

  await ref.update({ overallStatus, updatedAt: FieldValue.serverTimestamp() });
  return overallStatus;
}
