import { RC_SECRET_API_KEY } from '../config/secrets';
import type { RcSubscriberResponse } from './rcTypes';

/**
 * GET https://api.revenuecat.com/v1/subscribers/{app_user_id}
 * 出典: https://www.revenuecat.com/docs/api-v1
 */
export async function getSubscriber(appUserId: string): Promise<RcSubscriberResponse> {
  const res = await fetch(`https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(appUserId)}`, {
    headers: { Authorization: `Bearer ${RC_SECRET_API_KEY.value()}` },
  });
  if (!res.ok) {
    throw new Error(`RevenueCat subscribers API error: ${res.status}`);
  }
  return res.json() as Promise<RcSubscriberResponse>;
}
