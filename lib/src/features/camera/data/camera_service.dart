import 'package:camera/camera.dart';
import 'package:flutter/services.dart' show DeviceOrientation;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'camera_service.g.dart';

/// `camera` プラグインのラッパ(design.md アプリアーキテクチャ設計 ディレクトリ構造
/// 「camera/data/camera_service.dart: cameraプラグインのラッパ」準拠)。
///
/// presentation層の `CameraSession` は本インターフェース経由でのみプラグインを操作する
/// (design.md アプリアーキテクチャ設計「レイヤー責務と依存方向」: dataは外部SDKラッパを置く層)。
/// これにより `CameraSession` のロジック(前後カメラ選択・エラー分岐・suspend/resume)を
/// mocktail でユニットテスト可能にする。
abstract interface class CameraService {
  /// [ResolutionPreset.veryHigh] で初期化し、縦向きに固定する
  /// (design.md カメラ・自動加工パイプライン設計 §1.3準拠)。
  /// 静止画のみのため `enableAudio: false` とし、マイク権限ダイアログは表示させない。
  Future<CameraController> initialize(CameraDescription description);

  /// 動画撮影モード用の初期化。[ResolutionPreset.high](「HD」相当・~720p。
  /// `hd` という定数は存在しないため実装側で最も近い定数を使用する)・
  /// `enableAudio: true` で初期化し、縦向きに固定する(動画撮影モード追加分。
  /// 写真モードの [initialize] は変更しない)。
  Future<CameraController> initializeForVideo(CameraDescription description);

  /// フロント/バック切替。controllerを維持したまま `setDescription` を使う
  /// (design.md §1.3準拠。公式API)。
  Future<void> setDescription(
    CameraController controller,
    CameraDescription description,
  );

  /// JPEG一時ファイルを返す(design.md §1.3準拠)。
  Future<XFile> takePicture(CameraController controller);

  /// 動画録画を開始する(動画撮影モード追加分。`camera` パッケージ公式API)。
  Future<void> startVideoRecording(CameraController controller);

  /// 動画録画を停止し、動画一時ファイルを返す(動画撮影モード追加分)。
  Future<XFile> stopVideoRecording(CameraController controller);

  Future<void> dispose(CameraController controller);
}

class CameraServiceImpl implements CameraService {
  const CameraServiceImpl();

  @override
  Future<CameraController> initialize(CameraDescription description) async {
    final controller = CameraController(
      description,
      ResolutionPreset.veryHigh,
      enableAudio: false,
    );
    try {
      await controller.initialize();
      await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
      return controller;
    } catch (_) {
      // 初期化失敗時は取得済みリソースを解放してから呼び出し元へ再送出する
      // (design.md §1.3準拠: `on CameraException catch (e) { await controller.dispose(); ... }`)。
      await controller.dispose();
      rethrow;
    }
  }

  @override
  Future<CameraController> initializeForVideo(
    CameraDescription description,
  ) async {
    // NOTE: `camera` パッケージの `ResolutionPreset` に `hd` という定数は存在しない
    // (camera_platform_interface実ソースで確認済み。low/medium/high/veryHigh/
    // ultraHigh/max のみ)。「HD」相当(~720p)に該当する `high` を使用する。
    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: true,
    );
    try {
      await controller.initialize();
      await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
      return controller;
    } catch (_) {
      await controller.dispose();
      rethrow;
    }
  }

  @override
  Future<void> setDescription(
    CameraController controller,
    CameraDescription description,
  ) {
    return controller.setDescription(description);
  }

  @override
  Future<XFile> takePicture(CameraController controller) {
    return controller.takePicture();
  }

  @override
  Future<void> startVideoRecording(CameraController controller) {
    return controller.startVideoRecording();
  }

  @override
  Future<XFile> stopVideoRecording(CameraController controller) {
    return controller.stopVideoRecording();
  }

  @override
  Future<void> dispose(CameraController controller) {
    return controller.dispose();
  }
}

@Riverpod(keepAlive: true)
CameraService cameraService(Ref ref) => const CameraServiceImpl();
