import 'package:camera/camera.dart';
import 'package:flutter_camera/src/features/camera/domain/captured_media_source.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'captured_video.freezed.dart';

/// 動画撮影/フォトライブラリからの動画選択結果。
///
/// S-04(撮影・動画モード/ギャラリー取り込み)→S-05v(動画プレビュー画面)へ
/// GoRouter の `extra` として受け渡す(`captured_photo.dart` と同一方式。
/// `extra` が null の場合は routing 側の `redirect` で `/home` へ戻す)。
///
/// 動画加工(パターン適用等)はv1対象外のため、[EditPreviewController] のような
/// 正規化・パターン適用パイプラインを経由せず、S-05vは本モデルの [videoPath] を
/// そのまま `video_player` で再生確認するのみ。長さ([Duration])・ファイルサイズは
/// S-05vが `video_player`/ファイルシステムから取得したうえで
/// `PostMedia.video` を構築する(撮影時点では未確定のため本モデルには含めない)。
@freezed
abstract class CapturedVideo with _$CapturedVideo {
  const factory CapturedVideo({
    /// `CameraSession.stopRecording()` が返す動画一時ファイルのパス、
    /// またはフォトライブラリから選択した動画のパス。
    required String videoPath,

    /// 撮影時に選択されていたレンズ向き(フロント/バック)。フォトライブラリ由来の
    /// 場合は該当する概念が無いため `null`。
    CameraLensDirection? lensDirection,

    /// カメラ撮影/フォトライブラリ選択のいずれに由来するか(既定はカメラ撮影)。
    @Default(CapturedMediaSource.camera) CapturedMediaSource source,
  }) = _CapturedVideo;
}
