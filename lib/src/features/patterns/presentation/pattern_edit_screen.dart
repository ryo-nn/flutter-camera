import 'package:flutter/material.dart';
import 'package:flutter_camera/src/common_widgets/app_error_view.dart';
import 'package:flutter_camera/src/common_widgets/confirm_dialog.dart';
import 'package:flutter_camera/src/common_widgets/primary_button.dart';
import 'package:flutter_camera/src/core/error/error_listener.dart';
import 'package:flutter_camera/src/core/error/error_mapper.dart';
import 'package:flutter_camera/src/features/patterns/data/firestore_pattern_repository.dart';
import 'package:flutter_camera/src/features/patterns/domain/filter_params.dart';
import 'package:flutter_camera/src/features/patterns/domain/pattern.dart';
import 'package:flutter_camera/src/features/patterns/domain/pattern_repository.dart';
import 'package:flutter_camera/src/features/patterns/domain/stamp_layer.dart';
import 'package:flutter_camera/src/features/patterns/presentation/pattern_edit_controller.dart';
import 'package:flutter_camera/src/features/patterns/presentation/widgets/filter_param_sliders.dart';
import 'package:flutter_camera/src/features/patterns/presentation/widgets/frame_picker.dart';
import 'package:flutter_camera/src/features/patterns/presentation/widgets/pattern_preview.dart';
import 'package:flutter_camera/src/features/patterns/presentation/widgets/stamp_asset_grid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S-06a パターン編集画面(新規作成/編集共用)。
/// (design.md 画面設計・UIフロー章 S-06a準拠)
///
/// `patternId == null` は新規作成(S-06の「複製」導線からは
/// `patternDuplicateSourceProvider` 経由でプリセットの初期値を受け取る)、
/// 非nullは既存マイパターンの編集を表す(プリセットは複製経由でのみ本画面を開く)。
class PatternEditScreen extends ConsumerStatefulWidget {
  const PatternEditScreen({super.key, this.patternId});

  final String? patternId;

  @override
  ConsumerState<PatternEditScreen> createState() => _PatternEditScreenState();
}

