import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/features/camera/data/camera_service.dart';
import 'package:flutter_camera/src/features/camera/domain/camera_capture_mode.dart';
import 'package:flutter_camera/src/features/camera/presentation/camera_session_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// NOTE(coreChangeRequests参照): `availableCamerasProvider` は design.md アプリアーキテクチャ設計
// プロバイダー設計表で「architecture担当定義のkeepAliveプロバイダー」とされているが、
// 2026-07-04時点で lib/src/core/ 配下に未実装のため、想定パスを暫定でimportしている。
// core側での追加が完了するまで本ファイルはコンパイルできない(coreChangeRequests参照)。
import 'package:flutter_camera/src/core/camera/available_cameras_provider.dart';

part 'camera_session.g.dart';

/// カメラ撮影のライフサイクル管理(design.md カメラ・自動加工パイプライン設計 §1準拠)。
///
/// `CameraController` は本Notifierが単独所有し、widget側で直接生成・破棄しない
/// (design.md §1.3準拠)。autoDispose のため、S-04(`CameraScreen`)がpopされ
/// 誰も watch しなくなった時点で `ref.onDispose` が走りコントローラを解放する。
@riverpod
class CameraSession extends _$CameraSession {
  CameraController? _controller;
  CameraDescription? _current;

  /// 現在の撮影モード(動画撮影モード追加分)。suspend/resume・カメラ切替をまたいで
  /// 維持する(`_current` と同様の扱い)。
  CameraCaptureMode _mode = CameraCaptureMode.photo;

  @override
  Future<CameraSessionState> build() async {
    // Riverpod 3.0はonDispose内での`ref.read`を禁止する
    // (`_debugCallbackStack == 0`アサーション)ため、cameraServiceProvider
    // (keepAlive)の参照はコールバック登録前に取得しておく。
    final service = ref.read(cameraServiceProvider);
    ref.onDispose(() {
      final controller = _controller;
      _controller = null;
      _current = null;
      if (controller != null) {
        // dispose自体は非同期だがonDispose内では待たない(design.md §1.3の
        // `ref.onDispose(() { _controller?.dispose(); ... })` に準拠する同期呼び出し)。
        unawaited(service.dispose(controller));
      }
    });
    return _initialize(preferFront: true);
  }

  /// [mode] は動画撮影モード追加分。既定の `photo` では既存の [CameraService.initialize]
  /// をそのまま呼ぶため、既存呼び出し箇所(`build`・`switchCamera`・`resume`)の挙動は
  /// 変更しない。
  Future<CameraSessionState> _initialize({
    required bool preferFront,
    CameraCaptureMode mode = CameraCaptureMode.photo,
  }) async {
    // カメラ列挙は availableCamerasProvider(architecture担当定義、keepAlive)経由に一本化し、
    // 本Notifier内で `availableCameras()` を直接呼ばない(design.md §1.3準拠)。
    final cameras = await ref.read(availableCamerasProvider.future);
    if (cameras.isEmpty) {
      // design.md §1.2の分岐表には無いが、カメラ非搭載端末でのクラッシュ
      // (`Iterable.first` on empty list)を防ぐためのガード。
      return const CameraSessionState.error('no_camera_available');
    }
    final desc = cameras.firstWhere(
      (c) =>
          c.lensDirection ==
          (preferFront ? CameraLensDirection.front : CameraLensDirection.back),
      orElse: () => cameras.first,
    );
    final service = ref.read(cameraServiceProvider);
    try {
      final controller = mode == CameraCaptureMode.video
          ? await service.initializeForVideo(desc)
          : await service.initialize(desc);
      _controller = controller;
      _current = desc;
      _mode = mode;
      return CameraSessionState.ready(
        controller: controller,
        lens: desc.lensDirection,
        mode: mode,
      );
    } on CameraException catch (e) {
      return _mapCameraException(e);
    }
  }

  /// フロント/バック切替: controllerを維持したまま `setDescription` を使う
  /// (design.md §1.3準拠。失敗時のみ dispose→再生成にフォールバック)。
  Future<void> switchCamera() async {
    final current = _controller;
    final currentDesc = _current;
    if (current == null || currentDesc == null) return;

    final cameras = await ref.read(availableCamerasProvider.future);
    final next = cameras.firstWhere(
      (c) => c.lensDirection != currentDesc.lensDirection,
      orElse: () => currentDesc,
    );
    // orElse は候補が無い場合に currentDesc をそのまま返す(= 切替先が無い)。
    if (identical(next, currentDesc)) return;

    final service = ref.read(cameraServiceProvider);
    try {
      await service.setDescription(current, next);
      _current = next;
      state = AsyncData(
        CameraSessionState.ready(
          controller: current,
          lens: next.lensDirection,
          mode: _mode,
        ),
      );
    } on CameraException {
      // フォールバック: 再生成(design.md §1.3準拠)。
      // switchMode() と同じ理由で、dispose前にAsyncLoadingへ遷移させ、
      // 破棄済みcontrollerがCameraPreviewから参照されないようにする。
      _controller = null;
      state = const AsyncLoading();
      await service.dispose(current);
      state = AsyncData(
        await _initialize(
          preferFront: next.lensDirection == CameraLensDirection.front,
          mode: _mode,
        ),
      );
    }
  }

