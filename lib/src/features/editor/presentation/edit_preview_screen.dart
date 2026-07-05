import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_camera/src/common_widgets/app_error_view.dart';
import 'package:flutter_camera/src/common_widgets/confirm_dialog.dart';
import 'package:flutter_camera/src/common_widgets/primary_button.dart';
import 'package:flutter_camera/src/core/error/error_listener.dart';
import 'package:flutter_camera/src/core/error/error_mapper.dart';
import 'package:flutter_camera/src/features/camera/domain/captured_photo.dart';
import 'package:flutter_camera/src/features/camera/presentation/widgets/pattern_carousel.dart';
import 'package:flutter_camera/src/features/editor/data/pro_image_editor_apply_service.dart';
import 'package:flutter_camera/src/features/editor/domain/edited_image.dart';
import 'package:flutter_camera/src/features/editor/presentation/adjust_editor_screen.dart';
import 'package:flutter_camera/src/features/editor/presentation/edit_preview_controller.dart';
import 'package:flutter_camera/src/features/editor/presentation/widgets/lightweight_pattern_preview.dart';
import 'package:flutter_camera/src/features/patterns/domain/pattern.dart';
import 'package:flutter_camera/src/features/patterns/presentation/selected_pattern_provider.dart';
import 'package:flutter_camera/src/features/posting/domain/post_media.dart';
import 'package:flutter_camera/src/routing/app_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S-05 加工プレビュー画面(design.md 画面設計・UIフロー章準拠)。
///
/// パターン適用結果の確認・パターンの差し替え・微調整・投稿フローへの確定を行う。
/// パターンカルーセルはS-04と同一コンポーネント([PatternCarousel]、camera
/// フィーチャー実装済み)を再利用し、選択状態(`selectedPatternProvider`)の変化を
/// [ref.listen] で捕捉して [EditPreviewController.reapplyPattern] を呼び出す
/// (design.md カメラ・自動加工パイプライン設計 §3.1準拠)。
///
/// NOTE(coreChangeRequests参照): 解決済みriverpod(3.2.1)では
/// `AsyncValue.copyWithPrevious` が `@internal` のため、パターン再適用/最終確定の
/// 「処理中」表示はコントローラの `AsyncValue` ではなく本画面のローカル状態
/// (`_isReapplyingPattern` / `_isConfirming`)で管理し、失敗時のSnackBarも
/// このローカルcatchで明示的に表示する(`listenAppError` は初回ビルド失敗のみ対象)。
class EditPreviewScreen extends ConsumerStatefulWidget {
  const EditPreviewScreen({super.key, required this.capturedPhoto});

  final CapturedPhoto capturedPhoto;

  @override
  ConsumerState<EditPreviewScreen> createState() => _EditPreviewScreenState();
}

class _EditPreviewScreenState extends ConsumerState<EditPreviewScreen> {
  bool _isReapplyingPattern = false;
  bool _isConfirming = false;

