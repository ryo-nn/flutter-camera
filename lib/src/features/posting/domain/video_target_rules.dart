/// S-07 動画投稿のターゲット別クライアント側バリデーション(純Dart・
/// Flutter/Firebase SDK非依存)。`caption_rules.dart` と同様、UXのための
/// 事前チェックに過ぎず、最終判定は常にサーバー側(`snsPublishPost`)が正とする。
///
/// 仕様確定値:
/// - Instagram: 3秒〜15分かつ300MB以下(リールとして投稿される)。MOV/MP4いずれの
///   コンテナも受理する(公式: [IG User Media Reference]
///   (https://developers.facebook.com/docs/instagram-platform/instagram-graph-api/reference/ig-user/media))。
/// - X: 0.5秒〜140秒かつ512MB以下。コンテナはMP4のみ受理(公式サンプルがMP4のみで
///   確認済み。MOV(`video/quicktime`)の受理可否は未確認のため選択不可にする。
///   コードレビュー指摘「MOV動画のcontentType不整合」対応)。
abstract final class VideoTargetRules {
  const VideoTargetRules._();

  static const double instagramMinDurationSec = 3;
  static const double instagramMaxDurationSec = 15 * 60;
  static const int instagramMaxFileSizeBytes = 300 * 1024 * 1024;

  static const double xMinDurationSec = 0.5;
  static const double xMaxDurationSec = 140;
  static const int xMaxFileSizeBytes = 512 * 1024 * 1024;

  /// Xが受理するStorage `contentType`(MP4のみ。`video/quicktime`はXターゲット
  /// 選択不可にする)。
  static const String xAllowedContentType = 'video/mp4';

  static bool isInstagramEligible({
    required double durationSec,
    required int fileSizeBytes,
  }) {
    return durationSec >= instagramMinDurationSec &&
        durationSec <= instagramMaxDurationSec &&
        fileSizeBytes <= instagramMaxFileSizeBytes;
  }

  static bool isXEligible({
    required double durationSec,
    required int fileSizeBytes,
    required String contentType,
  }) {
    return contentType == xAllowedContentType &&
        durationSec >= xMinDurationSec &&
        durationSec <= xMaxDurationSec &&
        fileSizeBytes <= xMaxFileSizeBytes;
  }

  /// Instagramでチェック不可の場合の理由文言(`null` はチェック可)。
  /// design.md「日本語UI文言の方針」準拠(「何が起きたか」を簡潔に1文で)。
  static String? instagramIneligibleReason({
    required double durationSec,
    required int fileSizeBytes,
  }) {
    if (fileSizeBytes > instagramMaxFileSizeBytes) {
      return 'Instagramは300MB以内の動画のみ投稿できます';
    }
    if (durationSec < instagramMinDurationSec ||
        durationSec > instagramMaxDurationSec) {
      return 'Instagramは3秒〜15分以内の動画のみ投稿できます';
    }
    return null;
  }

  /// Xでチェック不可の場合の理由文言(`null` はチェック可)。
  /// コンテナ形式(`contentType`)のチェックを長さ/サイズより優先して判定する
  /// (MOV形式は長さ・サイズに関わらず常に選択不可のため。コードレビュー指摘
  /// 「MOV動画のcontentType不整合」対応)。
  static String? xIneligibleReason({
    required double durationSec,
    required int fileSizeBytes,
    required String contentType,
  }) {
    if (contentType != xAllowedContentType) {
      return 'Xへの投稿はMP4形式の動画のみ対応しています';
    }
    if (fileSizeBytes > xMaxFileSizeBytes) {
      return 'Xは512MB以内の動画のみ投稿できます';
    }
    if (durationSec < xMinDurationSec || durationSec > xMaxDurationSec) {
      return 'Xは140秒以内の動画のみ投稿できます';
    }
    return null;
  }
}
