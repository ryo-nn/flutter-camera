import type { SnsProvider } from '../sns/types';

/**
 * accountDelete(アカウント削除)が触るFirestore/Storageパスの列挙のみを担う純粋ロジック。
 * Admin SDK呼び出しを一切含まないため、実際のFirestore/Storage接続なしにnode:testで
 * 検証できる(削除対象パスの組み立てミスは即座に他ユーザーへの誤爆に直結するため、
 * 本体のCloud Functions実装から分離してユニットテストの対象にする)。
 *
 * 【uid紐付けドキュメントの棚卸しと削除方針】functions/src全体のFirestoreアクセスを
 * 走査した結果、uidに紐づくコレクションと本関数での扱いは以下のとおり:
 * - users/{uid}(+全サブコレクション) … recursiveDeleteで削除
 * - snsTokens/{uid}_{provider} / onboardingGrants/{uid} … 決定的IDで直接削除
 * - patterns(ownerUid)/ posts(userId)/ postUsage(uid) … uidフィールドのクエリで全件削除。
 *   postUsageはドキュメントIDが期間キー付き({uid}_x_d20260704等)で過去期間分を
 *   IDから列挙できないため、全ドキュメントに永続化済みのuidフィールドで検索する
 *   (X日次/月次・Instagram日次のすべてが該当)。利用カウンタは個人データであり、
 *   devicesと異なり乱用対策上の保持理由がない(端末単位の無料枠管理はdevicesの
 *   freeOwnerUid保持で担保済み)ため削除対象とする
 * - devices(freeOwnerUid) … 削除せずuid紐付けのみ解放(deviceOwnershipReleaseFields参照)
 * - rcEvents / creditGrants … 削除対象外(保持理由はaccountDelete.tsの関数コメント参照)
 */

/** snsTokens/{uid}_{provider} のドキュメントID生成に使うprovider一覧(sns/types.tsのSnsProviderと同一) */
const SNS_PROVIDERS: readonly SnsProvider[] = ['instagram', 'x'];

/** uidフィールドの等価クエリで全件削除するコレクションの指定 */
export interface UidQueryTarget {
  /** コレクション名 */
  collection: string;
  /** uidが格納されているフィールド名 */
  field: string;
}

export interface AccountDeleteTargets {
  /** users/{uid} 本体 + 全サブコレクション(billing/state・snsConnections等)。recursiveDeleteの対象 */
  userDocPath: string;
  /** snsTokens/{uid}_{provider}(instagram/x両方)。存在しなければ削除はno-op */
  snsTokenDocPaths: string[];
  /** onboardingGrants/{uid}(初回投稿グラント消費記録) */
  onboardingGrantDocPath: string;
  /** uidフィールドのクエリで全件削除するコレクション(patterns/posts/postUsage) */
  uidQueryTargets: UidQueryTarget[];
  /** Storageの削除対象プレフィックス(加工済み投稿画像 / Instagram一時公開ファイル) */
  storagePrefixes: string[];
}

export function buildAccountDeleteTargets(uid: string): AccountDeleteTargets {
  return {
    userDocPath: `users/${uid}`,
    snsTokenDocPaths: SNS_PROVIDERS.map((provider) => `snsTokens/${uid}_${provider}`),
    onboardingGrantDocPath: `onboardingGrants/${uid}`,
    uidQueryTargets: [
      // ユーザー作成パターンのみ(プリセットはownerUid: nullのため等価クエリに一致しない)
      { collection: 'patterns', field: 'ownerUid' },
      // 投稿履歴
      { collection: 'posts', field: 'userId' },
      // 利用カウンタ(X日次/月次・Instagram日次フェアユース。全期間分)
      { collection: 'postUsage', field: 'uid' },
    ],
    storagePrefixes: [`users/${uid}/`, `igTemp/${uid}/`],
  };
}

/**
 * devices/{deviceId} の当該uid紐付けを解放する際の更新フィールド。
 * ドキュメント自体は削除せず(理由はaccountDelete.tsのreleaseDeviceOwnership参照)、
 * freeOwnerUidのみをnullにして「このuidが占有していた」という情報を切り離す。
 * platform/firstSeenAt等の乱用対策情報(この端末は既に無料枠を消費済み)は
 * このオブジェクトに含めないことで、呼び出し側が誤って上書きしない形にする。
 */
export function deviceOwnershipReleaseFields(): { freeOwnerUid: null } {
  return { freeOwnerUid: null };
}
