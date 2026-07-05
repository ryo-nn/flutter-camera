import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// S-05a 微調整エディタ(design.md 画面設計・UIフロー章 / カメラ・自動加工パイプライン
/// 設計§3.1・§3.2準拠)。S-05から全画面モーダルとして起動し、Tune・Filter・
/// Sticker/Emojiエディタを有効化する。pro_image_editorのUI文字列はi18nで全文日本語化する。
///
/// GoRouterのルート表(design.md §「GoRouterルーティング設計」)にS-05aは含まれない
/// (S-05の内部モーダルとして扱う)ため、`Navigator.push` のフルスクリーンダイアログとして
/// 実装する。
class AdjustEditorScreen extends StatelessWidget {
  // GlobalKeyのインスタンス初期化がconst不可のため、本ウィジェットはconstにしない。
  AdjustEditorScreen({
    super.key,
    required this.normalizedImagePath,
    required this.importStateHistoryMap,
    required this.widgetLoader,
    required this.onEditingComplete,
  });

  final String normalizedImagePath;
  final Map<String, dynamic> importStateHistoryMap;
  final Widget Function(String id, {Map<String, dynamic>? meta}) widgetLoader;

  // インスタンスごとに1つ。`exportStateHistory` 呼び出しのためエディタ本体を参照する。
  final GlobalKey<ProImageEditorState> _editorKey =
      GlobalKey<ProImageEditorState>();

  /// 完了時(`onImageEditingComplete`)のコールバック。
  /// 最終JPEGバイト列とexportStateHistory(再オープン用)を渡す。
  final void Function(Uint8List jpegBytes, Map<String, dynamic> exportedMap)
  onEditingComplete;

  @override
  Widget build(BuildContext context) {
    return ProImageEditor.file(
      File(normalizedImagePath),
      configs: ProImageEditorConfigs(
        i18n: _japaneseI18n,
        stateHistory: StateHistoryConfigs(
          initStateHistory: ImportStateHistory.fromMap(
            importStateHistoryMap,
            configs: ImportEditorConfigs(
              recalculateSizeAndPosition: true,
              widgetLoader: widgetLoader,
            ),
          ),
        ),
        imageGeneration: const ImageGenerationConfigs(
          outputFormat: OutputFormat.jpg,
          jpegQuality: 90, // design.md §5
          maxOutputSize: Size(1440, 1800), // design.md §5
          processorConfigs: ProcessorConfigs(processorMode: ProcessorMode.auto),
        ),
        cropRotateEditor: const CropRotateEditorConfigs(
          initAspectRatio: 4 / 5,
          aspectRatios: [
            // Instagram許容比のみに制限(design.md §5)
            AspectRatioItem(text: '4:5', value: 4 / 5),
            AspectRatioItem(text: '1:1', value: 1),
            AspectRatioItem(text: '1.91:1', value: 1.91),
          ],
        ),
      ),
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: (bytes) async {
          Map<String, dynamic> exportedMap = const {};
          final editorState = _editorKey.currentState;
          if (editorState != null) {
            final exported = await editorState.exportStateHistory(
              configs: const ExportEditorConfigs(
                historySpan: ExportHistorySpan.current,
              ),
            );
            exportedMap = await exported.toMap();
          }
          onEditingComplete(bytes, exportedMap);
        },
        onCloseEditor: (mode) => Navigator.of(context).pop(),
      ),
      key: _editorKey,
    );
  }
}

/// pro_image_editorのUI文字列を日本語化する(design.md S-05
/// 「i18nで日本語化」準拠)。
final _japaneseI18n = I18n(
  various: const I18nVarious(
    loadingDialogMsg: '読み込み中...',
    closeEditorWarningTitle: 'エディタを閉じますか?',
    closeEditorWarningMessage: '変更内容は保存されません。エディタを閉じてもよろしいですか?',
    closeEditorWarningConfirmBtn: '閉じる',
    closeEditorWarningCancelBtn: 'キャンセル',
  ),
  tuneEditor: const I18nTuneEditor(
    bottomNavigationBarText: '調整',
    back: '戻る',
    done: '完了',
    brightness: '明るさ',
    contrast: 'コントラスト',
    saturation: '彩度',
    exposure: '露出',
    hue: '色相',
    temperature: '色温度',
    fade: 'フェード',
    // NOTE: pubspec.yaml の pro_image_editor バージョン固定NOTE参照。本バージョン
    // (12.4.7)では 13.0.0 の `tint` フィールドがまだ `luminance` という名称
    // (design.md の「ティント」に相当する調整項目は無くsharpness/luminanceの構成)。
    // UI表示ラベルは design.md のFilterParams「ティント」に合わせて据え置く。
    luminance: 'ティント',
    undo: '元に戻す',
    redo: 'やり直す',
  ),
  filterEditor: const I18nFilterEditor(
    bottomNavigationBarText: 'フィルター',
    back: '戻る',
    done: '完了',
  ),
  cropRotateEditor: const I18nCropRotateEditor(
    bottomNavigationBarText: '切り抜き/回転',
    rotate: '回転',
    flip: '反転',
    ratio: '比率',
    back: '戻る',
    done: '完了',
    cancel: 'キャンセル',
    undo: '元に戻す',
    redo: 'やり直す',
    reset: 'リセット',
  ),
  stickerEditor: const I18nStickerEditor(bottomNavigationBarText: 'スタンプ'),
  emojiEditor: const I18nEmojiEditor(
    bottomNavigationBarText: '絵文字',
    search: '検索',
  ),
  blurEditor: const I18nBlurEditor(
    bottomNavigationBarText: 'ぼかし',
    back: '戻る',
    done: '完了',
  ),
  layerInteraction: const I18nLayerInteraction(
    remove: '削除',
    edit: '編集',
    rotateScale: '回転・拡大縮小',
  ),
  cancel: 'キャンセル',
  undo: '元に戻す',
  redo: 'やり直す',
  done: '完了',
  remove: '削除',
  doneLoadingMsg: '反映しています...',
  // 微調整エディタ再オープン時(`initStateHistory` インポート)の読み込みダイアログ文言。
  // 既定値 'Initialize Editor'(英語)の日本語化漏れ(coreChangeRequests参照)。
  importStateHistoryMsg: 'エディタを準備しています...',
);
