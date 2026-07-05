/**
 * SNS種別・投稿ターゲット状態機械の型定義。
 *
 * 注意(design.mdの既知の未解決事項): data章のFreezed `PostTargetStatus` enumは
 * 7値(pending/publishing/succeeded/failed_retryable/failed_unknown/failed_permanent/skipped)
 * だが、backend章・quota章の実装(本Functions)は一貫して
 * 「pending → processing → succeeded | failed」の4値 + 併設フィールド `failureKind`
 * (retryable|permanent|unknown)を採用する。quota章に明記のとおり
 * 「data章enums.dartの7値との不整合は既存の未解決事項であり、この追補では解決しない」
 * ため、本FunctionsはFirestoreへ書き込む公開語彙として4値+failureKindを採用する
 * (design.mdのTS実装サンプルがすべてこの語彙で書かれているため)。
 * クライアント側Freezedモデルとの整合はintegrationフェーズでの確認事項とする。
 */
export type SnsProvider = 'instagram' | 'x';

export type PersistedTargetStatus = 'pending' | 'processing' | 'succeeded' | 'failed';

export type FailureKind = 'retryable' | 'permanent' | 'unknown';

export type QuotaSource = 'grant' | 'monthly' | 'credit';

export type SnsConnectionStatus = 'connected' | 'expired' | 'revoked' | 'error';

/**
 * 投稿メディア種別。動画対応追補で追加。未指定は既存互換のため'image'として扱う
 * (クライアントは後方互換のためmediaType省略時に旧来どおり画像投稿として振る舞う)。
 */
export type MediaType = 'image' | 'video';

export interface PublishPostInput {
  postId: string;
  imagePath: string;
  caption: string;
  targets: {
    instagram: boolean;
    x: boolean;
  };
  force?: boolean;
  /** freeプランでXターゲット選択時は必須(生識別子。サーバー側でハッシュ化する) */
  deviceId?: string;
  /**
   * deviceId 指定時のプラットフォーム('ios' | 'android')。devices/{deviceId} の
   * platform フィールドに使用する。design.mdの `devices` スキーマが要求するが
   * snsPublishPost入力への追加は明記されていないため、本実装で追加した契約
   * (coreChangeRequestsでクライアント/データ担当へ確認依頼)。
   */
  platform?: 'ios' | 'android';
  /** 適用パターンのドキュメントID。「加工なし」投稿は未指定 */
  patternId?: string;
  /**
   * 投稿メディア種別(動画対応追補)。省略時は'image'扱い(後方互換)。
   * imagePathが指すStorageオブジェクトは既存の一時アップロードパス
   * (`users/{uid}/postImages/{fileName}`)を流用し、contentTypeで
   * image/jpeg(既存)とvideo/mp4(新規)を区別する。
   */
  mediaType?: MediaType;
  /** mediaType: 'video' 時は必須。動画の長さ(秒)。クォータ消費前にターゲット別上限を検証する */
  durationSec?: number;
  /** mediaType: 'video' 時は必須。動画ファイルサイズ(バイト)。クォータ消費前にターゲット別上限を検証し、Storage実体とも突き合わせる */
  fileSizeBytes?: number;
}

export interface PublishPostResult {
  postId: string;
  overallStatus: 'processing' | 'succeeded' | 'partial' | 'failed';
  results: {
    instagram?: { status: PersistedTargetStatus; publishedId?: string; errorCode?: string };
    x?: { status: PersistedTargetStatus; publishedId?: string; errorCode?: string };
  };
}
