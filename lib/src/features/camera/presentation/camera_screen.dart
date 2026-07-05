import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera/src/core/constants/app_sizes.dart';
import 'package:flutter_camera/src/core/error/error_mapper.dart';
import 'package:flutter_camera/src/features/camera/domain/camera_capture_mode.dart';
import 'package:flutter_camera/src/features/camera/domain/captured_media_source.dart';
import 'package:flutter_camera/src/features/camera/domain/captured_photo.dart';
import 'package:flutter_camera/src/features/camera/domain/captured_video.dart';
import 'package:flutter_camera/src/features/camera/domain/video_recording_limits.dart';
import 'package:flutter_camera/src/features/camera/presentation/camera_session.dart';
import 'package:flutter_camera/src/features/camera/presentation/camera_session_state.dart';
import 'package:flutter_camera/src/features/camera/presentation/widgets/pattern_carousel.dart';
import 'package:flutter_camera/src/features/onboarding/presentation/first_post_guide_provider.dart';
import 'package:flutter_camera/src/features/onboarding/presentation/widgets/first_post_guide_overlay.dart';
import 'package:flutter_camera/src/routing/app_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// S-04 ホーム/撮影画面(design.md 画面設計・UIフロー章 S-04準拠)。
/// アプリのハブ画面。カメラプレビュー + パターン選択カルーセルで自撮りを撮影する。
class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver {
  bool _isCapturing = false;

  // 動画撮影モード追加分の状態(design.md追補: S-04動画撮影モード)。
  bool _isRecording = false;
  bool _isStoppingRecording = false;
  bool _isSwitchingMode = false;
  Timer? _recordingTicker;
  DateTime? _recordingStartedAt;
  int _elapsedSeconds = 0;

  bool get _isBusy =>
      _isCapturing || _isRecording || _isStoppingRecording || _isSwitchingMode;

