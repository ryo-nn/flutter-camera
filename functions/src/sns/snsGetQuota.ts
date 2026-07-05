import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions/v2';
import { db } from '../lib/admin';
import { dailyPeriodKey, monthlyPeriodKey, nextDailyResetAt, nextMonthlyResetAt } from '../lib/period';
import { resolvePlan, type BillingStateLike } from '../lib/plan';
import { getDecryptedToken } from './tokenStore';
import * as igClient from './igClient';

/**
 * quota章「X残回数表示」+「onCallエラーコードの追加」節、backend章「既存関数の
 * インターフェース変更」表 準拠。appConfig/limits・billing/state・postUsageの
 * 同一ソースから残数を算出する(表示とサーバー判定の乖離防止)。
 */

interface Output {
  plan: 'free' | 'light' | 'pro';
  x: {
    monthly: { limit: number; used: number; remaining: number };
    daily: { limit: number; used: number; remaining: number };
    credits: { balance: number };
    resetAt: { daily: string; monthly: string };
  };
  instagram: {
    quotaUsage: number;
    quotaTotal: number;
    quotaDuration: number;
    fairUse: { limit: number; used: number; remaining: number };
  };
}

export const snsGetQuota = onCall(
  { enforceAppCheck: true },
  async (request): Promise<Output> => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign-in required');
    }
    const uid = request.auth.uid;
    const now = new Date();
    const dailyKey = dailyPeriodKey(now);
    const monthlyKey = monthlyPeriodKey(now);

    const [limitsSnap, billingSnap, xDailySnap, xMonthlySnap, igDailySnap] = await Promise.all([
      db.doc('appConfig/limits').get(),
      db.doc(`users/${uid}/billing/state`).get(),
      db.doc(`postUsage/${uid}_x_${dailyKey}`).get(),
      db.doc(`postUsage/${uid}_x_${monthlyKey}`).get(),
      db.doc(`postUsage/${uid}_instagram_${dailyKey}`).get(),
    ]);

    const plan = resolvePlan(billingSnap.exists ? (billingSnap.data() as BillingStateLike) : undefined, now);
    const postCredits = billingSnap.exists ? ((billingSnap.get('postCredits') as number) ?? 0) : 0;

    const xDailyLimit = (limitsSnap.get(`xDailyPostLimitByPlan.${plan}`) as number | undefined) ?? 0;
    const xMonthlyLimit = (limitsSnap.get(`xMonthlyPostLimitByPlan.${plan}`) as number | undefined) ?? 0;
    const igFairUseLimit = (limitsSnap.get(`igDailyFairUseLimitByPlan.${plan}`) as number | undefined) ?? 0;

    const xDailyUsed = xDailySnap.exists ? ((xDailySnap.get('count') as number) ?? 0) : 0;
    const xMonthlyUsed = xMonthlySnap.exists ? ((xMonthlySnap.get('count') as number) ?? 0) : 0;
    const igDailyUsed = igDailySnap.exists ? ((igDailySnap.get('count') as number) ?? 0) : 0;

    let igMeta = { quotaUsage: 0, quotaTotal: 0, quotaDuration: 0 };
    try {
      const tokenInfo = await getDecryptedToken(uid, 'instagram');
      if (tokenInfo && tokenInfo.doc.igUserId) {
        const limit = await igClient.getContentPublishingLimit(
          tokenInfo.doc.igUserId as string,
          tokenInfo.accessToken,
        );
        const usage = limit.data[0];
        if (usage) {
          igMeta = {
            quotaUsage: usage.quota_usage,
            quotaTotal: usage.config.quota_total,
            quotaDuration: usage.config.quota_duration,
          };
        }
      }
    } catch (err) {
      // Instagram未連携・API一時障害時は0を返す(残数表示は補助情報のため)
      logger.warn('snsGetQuota: Instagram content_publishing_limit 取得に失敗', {
        uid,
        error: String(err),
      });
    }

    return {
      plan,
      x: {
        monthly: {
          limit: xMonthlyLimit,
          used: xMonthlyUsed,
          remaining: Math.max(0, xMonthlyLimit - xMonthlyUsed),
        },
        daily: {
          limit: xDailyLimit,
          used: xDailyUsed,
          remaining: Math.max(0, xDailyLimit - xDailyUsed),
        },
        credits: { balance: postCredits },
        resetAt: {
          daily: nextDailyResetAt(now).toISOString(),
          monthly: nextMonthlyResetAt(now).toISOString(),
        },
      },
      instagram: {
        ...igMeta,
        fairUse: {
          limit: igFairUseLimit,
          used: igDailyUsed,
          remaining: Math.max(0, igFairUseLimit - igDailyUsed),
        },
      },
    };
  },
);
