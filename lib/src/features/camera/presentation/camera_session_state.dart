import 'package:camera/camera.dart';
import 'package:flutter_camera/src/features/camera/domain/camera_capture_mode.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'camera_session_state.freezed.dart';

/// カメラ撮影のライフサイクル状態機械(design.md カメラ・自動加工パイプライン設計
/// §1.2「権限リクエストフロー」・§1.3「初期化・カメラ切替・dispose」準拠)。
///
/// `CameraException.code` の分岐結果をそのまま状態として保持し、S-04(`CameraScreen`)は
/// この値に応じて表示を切り替える(design.md 画面設計・UIフロー章 S-04「状態」準拠)。
@freezed
sealed class CameraSessionState with _$CameraSessionState {
  /// カメラ初期化成功。プレビュー表示・撮影が可能な状態。
  ///
  /// [mode] は動画撮影モード追加分(S-04写真/動画モード切替トグル準拠)。
  /// 既定は `photo` のため、動画モードを扱わない既存コードとの互換性を維持する。
  const factory CameraSessionState.ready({
    required CameraController controller,
    required CameraLensDirection lens,
    @Default(CameraCaptureMode.photo) CameraCaptureMode mode,
  }) = CameraSessionReady;

  /// AppLifecycleState.inactive によりコントローラを解放した状態
  /// (design.md §1.4準拠。resumed で再初期化される)。
  const factory CameraSessionState.suspended() = CameraSessionSuspended;

  /// `CameraAccessDenied`(canRetry: true、再`initialize()`可能)/
  /// `CameraAccessDeniedWithoutPrompt`(iOSのみ。canRetry: false、OS設定への案内が必要)
  /// (design.md §1.2 表準拠)。
  const factory CameraSessionState.permissionDenied({required bool canRetry}) =
      CameraSessionPermissionDenied;

  /// `CameraAccessRestricted`(iOSのみ。ペアレンタルコントロール等。再試行不可)
  /// (design.md §1.2 表準拠)。
  const factory CameraSessionState.restricted() = CameraSessionRestricted;

  /// 上記以外の初期化失敗等(design.md §1.2 表準拠)。`code` は `CameraException.code`
  /// または本実装が定義する追加コード(例: 'no_camera_available')。
  const factory CameraSessionState.error(String code) = CameraSessionError;
}
