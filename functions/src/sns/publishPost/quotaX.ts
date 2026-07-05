import { FieldValue } from 'firebase-admin/firestore';
import { HttpsError } from 'firebase-functions/v2/https';
import { db } from '../../lib/admin';
import { dailyPeriodKey, monthlyPeriodKey } from '../../lib/period';
import { resolvePlan, type BillingStateLike } from '../../lib/plan';
import { reasonError } from '../../lib/errors';
import type { QuotaSource } from '../types';

/**
 * quota章「X投稿枠の消費順序とトランザクション設計」+ retention章
 * 「初回同時投稿1回保証」の統合仕様(design.md 3902-3908行)に準拠する予約トランザクション。
 *
 * 消費順序: (0)URL検証は呼び出し側で事前実施 → (1)初回投稿グラント
 *   → (2)デバイス占有チェック → (3)日次乱用ガード → (4)月次枠→クレジット。
 *
 * 実装上の判断(design.md内の記述齟齬について): retention章本文(3902-3908行)は
 * 「デバイス占有(2)・日次ガード(3、カウンタ加算含む)はグラント経路でも適用する」と
 *明記し理由も述べる一方、追補による変更点一覧(4019行)の要約は「グラント経路は
 * デバイス占有・日次ガードも含め全て適用しない」と読める記述になっており、
 * design.md自身の中で矛盾している。本実装は根拠が明示されている本文側
 * (デバイス占有・日次ガードはグラント経路にも適用)を採用する。
 * この矛盾は統合フェーズでRYOに確認を要する(coreChangeRequests参照)。
 */

export interface ReserveXQuotaParams {
  uid: string;
  postId: string;
  deviceId?: string;
  platform?: 'ios' | 'android';
  phoneNumberClaim?: string;
  force?: boolean;
  now?: Date;
}

