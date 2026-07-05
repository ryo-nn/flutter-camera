import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions/v2';
import { FieldValue, type DocumentData, type Query } from 'firebase-admin/firestore';
import { auth, bucket, db } from '../lib/admin';
import { reasonError } from '../lib/errors';
import { buildAccountDeleteTargets, deviceOwnershipReleaseFields } from './accountDeleteTargets';

/**
 * App Store審査対応(Apple Guideline 5.1.1(v) アカウント削除要件)のアカウント削除。
 * クライアント(別担当)は再認証済みの状態で引数なしで呼ぶ。backend章の既存onCall作法
 * (unauthenticated判定 → enforceAppCheck: true。region はindex.tsのsetGlobalOptionsで
 * asia-northeast1固定済みのためここでは指定しない)にそのまま合わせる。
 *
 * 【冪等性】各削除ステップは「存在すれば削除/更新、存在しなければ何もしない」形にして
 * あるため、途中失敗後の再実行で必ず完走できる。処理順は
 * 「Firestore/Storageのデータ削除 → 最後にAuthユーザー削除」の固定順とする。
 * Authユーザー削除後はこの関数を呼ぶための認証済みIDトークン自体が発行できなくなり
 * 再実行不能になるため、必ず最後に置く(要件どおり)。
 *
 * 【RevenueCatのサブスク解約】サブスクリプションの解約はApple/Google(ストア)側の管理
 * であり、サーバー(本関数)からは一切操作できない。ユーザーはOS標準のサブスク管理画面
 * から解約する必要がある(billing章の既定方針どおり。本関数はplan/postCreditsを含む
 * users/{uid}/billing/state を削除するのみで、RevenueCat側のサブスク状態には触れない)。
 *
 * 【課金監査ログ(rcEvents・creditGrants)を削除対象に含めない理由】
 * - rcEvents/{eventId}: RevenueCat Webhookの冪等化台帳。既にexpireAt(90日)のTTLが
 *   設定済みで、Firestore TTLポリシーにより一定期間後は自動削除される設計(rcWebhook.ts参照)。
 * - creditGrants/{store}_{transactionId}: 購入クレジット付与/取消の二重処理防止台帳
 *   (grantCredits.ts参照)。取引記録であり、不正利用調査・決済突合・会計監査等の正当な
 *   事業目的での保持が必要となり得る(Apple Guideline 5.1.1(v)が認める「法令順守・不正防止
 *   に必要なデータの保持」に相当すると判断)。
 * どちらも保持しているのは取引ID・uid・金額相当の情報のみで、氏名・連絡先等の
 * プロフィール情報は保持しないため、削除対象外としてもプライバシー上の実害は小さい。
 */

interface Output {
  deleted: true;
}

export const accountDelete = onCall(
  { enforceAppCheck: true },
  async (request): Promise<Output> => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign-in required');
    }
    const uid = request.auth.uid;
    const targets = buildAccountDeleteTargets(uid);

    try {
      await Promise.all([
        // users/{uid} 本体 + 全サブコレクション(billing/state・snsConnections等)を再帰削除
        db.recursiveDelete(db.doc(targets.userDocPath)),
        // uidフィールドのクエリで全件削除するコレクション(列挙はaccountDeleteTargets.ts参照):
        // - patterns(ownerUid): ユーザー作成パターンのみ。ownerType: 'preset' の運営プリセットは対象外
        // - posts(userId): 投稿履歴
        // - postUsage(uid): X日次/月次・IG日次の利用カウンタ(全期間分。個人データのため削除)
        ...targets.uidQueryTargets.map(({ collection, field }) =>
          deleteQueryMatches(db.collection(collection).where(field, '==', uid)),
        ),
        // snsTokens: instagram/x 両方のトークンドキュメント(存在しなければ削除はno-op)
        ...targets.snsTokenDocPaths.map((path) => db.doc(path).delete()),
        // onboardingGrants/{uid}: 初回投稿グラント消費記録
        db.doc(targets.onboardingGrantDocPath).delete(),
        // devices: 当該uidが占有する端末の紐付けのみ解放(ドキュメント自体は削除しない。理由は関数コメント参照)
        releaseDeviceOwnership(uid),
        // Storage: 加工済み投稿画像(users/{uid}/postImages等)とInstagram一時公開ファイル(igTemp/{uid}/)
        ...targets.storagePrefixes.map((prefix) => bucket.deleteFiles({ prefix, force: true })),
      ]);
    } catch (err) {
      logger.error('accountDelete: データ削除に失敗(冪等設計のため再実行で継続可能)', { uid, error: String(err) });
      throw reasonError(
        'internal',
        'アカウントデータの削除に失敗しました。しばらくしてから再度お試しください',
        'ACCOUNT_DELETE_FAILED',
      );
    }

    try {
      await auth.deleteUser(uid);
    } catch (err) {
      if (isUserNotFoundError(err)) {
        // 直前の実行(再試行)でAuthユーザー削除まで完了済み。冪等に成功扱いとする
        return { deleted: true };
      }
      logger.error('accountDelete: Authユーザー削除に失敗', { uid, error: String(err) });
      throw reasonError(
        'internal',
        'アカウント削除の最終処理に失敗しました。しばらくしてから再度お試しください',
        'ACCOUNT_DELETE_FAILED',
      );
    }

    return { deleted: true };
  },
);

/**
 * devices/{deviceId} は「1端末の無料X枠は最初の1アカウントのみ」という乱用対策
 * (design.md 乱用対策章「デバイス単位の無料枠管理」節)の器であり、freeOwnerUidが
 * 端末の無料枠占有者を表す。アカウント削除時にこのドキュメントごと削除してしまうと、
 * 同一端末で「無料枠を使い切る → 退会 → アカウントを作り直す → 再び無料枠を得る」を
 * 際限なく繰り返せてしまい、乱用対策そのものが無効化される。
 * design.mdは「機種変更・端末譲渡での占有解除」を明示的にopenQuestions(未確定の
 * サポート運用)としており、退会という自己都合の操作で自動的に占有解放してよいとは
 * 決まっていない。そのため本関数では、当該uidが占有するdevicesドキュメントは削除せず、
 * freeOwnerUidのみをnullにして「このuidとの紐付け」だけを解放する。
 * ドキュメント自体は残り、freeOwnerUidが新しいuidと一致することは以後ないため、
 * 退会後に同一端末で新規アカウントを作っても無料枠は再取得できない
 * (既存のsnsPublishPost enforcement `device.exists && freeOwnerUid !== uid` により
 * 引き続きFREE_QUOTA_DEVICE_LIMITでブロックされる=既存の乱用対策仕様どおり)。
 */
async function releaseDeviceOwnership(uid: string): Promise<void> {
  const snap = await db.collection('devices').where('freeOwnerUid', '==', uid).get();
  if (snap.empty) return;
  const writer = db.bulkWriter();
  for (const doc of snap.docs) {
    writer.update(doc.ref, {
      ...deviceOwnershipReleaseFields(),
      updatedAt: FieldValue.serverTimestamp(),
    });
  }
  await writer.close();
}

/** クエリに一致する全ドキュメントをBulkWriterで削除する(0件なら何もしない=冪等) */
async function deleteQueryMatches(query: Query<DocumentData>): Promise<void> {
  const snap = await query.get();
  if (snap.empty) return;
  const writer = db.bulkWriter();
  for (const doc of snap.docs) {
    writer.delete(doc.ref);
  }
  await writer.close();
}

function isUserNotFoundError(err: unknown): boolean {
  return typeof err === 'object' && err !== null && (err as { code?: string }).code === 'auth/user-not-found';
}
