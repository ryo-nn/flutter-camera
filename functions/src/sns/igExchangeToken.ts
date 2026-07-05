import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions/v2';
import { IG_APP_ID, IG_APP_SECRET } from '../config/secrets';
import * as igClient from './igClient';
import { saveTokens } from './tokenStore';
import { upsertConnectedState } from './connectionStore';
import { reasonError } from '../lib/errors';

/**
 * backend章「Instagram連携設計」節 準拠。
 * (a)短期トークン取得 → (b)長期トークンへ交換 → (c)プロアカウント判定 → 保存、を1呼び出しで行う。
 * プロアカウント(Business/Media_Creator)でなければトークンを保存せず破棄する。
 */

interface Input {
  code: string;
  redirectUri: string;
}

interface Output {
  igUserId: string;
  username: string;
  accountType: string;
  tokenExpiresAt: string;
}

const PROFESSIONAL_ACCOUNT_TYPES = new Set(['BUSINESS', 'MEDIA_CREATOR']);

export const igExchangeToken = onCall<Input>(
  { secrets: [IG_APP_SECRET], enforceAppCheck: true },
  async (request): Promise<Output> => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign-in required');
    }
    const uid = request.auth.uid;
    const { code, redirectUri } = request.data;
    if (!code || !redirectUri) {
      throw new HttpsError('invalid-argument', 'code, redirectUri は必須です');
    }

    const appId = IG_APP_ID.value();
    const appSecret = IG_APP_SECRET.value();

    // (a) 短期トークン取得
    const shortLived = await igClient.exchangeShortLivedToken({
      code,
      redirectUri,
      appId,
      appSecret,
    });

    // (b) 長期トークンへ交換(短期トークンは保存しない)
    const longLived = await igClient.exchangeLongLivedToken(shortLived.access_token, appSecret);

    // (c) プロアカウント判定
    const profile = await igClient.getProfile(longLived.access_token);
    const accountType = (profile.account_type ?? '').toUpperCase();
    if (!PROFESSIONAL_ACCOUNT_TYPES.has(accountType)) {
      logger.info('Instagram連携: プロアカウントでないためトークンを破棄', { uid, accountType });
      throw reasonError(
        'failed-precondition',
        'Instagramプロアカウント(Business/Creator)への切り替えが必要です',
        'IG_NOT_PROFESSIONAL_ACCOUNT',
      );
    }

    const expiresAt = new Date(Date.now() + longLived.expires_in * 1000);

    await saveTokens({
      uid,
      provider: 'instagram',
      accessToken: longLived.access_token,
      expiresAt,
      externalUserId: profile.user_id,
    });

    await upsertConnectedState({
      uid,
      provider: 'instagram',
      username: profile.username,
      externalUserId: profile.user_id,
      accountType: profile.account_type,
      scopes: shortLived.permissions ?? [],
      expiresAt,
    });

    return {
      igUserId: profile.user_id,
      username: profile.username,
      accountType: profile.account_type,
      tokenExpiresAt: expiresAt.toISOString(),
    };
  },
);
