import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { X_CLIENT_ID, X_CLIENT_SECRET } from '../config/secrets';
import * as xClient from './xClient';
import { saveTokens } from './tokenStore';
import { upsertConnectedState } from './connectionStore';

/**
 * backend章「X連携設計」節 準拠。
 * Confidential Client(Basic認証)でトークン交換 → プロフィール取得 → 保存。
 */

interface Input {
  code: string;
  codeVerifier: string;
  redirectUri: string;
}

interface Output {
  xUserId: string;
  username: string;
  scope: string;
}

export const xExchangeToken = onCall<Input>(
  { secrets: [X_CLIENT_SECRET], enforceAppCheck: true },
  async (request): Promise<Output> => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign-in required');
    }
    const uid = request.auth.uid;
    const { code, codeVerifier, redirectUri } = request.data;
    if (!code || !codeVerifier || !redirectUri) {
      throw new HttpsError('invalid-argument', 'code, codeVerifier, redirectUri は必須です');
    }

    const clientId = X_CLIENT_ID.value();
    const clientSecret = X_CLIENT_SECRET.value();

    const tokenResponse = await xClient.exchangeToken({
      code,
      codeVerifier,
      redirectUri,
      clientId,
      clientSecret,
    });

    const profile = await xClient.getMe(tokenResponse.access_token);

    const expiresAt = new Date(Date.now() + tokenResponse.expires_in * 1000);

    await saveTokens({
      uid,
      provider: 'x',
      accessToken: tokenResponse.access_token,
      refreshToken: tokenResponse.refresh_token ?? null,
      scopes: tokenResponse.scope.split(' '),
      expiresAt,
      externalUserId: profile.data.id,
    });

    await upsertConnectedState({
      uid,
      provider: 'x',
      username: profile.data.username,
      externalUserId: profile.data.id,
      accountType: null,
      scopes: tokenResponse.scope.split(' '),
      expiresAt,
    });

    return {
      xUserId: profile.data.id,
      username: profile.data.username,
      scope: tokenResponse.scope,
    };
  },
);
