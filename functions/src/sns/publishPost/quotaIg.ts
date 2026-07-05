import { FieldValue } from 'firebase-admin/firestore';
import { HttpsError } from 'firebase-functions/v2/https';
import { db } from '../../lib/admin';
import { dailyPeriodKey } from '../../lib/period';
import { resolvePlan, type BillingStateLike } from '../../lib/plan';
import { reasonError } from '../../lib/errors';

/**
 * retention章「Instagramフェアユース上限(スロットル)」節 準拠の予約トランザクション。
 * Meta側 content_publishing_limit チェック(igClient側)の**前に**実行する。
 *
 * quota章のXターゲット向け quotaRefunded と同様の二重返還防止フラグとして
 * `targets.instagram.fairUseRefunded` を本実装で追加する(design.mdはXの
 * quotaRefundedのみ明記しIG側の等価フィールドを明記していないための追加。
 * data担当への追加依頼としてcoreChangeRequestsに記載)。
 */

export async function reserveIgFairUse(params: {
  uid: string;
  postId: string;
  force?: boolean;
  now?: Date;
}): Promise<void> {
  const { uid, postId, force } = params;
  const now = params.now ?? new Date();
  const dailyKey = dailyPeriodKey(now);

  const postDocRef = db.doc(`posts/${postId}`);
  const dailyRef = db.doc(`postUsage/${uid}_instagram_${dailyKey}`);
  const limitsRef = db.doc('appConfig/limits');
  const billingRef = db.doc(`users/${uid}/billing/state`);

  await db.runTransaction(async (tx) => {
    const [postSnap, dailySnap, limitsSnap, billingSnap] = await Promise.all([
      tx.get(postDocRef),
      tx.get(dailyRef),
      tx.get(limitsRef),
      tx.get(billingRef),
    ]);

    if (!postSnap.exists) {
      throw new HttpsError('not-found', 'post not found');
    }

    const status = postSnap.get('targets.instagram.status');
    const failureKind = postSnap.get('targets.instagram.failureKind');
    const runnable =
      status === 'pending' ||
      (status === 'failed' && failureKind === 'retryable') ||
      (status === 'failed' && failureKind === 'unknown' && force === true);
    if (!runnable) {
      throw reasonError('already-exists', 'Instagram target not runnable', 'POST_ALREADY_PROCESSING');
    }

    const plan = resolvePlan(billingSnap.exists ? (billingSnap.data() as BillingStateLike) : undefined, now);
    const dailyUsed = dailySnap.exists ? ((dailySnap.get('count') as number) ?? 0) : 0;
    const dailyLimit = limitsSnap.get(`igDailyFairUseLimitByPlan.${plan}`) as number | undefined;
    if (typeof dailyLimit === 'number' && dailyUsed >= dailyLimit) {
      throw reasonError('resource-exhausted', 'Instagram fair use limit reached', 'IG_FAIR_USE_EXCEEDED');
    }

    tx.set(
      dailyRef,
      {
        uid,
        provider: 'instagram',
        periodType: 'daily',
        period: dailyKey,
        count: dailyUsed + 1,
        lastPostedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    tx.update(postDocRef, {
      'targets.instagram.status': 'processing',
      updatedAt: FieldValue.serverTimestamp(),
    });
  });
}

export async function refundIgFairUse(uid: string, postId: string, now: Date = new Date()): Promise<void> {
  const dailyKey = dailyPeriodKey(now);
  const postDocRef = db.doc(`posts/${postId}`);
  const dailyRef = db.doc(`postUsage/${uid}_instagram_${dailyKey}`);

  await db.runTransaction(async (tx) => {
    const postSnap = await tx.get(postDocRef);
    if (postSnap.get('targets.instagram.fairUseRefunded') === true) return; // 冪等
    const dailySnap = await tx.get(dailyRef);
    const dailyUsed = dailySnap.exists ? ((dailySnap.get('count') as number) ?? 0) : 0;
    tx.update(dailyRef, { count: Math.max(0, dailyUsed - 1), updatedAt: FieldValue.serverTimestamp() });
    tx.update(postDocRef, {
      'targets.instagram.fairUseRefunded': true,
      updatedAt: FieldValue.serverTimestamp(),
    });
  });
}
