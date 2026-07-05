import 'package:flutter_camera/src/features/editor/domain/edited_image.dart';
import 'package:flutter_camera/src/features/posting/domain/video_content_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_media.freezed.dart';

/// S-07 SNS投稿画面(`PostComposeScreen`)への入力契約。
///
/// 画像(S-05で加工確定した [EditedImage])・動画(S-05vで再生確認した動画)の
/// いずれも受け付けるためのsealed union。動画は加工パイプライン(editor機能)の
/// 対象外(v1では動画加工非対応)のため、[EditedImage] を流用せず動画ファイルの
/// パス・長さ・サイズのみを保持する専用バリアントとして表現する
/// (既存の画像フロー・`EditedImage` の契約は変更しない)。
@freezed
sealed class PostMedia with _$PostMedia {
  const factory PostMedia.image(EditedImage editedImage) = PostMediaImage;

  const factory PostMedia.video({
    /// 動画ファイルの一時パス(S-05v表示に使用したものと同一)。
    required String filePath,

    /// 動画の長さ(秒。小数可。X投稿先バリデーションが0.5秒単位の下限を
    /// 持つため `double` とする)。
    required double durationSec,

    /// 動画ファイルのバイト数(IG/X投稿先バリデーションに使用)。
    required int fileSizeBytes,

    /// 動画ファイルの実コンテナ形式に対応するStorage `contentType`
    /// (`video/mp4` | `video/quicktime`)。ファイル拡張子から
    /// [VideoContentType.fromFilePath] で判定した値をそのまま保持し、
    /// アップロード時のcontentType申告・Xターゲットのゲーティング
    /// (`VideoTargetRules`)双方で使用する(コードレビュー指摘
    /// 「MOV動画のcontentType不整合」対応)。
    required String contentType,
  }) = PostMediaVideo;
}
