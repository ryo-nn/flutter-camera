import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions/v2';
import { X_CLIENT_ID, X_CLIENT_SECRET } from '../config/secrets';
import * as xClient from './xClient';
import { deleteTokens, getDecryptedToken } from './tokenStore';
import { markConnectionStatus } from './connectionStore';
import type { SnsProvider } from './types';

/**
 * backend章「リフレッシュトークン運用」節 準拠。
 * X: revoke API でトークン失効 → 削除 → status: 'revoked'。
 * Instagram: 失効APIの規定がないため削除 + status: 'revoked' のみ。
 */

interface Input {
  provider: SnsProvider;
}

interface Output {
  disconnected: true;
}

export const snsDisconnect = onCall<Input>(
  { secrets: [X_CLIENT_SECRET], enforceAppCheck: true },
  async (request): Promise<Output> => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign-in required');
    }
    const uid = request.auth.uid;
    const { provider } = request.data;
    if (provider !== 'instagram' && provider !== 'x') {
      throw new HttpsError('invalid-argument', "provider は 'instagram' または 'x' である必要があります");
    }

    if (provider === 'x') {
      const tokenInfo = await getDecryptedToken(uid, 'x');
      if (tokenInfo) {
        try {
          await xClient.revokeToken({
            token: tokenInfo.accessToken,
            clientId: X_CLIENT_ID.value(),
            clientSecret: X_CLIENT_SECRET.value(),
          });
        } catch (err) {
          // revoke失敗(既に失効済み等)でも解除処理自体は継続する
          logger.warn('X revokeToken 失敗(解除処理は継続)', { uid, error: String(err) });
        }
      }
    }

    await deleteTokens(uid, provider);
    await markConnectionStatus(uid, provider, 'revoked');

    return { disconnected: true };
  },
);
