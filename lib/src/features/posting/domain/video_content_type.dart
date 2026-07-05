/// 動画ファイルの拡張子からStorageアップロード時に申告すべき`contentType`を判定する
/// (コードレビュー指摘「MOV動画のcontentType不整合」対応)。
///
/// フォトライブラリから取り込んだ動画(iPhoneは通常`.mov`=QuickTimeコンテナ)を
/// クライアントが常に`video/mp4`として申告すると、実際のコンテナ形式と申告が
/// 食い違う。本ユーティリティはファイルパスの拡張子(大文字小文字を区別しない)から
/// 実態に即した`contentType`を判定する。
///
/// アプリ内動画撮影(`camera`パッケージ)の出力についても同一ロジックを適用する
/// (撮影結果の実ファイル拡張子が`.mp4`であれば従来どおり、`.mov`であれば
/// `video/quicktime`として扱われるだけで、取り込み動画と挙動は共通化される)。
abstract final class VideoContentType {
  const VideoContentType._();

  static const String mp4 = 'video/mp4';
  static const String quicktime = 'video/quicktime';

  /// ファイルパスの拡張子から`contentType`を判定する。
  /// `.mov`は`video/quicktime`、それ以外(`.mp4`等)は既定で`video/mp4`とする。
  static String fromFilePath(String filePath) {
    return filePath.toLowerCase().endsWith('.mov') ? quicktime : mp4;
  }
}
