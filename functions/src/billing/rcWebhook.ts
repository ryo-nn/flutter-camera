import { onRequest } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions/v2';
import { timingSafeEqual } from 'node:crypto';
import { FieldValue, Timestamp } from 'firebase-admin/firestore';
import { db } from '../lib/admin';
import { RC_EXPECTED_ENVIRONMENT, RC_SECRET_API_KEY, RC_WEBHOOK_AUTH } from '../config/secrets';
import { syncBillingState } from './syncBillingState';
import { grantCredits, revokeCreditGrant } from './grantCredits';
import type { RcWebhookBody, RcWebhookEvent } from './rcTypes';

/**
 * billing章「Webhook → Cloud Functions → Firestore のフロー」節 準拠。
 * 認証(Authorizationヘッダの定数時間比較)→ rcEvents/{id} での冪等化 →
 * イベント別処理表に従いdispatch、の順で処理する。
 */

const SUBSCRIPTION_EVENT_TYPES = new Set([
  'INITIAL_PURCHASE',
  'RENEWAL',
  'UNCANCELLATION',
  'PRODUCT_CHANGE',
  'SUBSCRIPTION_EXTENDED',
  'EXPIRATION',
  'BILLING_ISSUE',
  'CANCELLATION',
  'TRANSFER',
]);

const RC_EVENT_TTL_DAYS = 90;

export const rcWebhook = onRequest({ secrets: [RC_WEBHOOK_AUTH, RC_SECRET_API_KEY] }, async (req, res) => {
  if (req.method !== 'POST') {
    res.status(405).end();
    return;
  }

  const expected = Buffer.from(RC_WEBHOOK_AUTH.value());
  const actual = Buffer.from(req.get('Authorization') ?? '');
  if (actual.length !== expected.length || !timingSafeEqual(actual, expected)) {
    res.status(401).end();
    return;
  }

  const body = req.body as RcWebhookBody | undefined;
  const event = body?.event;
  if (!event || !event.id || !event.app_user_id) {
    res.status(400).json({ error: 'invalid event payload' });
    return;
  }

  const expectedEnv = RC_EXPECTED_ENVIRONMENT.value();
  if (expectedEnv && event.environment && event.environment !== expectedEnv) {
    logger.warn('rcWebhook: 環境不一致イベントをスキップ(多層防御)', {
      eventId: event.id,
      environment: event.environment,
      expected: expectedEnv,
    });
    res.status(200).json({ received: true, skipped: 'environment_mismatch' });
    return;
  }

  try {
    const eventRef = db.doc(`rcEvents/${event.id}`);
    const alreadyProcessed = await db.runTransaction(async (tx) => {
      const snap = await tx.get(eventRef);
      if (snap.exists) return true;
      tx.create(eventRef, {
        type: event.type,
        appUserId: event.app_user_id,
        processedAt: FieldValue.serverTimestamp(),
        expireAt: Timestamp.fromMillis(Date.now() + RC_EVENT_TTL_DAYS * 24 * 60 * 60 * 1000),
      });
      return false;
    });

    if (alreadyProcessed) {
      res.status(200).json({ received: true, duplicate: true });
      return;
    }

    await dispatchEvent(event);
    res.status(200).json({ received: true });
  } catch (err) {
    logger.error('rcWebhook処理失敗', { error: String(err) });
    res.status(500).json({ error: 'internal error' });
  }
});

async function dispatchEvent(event: RcWebhookEvent): Promise<void> {
  if (typeof event.app_user_id === 'string' && event.app_user_id.startsWith('$RCAnonymousID:')) {
    logger.warn('rcWebhook: 匿名IDからのイベント(サインイン後にのみconfigureする設計のため想定外)', {
      eventId: event.id,
      type: event.type,
    });
    return;
  }

  if (SUBSCRIPTION_EVENT_TYPES.has(event.type)) {
    await syncBillingState(event.app_user_id);

    if (event.type === 'TRANSFER') {
      const relatedIds = new Set<string>([
        ...((event.transferred_from as string[] | undefined) ?? []),
        ...((event.transferred_to as string[] | undefined) ?? []),
      ]);
      relatedIds.delete(event.app_user_id);
      await Promise.all(
        Array.from(relatedIds).map((id) =>
          syncBillingState(id).catch((err) => {
            logger.error('rcWebhook: TRANSFER関連UIDの同期に失敗', { id, error: String(err) });
          }),
        ),
      );
    }

    if (event.type === 'CANCELLATION') {
      // サブスクのキャンセルか消費型の返金かをここでは区別せず、
      // 該当transaction_idのcreditGrantが存在する場合のみ返金処理を行う(冪等)
      await revokeCreditGrant(event).catch((err) => {
        logger.error('rcWebhook: creditGrant取消処理に失敗', { error: String(err) });
      });
    }
    return;
  }

  if (event.type === 'NON_RENEWING_PURCHASE') {
    await grantCredits(event);
    return;
  }

  logger.info('rcWebhook: ログのみのイベント種別', { eventId: event.id, type: event.type });
}
