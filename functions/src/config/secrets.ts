import { defineSecret, defineString } from 'firebase-functions/params';

/**
 * design.md バックエンド設計「シークレット管理」節 準拠。
 * 値の設定(firebase functions:secrets:set 等)はRYOが後で行う前提で、
 * ここではパラメータ定義のみを行う。
 */

// Instagram (Business Login)
export const IG_APP_SECRET = defineSecret('IG_APP_SECRET');
export const IG_APP_ID = defineString('IG_APP_ID');

// X (OAuth 2.0 Confidential Client)
export const X_CLIENT_SECRET = defineSecret('X_CLIENT_SECRET');
export const X_CLIENT_ID = defineString('X_CLIENT_ID');

// トークン暗号化(Cloud KMS 対称鍵・直接暗号化)
export const KMS_KEY_NAME = defineString('KMS_KEY_NAME');

// RevenueCat連携
export const RC_WEBHOOK_AUTH = defineSecret('RC_WEBHOOK_AUTH');
export const RC_SECRET_API_KEY = defineSecret('RC_SECRET_API_KEY');
/**
 * billing章「環境分離」節 準拠。本番Firebaseプロジェクトでは 'PRODUCTION' を設定し、
 * event.environment !== 'PRODUCTION' のイベントを多層防御としてスキップする。
 * 開発プロジェクトでは未設定(空文字)のままにしてsandboxイベントも処理できるようにする。
 * design.mdはプロジェクトID等の具体値を規定していないため、本実装で追加したパラメータ
 * (coreChangeRequests参照。値の設定はRYOが環境ごとに行う)。
 */
export const RC_EXPECTED_ENVIRONMENT = defineString('RC_EXPECTED_ENVIRONMENT', { default: '' });

// デバイス単位無料枠管理(端末生IDのハッシュ化用ペッパー)
export const DEVICE_ID_PEPPER = defineSecret('DEVICE_ID_PEPPER');