class _PatternEditScreenState extends ConsumerState<PatternEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();

  FilterParams _filterParams = const FilterParams();
  String? _frameAssetId;
  List<StampLayer> _stampLayers = const [];
  int? _selectedStampIndex;

  bool _initialized = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    if (widget.patternId == null) {
      // S-06「複製」導線: プリセットの初期値をロードして即座にクリアする
      // (design.md 画面設計・UIフロー章 S-06「複製 → S-06a(プリセット内容を
      // 初期値とした新規作成)」準拠。配置の詳細はnotes参照)。
      final source = ref.read(patternDuplicateSourceProvider);
      if (source != null) {
        _nameController.text = source.name;
        _filterParams = source.filterParams;
        _frameAssetId = source.frameAssetId;
        _stampLayers = source.stampLayers;
        ref.read(patternDuplicateSourceProvider.notifier).clear();
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<bool> _confirmDiscardIfNeeded() async {
    if (!_hasChanges) return true;
    return showConfirmDialog(
      context,
      title: '編集内容を破棄しますか?',
      message: '編集内容を破棄して撮影に戻りますか?',
      confirmLabel: '破棄する',
      isDestructive: true,
    );
  }

  Future<void> _handleBack() async {
    final confirmed = await _confirmDiscardIfNeeded();
    if (confirmed && mounted) context.pop();
  }

  Future<void> _handleSave() async {
    // design.md 画面設計・UIフロー章「アクセシビリティ配慮」:
    // 「エラー発生時は先頭のエラーフィールドへフォーカス移動する」準拠。
    if (!(_formKey.currentState?.validate() ?? false)) {
      _nameFocusNode.requestFocus();
      return;
    }

    final controller = ref.read(
      patternEditControllerProvider(widget.patternId).notifier,
    );
    await controller.save(
      name: _nameController.text.trim(),
      filterParams: _filterParams,
      frameAssetId: _frameAssetId,
      stampLayers: _stampLayers,
    );

    if (!mounted) return;
    final result = ref.read(patternEditControllerProvider(widget.patternId));
    if (result.hasError) return; // エラーは下記のlistenAppErrorでSnackBar表示済み
    _hasChanges = false;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('パターンを保存しました')));
    context.pop();
  }

  void _addStamp(String assetId) {
    if (_stampLayers.length >= StampLayerLimits.maxLayers) return;
    setState(() {
      _stampLayers = [
        ..._stampLayers,
        StampLayer(assetId: assetId, cx: 0.5, cy: 0.5, widthRatio: 0.3),
      ];
      _selectedStampIndex = _stampLayers.length - 1;
    });
    _markChanged();
  }

  void _removeSelectedStamp() {
    final index = _selectedStampIndex;
    if (index == null) return;
    setState(() {
      _stampLayers = [..._stampLayers]..removeAt(index);
      _selectedStampIndex = null;
    });
    _markChanged();
  }

  @override
  Widget build(BuildContext context) {
    ref.listenAppError(
      patternEditControllerProvider(widget.patternId),
      context,
    );

    if (widget.patternId != null && !_initialized) {
      final patternAsync = ref.watch(patternByIdProvider(widget.patternId!));
      return Scaffold(
        appBar: AppBar(title: const Text('パターンを編集')),
        body: patternAsync.when(
          data: (pattern) {
            // ビルド後に初期値を反映する(build中のsetState呼び出しを避けるため
            // フレーム終了後にスケジュールする)。
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || _initialized) return;
              setState(() {
                _nameController.text = pattern.name;
                _filterParams = pattern.filterParams;
                _frameAssetId = pattern.frameAssetId;
                _stampLayers = pattern.stampLayers;
                _initialized = true;
              });
            });
            return const Center(child: CircularProgressIndicator());
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => AppErrorView(
            message: ErrorMapper.toUserMessage(error) ?? '読み込みに失敗しました。',
            onRetry: () =>
                ref.invalidate(patternByIdProvider(widget.patternId!)),
          ),
        ),
      );
    }

    final saveState = ref.watch(
      patternEditControllerProvider(widget.patternId),
    );

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.patternId == null ? 'パターンを作る' : 'パターンを編集'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: '戻る',
            onPressed: _handleBack,
          ),
        ),
        body: Form(
          key: _formKey,
          onChanged: _markChanged,
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: PatternPreview(
                    filterParams: _filterParams,
                    frameAssetId: _frameAssetId,
                    stampLayers: _stampLayers,
                    selectedStampIndex: _selectedStampIndex,
                    onSelectStamp: (index) =>
                        setState(() => _selectedStampIndex = index),
                    onStampLayersChanged: (layers) {
                      setState(() => _stampLayers = layers);
                      _markChanged();
                    },
                  ),
                ),
                if (_selectedStampIndex != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _removeSelectedStamp,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('選択中のスタンプを削除'),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    maxLength: PatternNameLimits.maxLength,
                    decoration: const InputDecoration(labelText: 'パターン名'),
                    validator: patternNameValidationError,
                  ),
                ),
                const TabBar(
                  tabs: [
                    Tab(text: 'フィルター'),
                    Tab(text: 'フレーム'),
                    Tab(text: 'スタンプ'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      FilterParamSliders(
                        filterParams: _filterParams,
                        onChanged: (value) {
                          setState(() => _filterParams = value);
                          _markChanged();
                        },
                      ),
                      FramePicker(
                        selectedFrameAssetId: _frameAssetId,
                        onChanged: (value) {
                          setState(() => _frameAssetId = value);
                          _markChanged();
                        },
                      ),
                      StampAssetGrid(
                        canAddMore:
                            _stampLayers.length < StampLayerLimits.maxLayers,
                        onAdd: _addStamp,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: PrimaryButton(
                    label: '保存する',
                    isLoading: saveState.isLoading,
                    onPressed: _handleSave,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
