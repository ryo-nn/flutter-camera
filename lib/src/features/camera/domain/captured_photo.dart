import 'package:camera/camera.dart';
import 'package:flutter_camera/src/features/camera/domain/captured_media_source.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'captured_photo.freezed.dart';

/// 撮影結果(design.md アプリアーキテクチャ設計 ディレクトリ構造
/// 「camera/domain/captured_photo.dart: 撮影結果(一時ファイルパス・レンズ向き)」準拠)。
///
/// S-04(撮影)→S-05(加工プレビュー)へ GoRouter の `extra` として受け渡す
/// (design.md 画面設計・UIフロー章「GoRouterルーティング設計」準拠。
/// `extra` が null の場合は routing 側の `redirect` で `/home` へ戻す)。
///
/// フォトライブラリ取り込み機能の追加により、[source] が `library` の場合は
/// [lensDirection] を持たない(フロントカメラ前提のミラー処理等はカメラ撮影時のみ適用する)。
@freezed
abstract class CapturedPhoto with _$CapturedPhoto {
  const factory CapturedPhoto({
    /// `CameraSession.capture()`(= `CameraController.takePicture()`)が返す
    /// JPEG一時ファイルのパス、またはフォトライブラリから選択した画像のパス。
    required String imagePath,

    /// 撮影時に選択されていたレンズ向き(フロント/バック)。フォトライブラリ由来の
    /// 場合は該当する概念が無いため `null`。
    CameraLensDirection? lensDirection,

    /// カメラ撮影/フォトライブラリ選択のいずれに由来するか(既定はカメラ撮影)。
    @Default(CapturedMediaSource.camera) CapturedMediaSource source,
  }) = _CapturedPhoto;
}