  /// シャッターボタン自体の無効化条件。動画撮影中([_isRecording])は「録画停止」
  /// として引き続きタップ可能にする必要があるため、[_isBusy] から除外する
  /// (停止処理中の [_isStoppingRecording] は多重タップ防止のため無効化する)。
  bool get _shutterBusy =>
      _isCapturing || _isStoppingRecording || _isSwitchingMode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recordingTicker?.cancel();
    super.dispose();
  }

  /// camera README掲載パターン(inactiveでdispose、resumedで再初期化)をそのまま踏襲する
  /// (design.md カメラ・自動加工パイプライン設計 §1.4準拠)。
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final notifier = ref.read(cameraSessionProvider.notifier);
    switch (state) {
      case AppLifecycleState.inactive:
        notifier.suspend();
      case AppLifecycleState.resumed:
        notifier.resume();
      default:
        break;
    }
  }

  Future<void> _capturePhoto() async {
    if (_isBusy) return;
    final currentState = ref.read(cameraSessionProvider).value;
    final lens = currentState is CameraSessionReady
        ? currentState.lens
        : CameraLensDirection.front;

    setState(() => _isCapturing = true);
    try {
      final shot = await ref.read(cameraSessionProvider.notifier).capture();
      if (!mounted) return;
      // 遷移先(S-05): `extra: CapturedPhoto`(design.md GoRouterルーティング設計準拠)。
      context.pushNamed(
        AppRoute.editPreview.name,
        extra: CapturedPhoto(
          imagePath: shot.path,
          lensDirection: lens,
          source: CapturedMediaSource.camera,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      final message = ErrorMapper.toUserMessage(error) ?? '撮影に失敗しました。';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  /// 動画撮影モードのシャッター操作: 録画中は停止、そうでなければ開始する
  /// (design.md追補: S-04動画撮影モード「録画開始/停止」)。
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecordingAndProceed();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    if (_isBusy) return;
    try {
      await ref.read(cameraSessionProvider.notifier).startRecording();
    } catch (error) {
      _showErrorSnackBar(error, fallback: '録画を開始できませんでした。');
      return;
    }
    if (!mounted) return;
    _recordingStartedAt = DateTime.now();
    setState(() {
      _isRecording = true;
      _elapsedSeconds = 0;
    });
    _recordingTicker?.cancel();
    _recordingTicker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _onRecordingTick(),
    );
  }

  /// 経過秒数の更新と、140秒到達時の自動停止(design.md追補: S-04動画撮影モード)。
  void _onRecordingTick() {
    final startedAt = _recordingStartedAt;
    if (startedAt == null || !mounted) return;
    final now = DateTime.now();
    setState(
      () => _elapsedSeconds = VideoRecordingLimits.elapsedSeconds(
        startedAt,
        now,
      ),
    );
    if (VideoRecordingLimits.shouldAutoStop(startedAt, now)) {
      unawaited(_stopRecordingAndProceed());
    }
  }

  Future<void> _stopRecordingAndProceed() async {
    _recordingTicker?.cancel();
    _recordingTicker = null;
    _recordingStartedAt = null;
    final currentState = ref.read(cameraSessionProvider).value;
    final lens = currentState is CameraSessionReady
        ? currentState.lens
        : null;

    // `_isRecording` を即falseにすると停止処理中(await中)にシャッターが再度
    // 「録画開始」として押せてしまうため、停止処理中も `_isBusy` を維持する
    // 専用フラグで覆う。
    setState(() {
      _isRecording = false;
      _isStoppingRecording = true;
    });
    try {
      final file = await ref.read(cameraSessionProvider.notifier).stopRecording();
      if (!mounted) return;
      // 遷移先(S-05v): `extra: CapturedVideo`。
      context.pushNamed(
        AppRoute.videoPreview.name,
        extra: CapturedVideo(
          videoPath: file.path,
          lensDirection: lens,
          source: CapturedMediaSource.camera,
        ),
      );
    } catch (error) {
      _showErrorSnackBar(error, fallback: '録画の保存に失敗しました。');
    } finally {
      if (mounted) setState(() => _isStoppingRecording = false);
    }
  }

  /// 写真/動画モード切替(design.md追補: S-04モード切替トグル)。
  Future<void> _switchMode(CameraCaptureMode mode) async {
    if (_isBusy) return;
    final currentState = ref.read(cameraSessionProvider).value;
    if (currentState is! CameraSessionReady || currentState.mode == mode) {
      return;
    }
    setState(() => _isSwitchingMode = true);
    try {
      await ref.read(cameraSessionProvider.notifier).switchMode(mode);
    } catch (error) {
      _showErrorSnackBar(error, fallback: 'モードを切り替えられませんでした。');
    } finally {
      if (mounted) setState(() => _isSwitchingMode = false);
    }
  }

  /// フォトライブラリからの写真・動画取り込み(design.md追補: S-04ギャラリーボタン)。
  /// 写真はS-05(既存の`CapturedPhoto`フロー)へ、動画はS-05vへ遷移する。
  Future<void> _pickFromLibrary() async {
    if (_isBusy) return;
    XFile? file;
    try {
      file = await ImagePicker().pickMedia();
    } catch (error) {
      _showErrorSnackBar(error, fallback: 'ライブラリからの読み込みに失敗しました。');
      return;
    }
    if (file == null || !mounted) return;

    if (_looksLikeVideo(file)) {
      context.pushNamed(
        AppRoute.videoPreview.name,
        extra: CapturedVideo(
          videoPath: file.path,
          source: CapturedMediaSource.library,
        ),
      );
    } else {
      context.pushNamed(
        AppRoute.editPreview.name,
        extra: CapturedPhoto(
          imagePath: file.path,
          source: CapturedMediaSource.library,
        ),
      );
    }
  }

  bool _looksLikeVideo(XFile file) {
    final mimeType = file.mimeType;
    if (mimeType != null) return mimeType.startsWith('video/');
    const videoExtensions = ['.mp4', '.mov', '.m4v', '.avi', '.mkv', '.webm'];
    final lowerPath = file.path.toLowerCase();
    return videoExtensions.any(lowerPath.endsWith);
  }

  void _showErrorSnackBar(Object error, {required String fallback}) {
    if (!mounted) return;
    final message = ErrorMapper.toUserMessage(error) ?? fallback;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openAppSettings() {
    // design.md §1.2「恒久拒否時のOS設定画面への直接遷移はcamera単体では不可」の
    // 対応(coreChangeRequests参照: `app_settings` パッケージの追加が必要)。
    return AppSettings.openAppSettings(type: AppSettingsType.settings);
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(cameraSessionProvider);
    final sessionValue = sessionAsync.value;
    final isReady = sessionValue is CameraSessionReady;
    final mode = sessionValue is CameraSessionReady
        ? sessionValue.mode
        : CameraCaptureMode.photo;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _CameraArea(
            sessionAsync: sessionAsync,
            onRetry: () => ref.read(cameraSessionProvider.notifier).resume(),
            onOpenSettings: _openAppSettings,
          ),
          // ②上部バー(半透明黒スクリム上): 連携設定アイコン(歯車)/投稿履歴アイコン(時計)。
          // Stack(fit: StackFit.expand) は非Positioned子を全画面に引き伸ばし、
          // Row(crossAxisAlignment既定=center)のアイコンが画面縦中央に落ちるため、
          // Positioned で上端に固定する。
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ScrimIconButton(
                      icon: Icons.settings,
                      semanticLabel: 'SNS連携設定',
                      onPressed: () =>
                          context.pushNamed(AppRoute.snsAccounts.name),
                    ),
                    Row(
                      children: [
                        // ③右上: カメラ切替ボタン(イン/アウト)。カメラ未起動時は非表示。
                        if (isReady)
                          _ScrimIconButton(
                            icon: Icons.cameraswitch,
                            semanticLabel: 'カメラ切替',
                            onPressed: () => ref
                                .read(cameraSessionProvider.notifier)
                                .switchCamera(),
                          ),
                        const SizedBox(width: 8),
                        _ScrimIconButton(
                          icon: Icons.access_time,
                          semanticLabel: '投稿履歴',
                          onPressed: () =>
                              context.pushNamed(AppRoute.history.name),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ④下部: パターン選択カルーセル / ⑤中央下: シャッターボタン。
          // プレビュー上のテキスト・UIは不透明度40%の黒スクリム上に置き、
          // コントラスト比を担保する(design.md 画面設計・UIフロー章
          // 「アクセシビリティ配慮」準拠。上部バーと同一の方式)。
          if (isReady)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // カルーセルのラベル・「編集」はスクリム上で白系表示にする
                        // (S-05 から再利用される共通コンポーネント側は変更しない)。
                        Theme(
                          data: Theme.of(context).copyWith(
                            textTheme: Theme.of(context).textTheme.apply(
                              bodyColor: Colors.white,
                              displayColor: Colors.white,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          child: const PatternCarousel(),
                        ),
                        const SizedBox(height: 16),
                        // 動画撮影モード追加分: 録画中は赤表示+経過秒数
                        // (design.md追補: S-04動画撮影モード)。
                        if (_isRecording) ...[
                          _RecordingIndicator(elapsedSeconds: _elapsedSeconds),
                          const SizedBox(height: 8),
                        ],
                        Row(
                          children: [
                            // フォトライブラリ取り込みボタン(シャッター左。
                            // design.md追補: S-04ギャラリーボタン)。
                            Expanded(
                              child: Align(
                                child: _ScrimIconButton(
                                  icon: Icons.photo_library,
                                  semanticLabel: 'ライブラリから選ぶ',
                                  onPressed: _pickFromLibrary,
                                ),
                              ),
                            ),
                            // design.md 第9章「S-04 初回投稿ガイド(コーチマーク)」:
                            // ②「シャッターで撮影」ステップでシャッターボタンをハイライト。
                            FirstPostGuideHighlight(
                              step: FirstPostGuideStep.shutter,
                              child: _ShutterButton(
                                mode: mode,
                                isBusy: _shutterBusy,
                                isRecording: _isRecording,
                                onPressed: mode == CameraCaptureMode.photo
                                    ? _capturePhoto
                                    : _toggleRecording,
                              ),
                            ),
                            // 写真/動画モード切替トグル(design.md追補: S-04モード切替)。
                            Expanded(
                              child: Align(
                                child: _ModeToggle(
                                  mode: mode,
                                  onChanged: _switchMode,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // sequenceDiagram「撮影し選択中パターンを軽量適用(処理中オーバーレイ)」準拠。
          if (_isCapturing) const _ProcessingOverlay(),
          // design.md 第9章「S-04 初回投稿ガイド(コーチマーク)」: Stack最前面に配置。
          const FirstPostGuideOverlay(),
        ],
      ),
    );
  }
}

/// `CameraPreview` の全画面表示(design.md 画面設計・UIフロー章 S-04 主要UI要素①)。
/// `StackFit.expand` の tight constraints をそのまま `CameraPreview` に渡すと
/// 画面比率へ引き伸ばされて歪むため、実プレビュー解像度で包んだうえで
/// `BoxFit.cover` により縦横比を保ったまま全画面へ切り出す。
class _FullScreenCameraPreview extends StatelessWidget {
  const _FullScreenCameraPreview({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;
    if (previewSize == null) return CameraPreview(controller);
    // previewSize はセンサー基準(横長)のため、縦持ちでは縦横を入れ替える。
    final isPortrait =
        MediaQuery.orientationOf(context) == Orientation.portrait;
    final width = isPortrait ? previewSize.height : previewSize.width;
    final height = isPortrait ? previewSize.width : previewSize.height;
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: width,
          height: height,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

class _CameraArea extends StatelessWidget {
  const _CameraArea({
    required this.sessionAsync,
    required this.onRetry,
    required this.onOpenSettings,
  });

  final AsyncValue<CameraSessionState> sessionAsync;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return sessionAsync.when(
      // camera-loading: カメラ初期化中は黒背景+スピナー。
      loading: () =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
      error: (error, stackTrace) => _CameraErrorView(onRetry: onRetry),
      data: (sessionState) => switch (sessionState) {
        CameraSessionReady(:final controller) => _FullScreenCameraPreview(
          controller: controller,
        ),
        CameraSessionSuspended() => const ColoredBox(color: Colors.black),
        CameraSessionPermissionDenied(:final canRetry) => _PermissionDeniedView(
          canRetry: canRetry,
          onRetry: onRetry,
          onOpenSettings: onOpenSettings,
        ),
        CameraSessionRestricted() => const _MessageView(
          message: 'カメラの利用が制限されています。デバイスの設定をご確認ください。',
        ),
        CameraSessionError() => _CameraErrorView(onRetry: onRetry),
      },
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({required this.message, this.actions = const []});

  final String message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography, color: Colors.white70, size: 48),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.center,
                  children: actions,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// permission-denied状態(design.md 画面設計・UIフロー章 S-04「状態」準拠)。
/// `canRetry`(design.md カメラ・自動加工パイプライン設計 §1.2準拠)により
/// 「再試行」ボタンの有無を切り替える。
class _PermissionDeniedView extends StatelessWidget {
  const _PermissionDeniedView({
    required this.canRetry,
    required this.onRetry,
    required this.onOpenSettings,
  });

  final bool canRetry;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return _MessageView(
      message: 'カメラへのアクセスが許可されていません。撮影には許可が必要です。',
      actions: [
        if (canRetry)
          FilledButton(onPressed: onRetry, child: const Text('再試行')),
        OutlinedButton(onPressed: onOpenSettings, child: const Text('設定を開く')),
      ],
    );
  }
}

/// camera-error状態(design.md 画面設計・UIフロー章 S-04「状態」準拠)。
class _CameraErrorView extends StatelessWidget {
  const _CameraErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _MessageView(
      message: 'カメラを起動できませんでした。',
      actions: [FilledButton(onPressed: onRetry, child: const Text('再試行'))],
    );
  }
}

class _ScrimIconButton extends StatelessWidget {
  const _ScrimIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // 不透明度40%の黒スクリムでコントラスト比を担保する
    // (design.md 画面設計・UIフロー章「アクセシビリティ配慮」準拠)。
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        tooltip: semanticLabel,
        onPressed: onPressed,
        constraints: const BoxConstraints(
          minWidth: AppSizes.minTapTarget,
          minHeight: AppSizes.minTapTarget,
        ),
      ),
    );
  }
}

/// シャッターボタン。写真モードは既存の白丸ボタン(撮影)、動画モードは
/// 赤系の録画開始/停止ボタンとして表示を切り替える
/// (design.md追補: S-04動画撮影モード)。
class _ShutterButton extends StatelessWidget {
  const _ShutterButton({
    required this.mode,
    required this.isBusy,
    required this.isRecording,
    required this.onPressed,
  });

  final CameraCaptureMode mode;
  final bool isBusy;
  final bool isRecording;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isVideoMode = mode == CameraCaptureMode.video;
    final label = !isVideoMode ? '撮影' : (isRecording ? '録画停止' : '録画開始');

    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: isBusy ? null : onPressed,
        child: Container(
          width: AppSizes.shutterButtonSize,
          height: AppSizes.shutterButtonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: (isVideoMode ? Colors.red : Colors.white).withValues(
                alpha: 0.6,
              ),
              width: 4,
            ),
          ),
          child: isBusy
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(strokeWidth: 3),
                )
              : (isVideoMode
                    ? Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: isRecording ? 28 : 56,
                          height: isRecording ? 28 : 56,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(
                              isRecording ? 6 : 28,
                            ),
                          ),
                        ),
                      )
                    : null),
        ),
      ),
    );
  }
}

