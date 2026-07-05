import { onSchedule } from 'firebase-functions/v2/scheduler';
import { logger } from 'firebase-functions/v2';
import { Timestamp } from 'firebase-admin/firestore';
import { db } from '../lib/admin';
import * as igClient from './igClient';
import { decryptToken, encryptToken } from '../lib/kms';
import { markConnectionStatus } from './connectionStore';

/**
 * backend章「トークンのライフサイクル(短期→長期→リフレッシュ)」節 準拠。
 * 毎日03:00 JSTに実行し、発行から24時間以上経過・10日以内に失効するInstagram
 * 長期トークンをリフレッシュする(10日マージンでスケジューラ障害を吸収)。
 *
 * 参照クエリ(provider == 'instagram' AND expiresAt < now + 10日)には
 * 複合インデックス(collectionGroup: snsTokens, fields: provider ASC, expiresAt ASC)
 * が必要。firestore.indexes.json はRules担当の管轄のため、統合フェーズでの
 * 追加を依頼する(coreChangeRequests参照)。
 */
export const igRefreshTokens = onSchedule(
  { schedule: 'every day 03:00', timeZone: 'Asia/Tokyo' },
  async () => {
    const tenDaysFromNow = Timestamp.fromMillis(Date.now() + 10 * 24 * 60 * 60 * 1000);
    const snapshot = await db
      .collection('snsTokens')
      .where('provider', '==', 'instagram')
      .where('expiresAt', '<', tenDaysFromNow)
      .get();

    logger.info(`igRefreshTokens: 対象 ${snapshot.size} 件`);

    await Promise.all(
      snapshot.docs.map(async (doc) => {
        const data = doc.data();
        const uid: string | undefined = data.uid;
        if (!uid) {
          logger.error('igRefreshTokens: uid フィールドが無いドキュメント', { docId: doc.id });
          return;
        }
        try {
          const aad = `${uid}:instagram`;
          const longLivedToken = await decryptToken(data.accessTokenCiphertext, aad);
          const refreshed = await igClient.refreshLongLivedToken(longLivedToken);
          const encAccess = await encryptToken(refreshed.access_token, aad);
          const newExpiresAt = Timestamp.fromMillis(Date.now() + refreshed.expires_in * 1000);
          await doc.ref.set(
            {
              accessTokenCiphertext: encAccess.ciphertext,
              encKeyRef: encAccess.keyVersion,
              expiresAt: newExpiresAt,
              updatedAt: Timestamp.now(),
            },
            { merge: true },
          );
        } catch (err) {
          // リフレッシュ失敗=失効済みとみなし、再連携フローへ(トークン削除+status: 'expired')
          logger.warn('igRefreshTokens: リフレッシュ失敗。再連携要求へ', { uid, error: String(err) });
          await doc.ref.delete();
          await markConnectionStatus(uid, 'instagram', 'expired');
        }
      }),
    );
  },
);
