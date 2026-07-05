/**
 * RevenueCat REST API v1 / Webhookイベントの最小型定義。
 * 出典: https://www.revenuecat.com/docs/api-v1
 *       https://www.revenuecat.com/docs/integrations/webhooks/event-types-and-fields
 */

export interface RcEntitlement {
  expires_date: string | null;
  grace_period_expires_date?: string | null;
  product_identifier: string;
  purchase_date?: string;
}

export interface RcSubscription {
  expires_date: string | null;
  period_type?: 'normal' | 'trial' | 'intro' | string;
  grace_period_expires_date?: string | null;
}

export interface RcSubscriberResponse {
  subscriber: {
    entitlements: Record<string, RcEntitlement>;
    subscriptions: Record<string, RcSubscription>;
  };
}

export interface RcWebhookEvent {
  id: string;
  type: string;
  app_user_id: string;
  product_id?: string;
  store?: string;
  transaction_id?: string;
  environment?: 'SANDBOX' | 'PRODUCTION' | string;
  transferred_from?: string[];
  transferred_to?: string[];
  [key: string]: unknown;
}

export interface RcWebhookBody {
  event: RcWebhookEvent;
}
