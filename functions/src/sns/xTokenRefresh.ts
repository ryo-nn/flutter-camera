import { FieldValue, Timestamp } from 'firebase-admin/firestore';
import { db } from '../lib/admin';
import { decryptToken, encryptToken } from '../lib/kms';
import { X_CLIENT_ID, X_CLIENT_SECRET } from '../config/secrets';
import * as xClient from './xClient';

/**
 * backend章「リフレッシュトークン運用」節 準拠。
 * X APIを呼ぶ直前に expiresAt - 5分 < now ならオンデマンドでリフレッシュする
 * (IGと異なりXはスケジュールリフレッシュ不要)。
 * 同一ユーザーのリフレッシュ競合を防ぐため、snsTokens/{uid}_x ドキュメント上の
 * Firestoreトランザクションで「読み取り→更新」を直列化する
 * (トランザクション再試行時に外部API呼び出しが重複しうる点はトレードオフとして許容する)。
 * レスポンスに refresh_token が含まれていたら、ローテーション有無に関わらず
 * 必ず旧値を上書き保存する(単回使用でも再使用可能でも壊れないようにするため)。
 *
 * 戻り値が null の場合はリフレッシュ失敗(invalid_grant等)または未連携であり、
 * 呼び出し元は再連携フロー(TOKEN_EXPIRED)を実行すること。
 */
export async function ensureFreshXAccessToken(uid: string): Promise<string | null> {
  const ref = db.doc(`snsTokens/${uid}_x`);
  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) return null;
    const data = snap.data()!;
    const aad = `${uid}:x`;
    const expiresAt = data.expiresAt as Timestamp | null;
    const needsRefresh = !expiresAt || expiresAt.toMillis() - 5 * 60 * 1000 < Date.now();
    if (!needsRefresh) {
      return decryptToken(data.accessTokenCiphertext, aad);
    }
    if (!data.refreshTokenCiphertext) {
      // リフレッシュトークンが無ければ現行アクセストークンのまま試す(失効はAPI呼び出し時に検知)
      return decryptToken(data.accessTokenCiphertext, aad);
    }

    const refreshToken = await decryptToken(data.refreshTokenCiphertext, aad);
    let refreshed;
    try {
      refreshed = await xClient.refreshAccessToken({
        refreshToken,
        clientId: X_CLIENT_ID.value(),
        clientSecret: X_CLIENT_SECRET.value(),
      });
    } catch {
      return null;
    }

    const newExpiresAt = Timestamp.fromMillis(Date.now() + refreshed.expires_in * 1000);
    const encAccess = await encryptToken(refreshed.access_token, aad);
    const update: Record<string, unknown> = {
      accessTokenCiphertext: encAccess.ciphertext,
      encKeyRef: encAccess.keyVersion,
      expiresAt: newExpiresAt,
      updatedAt: FieldValue.serverTimestamp(),
    };
    if (refreshed.refresh_token) {
      const encRefresh = await encryptToken(refreshed.refresh_token, aad);
      update.refreshTokenCiphertext = encRefresh.ciphertext;
    }
    tx.set(ref, update, { merge: true });
    return refreshed.access_token;
  });
}
