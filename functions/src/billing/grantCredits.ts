import { FieldValue } from 'firebase-admin/firestore';
import { db } from '../lib/admin';
import type { RcWebhookEvent } from './rcTypes';

/**
 * billing章「消費型『X投稿10回パック ¥200』の購入フロー」節 準拠。
 * NON_RENEWING_PURCHASE イベントで、appConfig/billing.creditProducts に
 * 登録されたプロダクトIDのみクレジットを付与する。
 * creditGrants/{store}_{transactionId} の tx.get 存在チェックで冪等化する
 * (再送・二重イベントでも1回のみ付与)。
 */
export async function grantCredits(event: RcWebhookEvent): Promise<void> {
  if (!event.product_id || !event.store || !event.transaction_id) {
    return;
  }
  const configSnap = await db.doc('appConfig/billing').get();
  const creditProducts = (configSnap.get('creditProducts') as Record<string, number> | undefined) ?? {};
  const credits = creditProducts[event.product_id];
  if (!credits) return; // クレジット付与対象外のプロダクト

  const grantId = `${event.store}_${event.transaction_id}`;
  const grantRef = db.doc(`creditGrants/${grantId}`);
  const stateRef = db.doc(`users/${event.app_user_id}/billing/state`);

  await db.runTransaction(async (tx) => {
    const existing = await tx.get(grantRef);
    if (existing.exists) return; // 冪等: 再送・二重イベントでも1回のみ付与
    tx.set(grantRef, {
      uid: event.app_user_id,
      productId: event.product_id,
      credits,
      store: event.store,
      transactionId: event.transaction_id,
      eventId: event.id,
      environment: event.environment ?? null,
      revoked: false,
      createdAt: FieldValue.serverTimestamp(),
    });
    tx.set(
      stateRef,
      { postCredits: FieldValue.increment(credits), updatedAt: FieldValue.serverTimestamp() },
      { merge: true },
    );
  });
}

/**
 * billing章「イベント別処理表」の CANCELLATION 行(消費型の返金)準拠。
 * creditGrants の該当 transaction_id を照合し、未取消なら postCredits を
 * 減算(下限0)し grant を revoked 化する。対象grantが存在しない・既に取消済みの
 * 場合は何もしない(サブスクのCANCELLATIONイベントに対しても安全に呼び出せる)。
 */
export async function revokeCreditGrant(event: RcWebhookEvent): Promise<void> {
  if (!event.store || !event.transaction_id) return;
  const grantId = `${event.store}_${event.transaction_id}`;
  const grantRef = db.doc(`creditGrants/${grantId}`);
  const stateRef = db.doc(`users/${event.app_user_id}/billing/state`);

  await db.runTransaction(async (tx) => {
    const grantSnap = await tx.get(grantRef);
    if (!grantSnap.exists || grantSnap.get('revoked') === true) return;
    const credits = (grantSnap.get('credits') as number) ?? 0;
    const stateSnap = await tx.get(stateRef);
    const currentCredits = (stateSnap.get('postCredits') as number) ?? 0;
    tx.update(grantRef, { revoked: true });
    tx.set(
      stateRef,
      { postCredits: Math.max(0, currentCredits - credits), updatedAt: FieldValue.serverTimestamp() },
      { merge: true },
    );
  });
}
