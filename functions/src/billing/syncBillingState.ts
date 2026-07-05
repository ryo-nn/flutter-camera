import { FieldValue, Timestamp } from 'firebase-admin/firestore';
import { db } from '../lib/admin';
import { getSubscriber } from './rcApi';
import type { RcEntitlement } from './rcTypes';

/**
 * billing章「プラン状態の同期設計」節 準拠の「書き込み時導出」(プラン解決規則1)。
 * rcWebhook / rcRefreshCustomer の両方から呼ばれる単一の同期処理。
 * イベント差分ではなく `GET /v1/subscribers/{uid}` を毎回全量取得して上書きする
 * (イベント順序の入れ替わり・取りこぼしがあっても最終的に正しい状態へ収束する)。
 */

function isActive(ent: RcEntitlement | undefined, now: number): boolean {
  if (!ent) return false;
  if (!ent.expires_date) return true; // 無期限エンタイトルメント(通常は発生しない想定)
  return new Date(ent.expires_date).getTime() > now;
}

export interface BillingSyncResult {
  plan: 'free' | 'light' | 'pro';
  isTrial: boolean;
  postCredits: number;
}

export async function syncBillingState(uid: string): Promise<BillingSyncResult> {
  const subscriber = await getSubscriber(uid);
  const entitlements = subscriber.subscriber.entitlements ?? {};
  const subscriptions = subscriber.subscriber.subscriptions ?? {};
  const now = Date.now();

  const pro = entitlements['pro'];
  const light = entitlements['light'];

  let plan: 'free' | 'light' | 'pro' = 'free';
  let active: RcEntitlement | undefined;
  if (isActive(pro, now)) {
    plan = 'pro';
    active = pro;
  } else if (isActive(light, now)) {
    plan = 'light';
    active = light;
  }

  const activeSubscription = active ? subscriptions[active.product_identifier] : undefined;
  const isTrial = (activeSubscription?.period_type ?? '').toLowerCase() === 'trial';

  // planExpiresAt: grace_period_expires_date が設定されていればそちらを採用(グレース中はアクセス維持)
  const expiryIso = active ? (active.grace_period_expires_date ?? active.expires_date) : null;

  const ref = db.doc(`users/${uid}/billing/state`);
  await ref.set(
    {
      plan,
      isTrial,
      planProductId: active?.product_identifier ?? null,
      planExpiresAt: expiryIso ? Timestamp.fromDate(new Date(expiryIso)) : null,
      rcLastEventAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  const snap = await ref.get();
  return {
    plan,
    isTrial,
    postCredits: (snap.get('postCredits') as number) ?? 0,
  };
}
