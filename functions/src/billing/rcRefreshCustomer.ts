import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { RC_SECRET_API_KEY } from '../config/secrets';
import { syncBillingState } from './syncBillingState';

/**
 * billing章「即時同期(rcRefreshCustomer onCall)」節 準拠。
 * 購入・リストア成功直後にクライアントが呼び、rcWebhookと同一のsyncBillingStateを
 * 共有することで導出ロジックを一元化する。
 */
export const rcRefreshCustomer = onCall(
  { secrets: [RC_SECRET_API_KEY], enforceAppCheck: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign-in required');
    }
    return syncBillingState(request.auth.uid);
  },
);