export async function reserveXQuota(params: ReserveXQuotaParams): Promise<QuotaSource> {
  const { uid, postId, deviceId, platform, phoneNumberClaim, force } = params;
  const now = params.now ?? new Date();
  const dailyKey = dailyPeriodKey(now);
  const monthlyKey = monthlyPeriodKey(now);

  const postDocRef = db.doc(`posts/${postId}`);
  const dailyRef = db.doc(`postUsage/${uid}_x_${dailyKey}`);
  const monthlyRef = db.doc(`postUsage/${uid}_x_${monthlyKey}`);
  const limitsRef = db.doc('appConfig/limits');
  const billingRef = db.doc(`users/${uid}/billing/state`);
  const grantRef = db.doc(`onboardingGrants/${uid}`);
  const deviceRef = deviceId ? db.doc(`devices/${deviceId}`) : null;

  return db.runTransaction<QuotaSource>(async (tx) => {
    const [limitsSnap, billingSnap, grantSnap, dailySnap, monthlySnap, postSnap, deviceSnap] = await Promise.all([
      tx.get(limitsRef),
      tx.get(billingRef),
      tx.get(grantRef),
      tx.get(dailyRef),
      tx.get(monthlyRef),
      tx.get(postDocRef),
      deviceRef ? tx.get(deviceRef) : Promise.resolve(null),
    ]);

    if (!postSnap.exists) {
      throw new HttpsError('not-found', 'post not found');
    }

    // (A) 実行可否CAS(既存の冪等性設計。全消費経路に共通で先行)
    const status = postSnap.get('targets.x.status');
    const failureKind = postSnap.get('targets.x.failureKind');
    const runnable =
      status === 'pending' ||
      (status === 'failed' && failureKind === 'retryable') ||
      (status === 'failed' && failureKind === 'unknown' && force === true);
    if (!runnable) {
      throw reasonError('already-exists', 'X target not runnable', 'X_ALREADY_RUNNING');
    }

    const isGrantPath = !grantSnap.exists;
    const plan = resolvePlan(billingSnap.exists ? (billingSnap.data() as BillingStateLike) : undefined, now);

    // (0) freeプランのSMS認証クレーム検証: グラント経路は適用外
    if (!isGrantPath && plan === 'free' && !phoneNumberClaim) {
      throw reasonError(
        'failed-precondition',
        'Phone verification required',
        'X_PHONE_VERIFICATION_REQUIRED',
      );
    }

    // (2) デバイス占有チェック: freeプランのみ。グラント経路でも適用する(本文3905行の統合仕様)
    if (plan === 'free') {
      if (!deviceRef) {
        throw new HttpsError('invalid-argument', 'deviceId is required for free plan X posting');
      }
      if (deviceSnap && deviceSnap.exists && deviceSnap.get('freeOwnerUid') !== uid) {
        throw reasonError(
          'permission-denied',
          'Free quota is bound to another account',
          'FREE_QUOTA_DEVICE_LIMIT',
        );
      }
    }

    // (3) 日次乱用ガード: 消費ソースを問わず適用(グラント経路でも適用)
    const dailyUsed = dailySnap.exists ? ((dailySnap.get('count') as number) ?? 0) : 0;
    const dailyLimit = limitsSnap.get(`xDailyPostLimitByPlan.${plan}`) as number | undefined;
    if (typeof dailyLimit === 'number' && dailyUsed >= dailyLimit) {
      throw reasonError('resource-exhausted', 'X daily limit reached', 'X_QUOTA_EXCEEDED', {
        quotaScope: 'daily',
      });
    }

    const claimDeviceIfNeeded = () => {
      if (plan === 'free' && deviceRef && (!deviceSnap || !deviceSnap.exists)) {
        tx.create(deviceRef, {
          platform: platform ?? 'ios',
          freeOwnerUid: uid,
          firstSeenAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        });
      }
    };
    const incrementDaily = () => {
      tx.set(
        dailyRef,
        {
          uid,
          provider: 'x',
          periodType: 'daily',
          period: dailyKey,
          count: dailyUsed + 1,
          lastPostedAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    };

    if (isGrantPath) {
      // (1) 初回投稿グラント消費: SMS認証・月次枠/クレジットの判定・消費はスキップする
      tx.create(grantRef, {
        uid,
        firstPostUsedAt: FieldValue.serverTimestamp(),
        firstPostId: postId,
        updatedAt: FieldValue.serverTimestamp(),
      });
      claimDeviceIfNeeded();
      incrementDaily();
      tx.update(postDocRef, {
        'targets.x.status': 'processing',
        'targets.x.quotaSource': 'grant',
        'targets.x.quotaRefunded': false,
        updatedAt: FieldValue.serverTimestamp(),
      });
      return 'grant';
    }

    // (4) 消費ソース決定: 月次リセット枠 → 無期限クレジット
    const monthlyUsed = monthlySnap.exists ? ((monthlySnap.get('count') as number) ?? 0) : 0;
    const monthlyLimit = limitsSnap.get(`xMonthlyPostLimitByPlan.${plan}`) as number | undefined;
    const creditBalance = billingSnap.exists ? ((billingSnap.get('postCredits') as number) ?? 0) : 0;

    let quotaSource: QuotaSource;
    if (typeof monthlyLimit === 'number' && monthlyUsed < monthlyLimit) {
      quotaSource = 'monthly';
    } else if (creditBalance > 0) {
      quotaSource = 'credit';
    } else {
      throw reasonError('resource-exhausted', 'X monthly limit reached', 'X_QUOTA_EXCEEDED', {
        quotaScope: 'monthly',
      });
    }

    claimDeviceIfNeeded();
    incrementDaily();
    if (quotaSource === 'monthly') {
      tx.set(
        monthlyRef,
        {
          uid,
          provider: 'x',
          periodType: 'monthly',
          period: monthlyKey,
          count: monthlyUsed + 1,
          lastPostedAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    } else {
      tx.update(billingRef, {
        postCredits: creditBalance - 1,
        updatedAt: FieldValue.serverTimestamp(),
      });
    }
    tx.update(postDocRef, {
      'targets.x.status': 'processing',
      'targets.x.quotaSource': quotaSource,
      'targets.x.quotaRefunded': false,
      updatedAt: FieldValue.serverTimestamp(),
    });
    return quotaSource;
  });
}

/**
 * quota章「投稿失敗時の返還ポリシー」節 準拠の補償トランザクション。
 * `POST /2/tweets` 送信前の失敗でのみ呼び出すこと(送信後・結果不明は呼び出し元が返還しない)。
 */
export async function refundXQuota(uid: string, postId: string, quotaSource: QuotaSource): Promise<void> {
  const now = new Date();
  const dailyKey = dailyPeriodKey(now);
  const monthlyKey = monthlyPeriodKey(now);
  const postDocRef = db.doc(`posts/${postId}`);
  const dailyRef = db.doc(`postUsage/${uid}_x_${dailyKey}`);
  const monthlyRef = db.doc(`postUsage/${uid}_x_${monthlyKey}`);
  const billingRef = db.doc(`users/${uid}/billing/state`);
  const grantRef = db.doc(`onboardingGrants/${uid}`);

  await db.runTransaction(async (tx) => {
    const postSnap = await tx.get(postDocRef);
    if (postSnap.get('targets.x.quotaRefunded') === true) return; // 冪等(二重返還防止)

    // 日次カウンタはグラント経路も含め全経路共通で消費しているため、常に1減算する
    const dailySnap = await tx.get(dailyRef);
    const dailyUsed = dailySnap.exists ? ((dailySnap.get('count') as number) ?? 0) : 0;
    tx.update(dailyRef, { count: Math.max(0, dailyUsed - 1), updatedAt: FieldValue.serverTimestamp() });

    if (quotaSource === 'grant') {
      tx.delete(grantRef); // 保証を返還(月次枠・クレジットの返還は発生しない)
    } else if (quotaSource === 'monthly') {
      const monthlySnap = await tx.get(monthlyRef);
      const monthlyUsed = monthlySnap.exists ? ((monthlySnap.get('count') as number) ?? 0) : 0;
      tx.update(monthlyRef, { count: Math.max(0, monthlyUsed - 1), updatedAt: FieldValue.serverTimestamp() });
    } else if (quotaSource === 'credit') {
      const billingSnap = await tx.get(billingRef);
      const currentCredits = ((billingSnap.get('postCredits') as number) ?? 0);
      tx.update(billingRef, { postCredits: currentCredits + 1, updatedAt: FieldValue.serverTimestamp() });
    }

    tx.update(postDocRef, { 'targets.x.quotaRefunded': true, updatedAt: FieldValue.serverTimestamp() });
  });
}
