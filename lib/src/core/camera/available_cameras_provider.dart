import 'package:camera/camera.dart' as camera_plugin;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'available_cameras_provider.g.dart';

/// 端末カメラの列挙(design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計
/// 「availableCamerasProvider」準拠。デバイス構成は起動中不変のため keepAlive とする)。
///
/// 関数名を `availableCameras` にすると `camera_plugin.availableCameras()` と
/// 名前衝突するため prefix import が必須(camera feature からの想定利用箇所準拠)。
@Riverpod(keepAlive: true)
Future<List<camera_plugin.CameraDescription>> availableCameras(Ref ref) {
  return camera_plugin.availableCameras();
}