  /// 写真/動画モード切替(design.md追補: S-04モード切替トグル)。
  /// controllerを維持したまま切替可能な `setDescription` と異なり、モード切替は
  /// `enableAudio`/解像度プリセットが異なるため controller の dispose→再生成が必要。
  /// 切替先が同じモードの場合は何もしない。切替前のレンズ向きは維持する。
  Future<void> switchMode(CameraCaptureMode mode) async {
    if (mode == _mode) return;
    final current = _controller;
    final currentDesc = _current;
    if (current == null || currentDesc == null) return;

    final service = ref.read(cameraServiceProvider);
    // dispose〜再初期化完了の間にリビルドが起きると、CameraPreviewが破棄済み
    // controllerを参照して再構築される(debugではChangeNotifierのassert違反、
    // releaseではプレビューのフリーズ/黒画面)。これを防ぐため、dispose前に
    // controllerを伴わない状態(AsyncLoading)へ遷移させてから破棄する。
    _controller = null;
    state = const AsyncLoading();
    await service.dispose(current);
    state = AsyncData(
      await _initialize(
        preferFront: currentDesc.lensDirection == CameraLensDirection.front,
        mode: mode,
      ),
    );
  }

  /// AppLifecycle: inactiveで解放(design.md §1.4、camera README掲載パターン準拠)。
  Future<void> suspend() async {
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      await ref.read(cameraServiceProvider).dispose(controller);
    }
    state = const AsyncData(CameraSessionState.suspended());
  }

  /// AppLifecycle: resumedで直前のlensDirectionにより再初期化(design.md §1.4準拠)。
  Future<void> resume() async {
    if (_controller != null) return;
    state = AsyncData(
      await _initialize(
        preferFront: _current?.lensDirection != CameraLensDirection.back,
        mode: _mode,
      ),
    );
  }

  /// 撮影(design.md §1.3準拠。JPEG一時ファイルを返す)。
  ///
  /// SDK例外は data 層(`CameraServiceImpl`)からthrowされた `CameraException` を
  /// `CameraAccessException` に変換して再throwする
  /// (design.md アプリアーキテクチャ設計「エラーハンドリング方針」準拠:
  /// Repository/ServiceのI/O失敗はAppExceptionへ変換してthrowし `AsyncValue.error` に
  /// 載せず、呼び出し元(S-04)がSnackBar等で表示する)。
  Future<XFile> capture() async {
    final controller = _controller;
    if (controller == null) {
      throw const CameraAccessException(
        'capture() called while camera controller is not ready',
      );
    }
    try {
      return await ref.read(cameraServiceProvider).takePicture(controller);
    } on CameraException catch (e) {
      throw CameraAccessException(e.description ?? e.code);
    }
  }

  /// 動画録画開始(design.md追補: S-04動画撮影モード)。[capture] と同様、
  /// SDK例外は `CameraAccessException` へ変換して再throwする。
  Future<void> startRecording() async {
    final controller = _controller;
    if (controller == null) {
      throw const CameraAccessException(
        'startRecording() called while camera controller is not ready',
      );
    }
    try {
      await ref.read(cameraServiceProvider).startVideoRecording(controller);
    } on CameraException catch (e) {
      throw CameraAccessException(e.description ?? e.code);
    }
  }

  /// 動画録画停止(design.md追補: S-04動画撮影モード)。動画一時ファイルを返す。
  Future<XFile> stopRecording() async {
    final controller = _controller;
    if (controller == null) {
      throw const CameraAccessException(
        'stopRecording() called while camera controller is not ready',
      );
    }
    try {
      return await ref.read(cameraServiceProvider).stopVideoRecording(controller);
    } on CameraException catch (e) {
      throw CameraAccessException(e.description ?? e.code);
    }
  }

  /// design.md §1.2「権限リクエストフロー」の分岐表準拠。
  CameraSessionState _mapCameraException(CameraException e) {
    return switch (e.code) {
      'CameraAccessDenied' => const CameraSessionState.permissionDenied(
        canRetry: true,
      ),
      'CameraAccessDeniedWithoutPrompt' =>
        const CameraSessionState.permissionDenied(canRetry: false),
      'CameraAccessRestricted' => const CameraSessionState.restricted(),
      _ => CameraSessionState.error(e.code),
    };
  }
}
