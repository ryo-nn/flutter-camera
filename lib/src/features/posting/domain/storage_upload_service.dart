/// 加工済みJPEGの一時アップロードサービスの抽象インターフェース。
///
/// design.md アーキテクチャ章のディレクトリ構造コメントは
/// `posting/data/storage_upload_service.dart` のみを列挙しているが、
/// 同章「レイヤー責務と依存方向」は presentation が data 層の具象クラスを
/// 直接importせず domain のインターフェース型で受けることを求めている
/// (editorの `pattern_apply_service.dart` と同様のdomain/data分離)。
/// この原則を満たすため本ファイルを追加している(notes参照)。
abstract interface class StorageUploadService {
  /// 加工済みJPEGを `users/{uid}/postImages/{imageId}.jpg`
  /// (backend章「画像の公開URL(Storage一時公開画像)との組み合わせ」節・
  /// data確定パス)へアップロードし、`snsPublishPost` の `imagePath` に
  /// そのまま渡せるパス文字列を返す。
  ///
  /// 公開URLの発行自体はCloud Functions側(Instagram投稿時のみ、
  /// `igTemp/` への署名付きURL)が行うため、本サービスは恒久非公開パスへの
  /// アップロードのみを担う(storage.rulesの `users/{uid}/postImages/` は
  /// contentType: image/jpeg・10MB未満の `create` のみ許可し更新・削除不可)。
  Future<String> uploadPostImage({
    required String uid,
    required String localFilePath,
  });

  /// 加工不要な動画(v1では動画加工非対応)を `users/{uid}/postImages/{videoId}.mp4`
  /// (画像と同じ一時Storageパス方式)へアップロードする。
  ///
  /// [contentType] は動画ファイルの実コンテナ形式に対応するStorage
  /// `contentType`(`video/mp4` | `video/quicktime`。呼び出し元が
  /// `VideoContentType.fromFilePath` で判定した値をそのまま渡す。
  /// コードレビュー指摘「MOV動画のcontentType不整合」対応)。
  ///
  /// storage.rulesの動画対応(サイズ上限・contentType許可)は別担当が並行対応中の
  /// ため、クライアントは契約(パス方式・contentType)どおりにアップロードのみ行う。
  Future<String> uploadPostVideo({
    required String uid,
    required String localFilePath,
    required String contentType,
  });
}