/// 写真/動画モード切替トグル(design.md追補: S-04モード切替トグル)。
class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});

  final CameraCaptureMode mode;
  final ValueChanged<CameraCaptureMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeToggleSegment(
            label: '写真',
            semanticLabel: '写真モード',
            icon: Icons.photo_camera,
            isSelected: mode == CameraCaptureMode.photo,
            onTap: () => onChanged(CameraCaptureMode.photo),
          ),
          _ModeToggleSegment(
            label: '動画',
            semanticLabel: '動画モード',
            icon: Icons.videocam,
            isSelected: mode == CameraCaptureMode.video,
            onTap: () => onChanged(CameraCaptureMode.video),
          ),
        ],
      ),
    );
  }
}

class _ModeToggleSegment extends StatelessWidget {
  const _ModeToggleSegment({
    required this.label,
    required this.semanticLabel,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String semanticLabel;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // アクセシビリティ配慮: 「モード名+選択状態」をselectedフラグ付きで通知
    // (design.md 画面設計・UIフロー章「アクセシビリティ配慮」準拠。
    // パターンカルーセルの選択通知と同一方式)。
    return Semantics(
      button: true,
      selected: isSelected,
      label: isSelected ? '$semanticLabel、選択中' : semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          constraints: const BoxConstraints(
            minWidth: AppSizes.minTapTarget,
            minHeight: AppSizes.minTapTarget,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.9)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.black : Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 録画中インジケータ: 赤丸+経過時間(design.md追補: S-04動画撮影モード
/// 「録画中は赤表示+経過秒数」)。`liveRegion` で経過時間の更新を
/// スクリーンリーダーに通知する(design.md「アクセシビリティ配慮」準拠の
/// 投稿処理モーダルと同様の方式)。
class _RecordingIndicator extends StatelessWidget {
  const _RecordingIndicator({required this.elapsedSeconds});

  final int elapsedSeconds;

  @override
  Widget build(BuildContext context) {
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    final text =
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    return Semantics(
      liveRegion: true,
      label: '録画中、経過時間$text',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _RecordingDot(),
              const SizedBox(width: 6),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordingDot extends StatelessWidget {
  const _RecordingDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
    );
  }
}

class _ProcessingOverlay extends StatelessWidget {
  const _ProcessingOverlay();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0x66000000),
      child: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}
