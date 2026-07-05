import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_camera/src/features/camera/domain/captured_photo.dart';
import 'package:flutter_camera/src/features/editor/data/pro_image_editor_apply_service.dart';
import 'package:flutter_camera/src/features/editor/domain/edited_image.dart';
import 'package:flutter_camera/src/features/editor/domain/pattern_apply_service.dart';
import 'package:flutter_camera/src/features/patterns/domain/pattern.dart';
import 'package:flutter_camera/src/features/patterns/presentation/selected_pattern_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'edit_preview_controller.g.dart';

/// 画面5(加工プレビュー)のコントローラ(design.md アプリアーキテクチャ設計
/// プロバイダー設計「editPreviewControllerProvider」準拠)。
///
/// 撮影画像へのパターン適用・微調整・JPEG確定出力を担う。軽量プレビュー自体の
/// 描画([LightweightPatternPreview])はpresentation側でselectedPatternProviderの
/// 変化を直接watchして即時再構成するため、本コントローラは
/// (1) 正規化(初回のみ)、(2) パターン切替時のアセットprecache、
/// (3) 微調整(S-05a)結果の反映、(4) 最終JPEG確定、の非同期処理のみを担当する。
@riverpod
class EditPreviewController extends _$EditPreviewController {
  NormalizedImage? _normalized;
  Uint8List? _confirmedCandidateJpeg;
  Map<String, dynamic>? _adjustStateHistoryMap;
  Pattern? _candidatePattern;

  @override
  Future<EditedImage> build(CapturedPhoto capturedPhoto) async {
    final service = ref.watch(patternApplyServiceProvider);
    final normalized = await service.normalizeCapture(capturedPhoto.imagePath);
    _normalized = normalized;

    final pattern = ref.read(selectedPatternProvider);
    await service.precachePatternAssets(pattern);

    return EditedImage(filePath: normalized.filePath, isFinal: false);
  }

  NormalizedImage get _requireNormalized {
    final normalized = _normalized;
    if (normalized == null) {
      throw StateError('normalizeCaptureが完了する前に呼び出されました');
    }
    return normalized;
  }

  /// カルーセルでパターンを切り替えたときの再適用(design.md S-05「パターン差し替え」)。
  /// 微調整差分・確定候補は破棄し、切替先パターンのアセットをprecacheし直す(§3.1)。
  ///
  /// NOTE(coreChangeRequests参照): 解決済みriverpod(3.2.1)では
  /// `AsyncValue.copyWithPrevious` が `@internal` 指定のため使用できない
  /// (design.mdが前提とする3.3.2系との差異)。そのため本メソッドは失敗時も
  /// `state` を書き換えず(直前の正常なプレビューを維持したまま)例外をrethrowし、
  /// 呼び出し側(EditPreviewScreen)がローカル状態でローディング表示・SnackBar表示を行う。
  Future<void> reapplyPattern(Pattern? pattern) async {
    _confirmedCandidateJpeg = null;
    _adjustStateHistoryMap = null;
    _candidatePattern = null;

    final service = ref.read(patternApplyServiceProvider);
    await service.precachePatternAssets(pattern);
    // 正規化済み画像(filePath)自体は変化しないため、成功時もstateの更新は不要。
  }

  /// 「微調整」タップ時: S-05a(pro_image_editor)起動用のimportMapを準備する
  /// (design.md §3.1/§3.2)。同一パターンで既に微調整差分があればそれを再利用する。
  Future<Map<String, dynamic>> prepareAdjustEditor(Pattern? pattern) async {
    final adjustMap = _adjustStateHistoryMap;
    if (adjustMap != null && _candidatePattern == pattern) {
      return adjustMap;
    }
    final service = ref.read(patternApplyServiceProvider);
    await service.precachePatternAssets(pattern);
    final normalized = _requireNormalized;
    return service.buildImportStateHistoryMap(
      pattern: pattern,
      imageWidth: normalized.width,
      imageHeight: normalized.height,
    );
  }

  /// S-05a完了時(`onImageEditingComplete`)の反映(design.md §3.1)。
  /// 確定候補JPEGを一時ファイルに保存し、以降S-05はこれをそのまま表示する。
  Future<void> onAdjustEditingComplete({
    required Pattern? pattern,
    required Uint8List jpegBytes,
    required Map<String, dynamic> exportedStateHistoryMap,
  }) async {
    _confirmedCandidateJpeg = jpegBytes;
    _adjustStateHistoryMap = exportedStateHistoryMap;
    _candidatePattern = pattern;

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/adjust_preview_${_uniqueSuffix()}.jpg';
    await File(path).writeAsBytes(jpegBytes, flush: true);

    state = AsyncData(EditedImage(filePath: path, isFinal: false));
  }

  /// 「次へ」タップ時: 最終JPEGを確定する(design.md §3.1手順[E]/[F])。
  /// 失敗時は `state` を書き換えず例外をrethrowする(直前のプレビューを維持。
  /// 上記 [reapplyPattern] のNOTE参照)。
  Future<EditedImage> confirm(Pattern? pattern) async {
    final service = ref.read(patternApplyServiceProvider);
    final normalized = _requireNormalized;
    final bytes = await service.finalizeJpeg(
      normalizedImagePath: normalized.filePath,
      pattern: pattern,
      imageWidth: normalized.width,
      imageHeight: normalized.height,
      confirmedCandidateJpeg: _candidatePattern == pattern
          ? _confirmedCandidateJpeg
          : null,
    );

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/edited_${_uniqueSuffix()}.jpg';
    await File(path).writeAsBytes(bytes, flush: true);

    final result = EditedImage(filePath: path, isFinal: true);
    state = AsyncData(result);
    return result;
  }

  String _uniqueSuffix() {
    final random = Random().nextInt(1 << 32).toRadixString(16);
    return '${DateTime.now().microsecondsSinceEpoch}_$random';
  }
}
