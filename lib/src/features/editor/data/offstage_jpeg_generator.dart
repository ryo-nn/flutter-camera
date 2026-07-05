import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_camera/src/routing/app_router.dart'
    show rootNavigatorKey;
import 'package:pro_image_editor/pro_image_editor.dart';

/// S-05a(微調整エディタ)と同一構成の `ProImageEditor` を画面外(Offstage)にマウントし、
/// `captureEditorImage()`(`ProImageEditorState` 公式API)で最終JPEGを取得する
/// (design.md「カメラ・自動加工パイプライン設計」§3.1手順[E]/§6準拠)。
///
/// pro_image_editor自体がFlutter Widgetベースの実装であるため、mount先として
/// アプリ共通の `rootNavigatorKey`(routing章で定義)配下のOverlayを利用する。
/// 同時に1インスタンスのみマウントし、取得後は即座にアンマウントする(§6)。
class OffstageJpegGenerator {
  const OffstageJpegGenerator();

  Future<Uint8List> capture({
    required String normalizedImagePath,
    required Map<String, dynamic> importStateHistoryMap,
    required Widget Function(String id, {Map<String, dynamic>? meta})
    widgetLoader,
    required double imageWidth,
    required double imageHeight,
    int jpegQuality = 90, // design.md §5(超過時はq80で再生成)
  }) async {
    final overlay = rootNavigatorKey.currentState?.overlay;
    if (overlay == null) {
      throw StateError('rootNavigatorKeyにOverlayが見つかりません(最終JPEG生成不可)');
    }

    final editorKey = GlobalKey<ProImageEditorState>();
    final entry = OverlayEntry(
      builder: (context) => SizedBox(
        width: imageWidth,
        height: imageHeight,
        child: Offstage(
          offstage: true,
          child: ProImageEditor.file(
            File(normalizedImagePath),
            key: editorKey,
            configs: ProImageEditorConfigs(
              stateHistory: StateHistoryConfigs(
                initStateHistory: ImportStateHistory.fromMap(
                  importStateHistoryMap,
                  configs: ImportEditorConfigs(
                    recalculateSizeAndPosition: true,
                    widgetLoader: widgetLoader,
                  ),
                ),
              ),
              imageGeneration: ImageGenerationConfigs(
                outputFormat: OutputFormat.jpg,
                jpegQuality: jpegQuality,
                maxOutputSize: const Size(1440, 1800), // design.md §5
                processorConfigs: const ProcessorConfigs(
                  processorMode: ProcessorMode.auto,
                ),
              ),
            ),
            callbacks: const ProImageEditorCallbacks(),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    try {
      // ProImageEditorのマウント・初期化(initStateHistoryの反映)完了を1フレーム待つ。
      await WidgetsBinding.instance.endOfFrame;
      final state = editorKey.currentState;
      if (state == null) {
        throw StateError('OffstageのProImageEditorのマウントに失敗しました');
      }
      return await state.captureEditorImage();
    } finally {
      entry.remove();
    }
  }
}