  @override
  Widget build(BuildContext context) {
    final controllerProvider = editPreviewControllerProvider(
      widget.capturedPhoto,
    );
    final asyncEditedImage = ref.watch(controllerProvider);
    ref.listenAppError(controllerProvider, context);

    // パターンカルーセル(PatternCarousel、S-04と共通)がselectedPatternProviderを
    // 直接書き換えるため、その変化を捕捉して軽量プレビューの再適用(アセットprecache)を
    // トリガーする(design.md §3.1「パターン差し替え」)。
    ref.listen<Pattern?>(selectedPatternProvider, (previous, next) {
      if (previous == next) return;
      _reapplyPattern(next);
    });

    final selectedPattern = ref.watch(selectedPatternProvider);
    final controlsDisabled =
        asyncEditedImage.isLoading || _isReapplyingPattern || _isConfirming;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _confirmDiscardAndLeave();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('加工プレビュー')),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: _buildPreviewArea(asyncEditedImage, selectedPattern),
              ),
              IgnorePointer(
                ignoring: controlsDisabled,
                child: const PatternCarousel(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: controlsDisabled
                            ? null
                            : () => _openAdjustEditor(selectedPattern),
                        child: const Text('微調整'),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: controlsDisabled
                            ? null
                            : _confirmDiscardAndLeave,
                        child: const Text('撮り直す'),
                      ),
                    ),
                    Expanded(
                      child: PrimaryButton(
                        label: '次へ',
                        isLoading: _isConfirming,
                        onPressed:
                            (controlsDisabled || !asyncEditedImage.hasValue)
                            ? null
                            : () => _confirmAndProceed(selectedPattern),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// [AsyncValue.hasValue] は初回ビルドが完了した後は基本的に `true` のまま維持される
  /// (パターン再適用・最終確定の失敗時も `state` を書き換えない設計。
  /// [EditPreviewController] のNOTE参照)。「processing」中の半透明オーバーレイは
  /// ローカル状態 [_isReapplyingPattern] で表示する(design.md S-05状態表準拠)。
  Widget _buildPreviewArea(
    AsyncValue<EditedImage> asyncEditedImage,
    Pattern? selectedPattern,
  ) {
    if (asyncEditedImage.hasValue) {
      final value = asyncEditedImage.value!;
      return Stack(
        alignment: Alignment.center,
        children: [
          LightweightPatternPreview(
            imageFile: File(value.filePath),
            pattern: selectedPattern,
            service: ref.watch(patternApplyServiceProvider),
            aspectRatio: 4 / 5,
          ),
          if (asyncEditedImage.isLoading || _isReapplyingPattern)
            const ColoredBox(
              color: Color(0x66000000),
              child: SizedBox.expand(
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      );
    }
    if (asyncEditedImage.hasError) {
      return AppErrorView(
        message:
            ErrorMapper.toUserMessage(asyncEditedImage.error!) ??
            '画像の加工に失敗しました。',
        onRetry: () =>
            ref.invalidate(editPreviewControllerProvider(widget.capturedPhoto)),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  Future<void> _reapplyPattern(Pattern? pattern) async {
    setState(() => _isReapplyingPattern = true);
    try {
      final controllerProvider = editPreviewControllerProvider(
        widget.capturedPhoto,
      );
      await ref.read(controllerProvider.notifier).reapplyPattern(pattern);
    } catch (error) {
      _showErrorSnackBar(error);
    } finally {
      if (mounted) setState(() => _isReapplyingPattern = false);
    }
  }

  Future<void> _openAdjustEditor(Pattern? pattern) async {
    final controllerProvider = editPreviewControllerProvider(
      widget.capturedPhoto,
    );
    final notifier = ref.read(controllerProvider.notifier);
    final service = ref.read(patternApplyServiceProvider);
    // NOTE(coreChangeRequests参照): 解決済みriverpodは3.2.1(pubspec.yamlのNOTE準拠)で
    // `AsyncValue.valueOrNull` が存在しないため `.value`(nullable getter)を使用する。
    final normalizedFilePath = ref.read(controllerProvider).value?.filePath;
    if (normalizedFilePath == null) return;

    final Map<String, dynamic> importMap;
    try {
      importMap = await notifier.prepareAdjustEditor(pattern);
    } catch (error) {
      _showErrorSnackBar(error);
      return;
    }
    // ProImageEditorの座標系は正規化後画像の実寸px(design.md §4.2)。
    final imgSize = importMap['imgSize'] as Map<String, dynamic>?;
    final width = (imgSize?['width'] as num?)?.toDouble() ?? 1080;
    final height = (imgSize?['height'] as num?)?.toDouble() ?? 1350;

    if (!mounted) return;
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AdjustEditorScreen(
          normalizedImagePath: normalizedFilePath,
          importStateHistoryMap: importMap,
          widgetLoader: service.buildLayerWidgetLoader(
            canvasWidth: width,
            canvasHeight: height,
          ),
          onEditingComplete: (bytes, exportedMap) {
            notifier.onAdjustEditingComplete(
              pattern: pattern,
              jpegBytes: bytes,
              exportedStateHistoryMap: exportedMap,
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDiscardAndLeave() async {
    final confirmed = await showConfirmDialog(
      context,
      title: '撮影に戻りますか?',
      message: '編集内容を破棄して撮影に戻りますか?',
      confirmLabel: '破棄する',
      isDestructive: true,
    );
    if (confirmed && mounted) {
      context.go(AppRoute.home.path);
    }
  }

  Future<void> _confirmAndProceed(Pattern? pattern) async {
    final confirmed = await showConfirmDialog(
      context,
      title: '投稿フローへ進みますか?',
      message: '加工を確定してSNS投稿画面へ進みます。よろしいですか?',
      confirmLabel: '次へ',
    );
    if (!confirmed || !mounted) return;

    final controllerProvider = editPreviewControllerProvider(
      widget.capturedPhoto,
    );
    setState(() => _isConfirming = true);
    try {
      final edited = await ref
          .read(controllerProvider.notifier)
          .confirm(pattern);
      if (mounted) {
        context.pushNamed(
          AppRoute.postCompose.name,
          extra: PostMedia.image(edited),
        );
      }
    } catch (error) {
      _showErrorSnackBar(error);
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  void _showErrorSnackBar(Object error) {
    final message = ErrorMapper.toUserMessage(error);
    if (message == null || !mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
