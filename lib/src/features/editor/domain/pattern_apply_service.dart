import 'dart:typed_data';

import 'package:flutter/widgets.dart' show Widget;
import 'package:flutter_camera/src/features/patterns/domain/pattern.dart';

/// パターン自動適用エンジンの抽象(design.md「カメラ・自動加工パイプライン設計」準拠)。
///
/// 実装は data 層(`pro_image_editor_apply_service.dart`)。domain 層は本来
/// Flutter/Firebase SDKに依存しない純Dartとする方針(design.md アプリアーキテクチャ設計
/// 「レイヤー責務と依存方向」)だが、[buildLayerWidgetLoader] のみ例外的に Flutter の
/// `Widget` 型を露出する(戻り値の関数型は pro_image_editor の `WidgetLoader`
/// `Widget Function(String,{meta})` と構造的に同一だが、当該typedefはパッケージの
/// 公開バレルからexportされていないため、ここでは関数型を直接記述している)。
/// pro_image_editorの `ImportEditorConfigs.widgetLoader` がFlutter Widgetを要求する
/// 公開APIであり、この関数自体をS-05a画面とOffstage最終生成の双方で共有する必要があるため
/// (design.md §3.1/§4.3)。禁止対象の「SDK型の露出」はFirestore `DocumentSnapshot` 等の
/// I/O由来型を主眼とした規約と解釈し、この1点のみ許容する(統合フェーズの申し送り事項)。
///
/// パイプライン全体(§3.1): 正規化(§5) → 軽量プレビュー適用(presentation層の責務、
/// 本インターフェースの対象外) → 「微調整」タップ時のみ [buildImportStateHistoryMap] +
/// [buildLayerWidgetLoader] で S-05a(pro_image_editor)起動 → 「次へ」確定時に
/// [finalizeJpeg] で最終JPEGを生成。
abstract class PatternApplyService {
  /// 撮影直後の正規化(4:5センタークロップ+幅1440px上限。design.md §5)。
  /// 中間フォーマットはロスレスPNGの一時ファイル。
  Future<NormalizedImage> normalizeCapture(String sourceImagePath);

  /// パターンの frame/stamp アセットを事前キャッシュする(design.md §4.3 precache契約)。
  /// [buildImportStateHistoryMap] で得たマップを pro_image_editor に渡す前、および
  /// [buildLayerWidgetLoader] が返す関数を使う前に必ず完了させること
  /// (widgetLoader は同期関数のため)。
  /// `null` は「加工なし」(design.md S-04カルーセルの先頭タイル)を表し、
  /// アセットのキャッシュは発生しない。
  Future<void> precachePatternAssets(Pattern? pattern);

  /// precache 済みのフレーム/スタンプを解決する `widgetLoader` を生成する(同期。
  /// design.md §4.3)。[canvasWidth]/[canvasHeight] は正規化後画像の実寸px。
  /// 未キャッシュのアセットが要求された場合は [StateError] を投げる
  /// (呼び出し前に [precachePatternAssets] が必須)。
  Widget Function(String id, {Map<String, dynamic>? meta})
  buildLayerWidgetLoader({
    required double canvasWidth,
    required double canvasHeight,
  });

  /// Pattern → `ImportStateHistory` 用マップを生成する(design.md §3.2)。
  /// 純Dart処理のため実装側で `Isolate.run` を使用する(§3.4)。
  /// [pattern] が `null`(「加工なし」)の場合はフィルター・レイヤーとも無しの
  /// 初期状態マップを生成する。
  Future<Map<String, dynamic>> buildImportStateHistoryMap({
    required Pattern? pattern,
    required double imageWidth,
    required double imageHeight,
  });

  /// 最終JPEGを確定する(design.md §3.1 手順[E])。
  ///
  /// [confirmedCandidateJpeg] が指定されている場合(S-05a の `onImageEditingComplete`
  /// 由来の確定候補)はそれをそのまま返し、再生成しない。未指定の場合は
  /// [normalizedImagePath] と [pattern] から同一構成の pro_image_editor を
  /// Offstage起動して `captureEditorImage()` で生成する。
  ///
  /// 戻り値は§5のサイズ検証(8MB以内)を満たすJPEGバイト列。
  Future<Uint8List> finalizeJpeg({
    required String normalizedImagePath,
    required Pattern? pattern,
    required double imageWidth,
    required double imageHeight,
    Uint8List? confirmedCandidateJpeg,
  });
}

/// [PatternApplyService.normalizeCapture] の戻り値。
/// 正規化後(4:5センタークロップ済み)PNGの一時ファイルパスと実寸pxを保持する。
class NormalizedImage {
  const NormalizedImage({
    required this.filePath,
    required this.width,
    required this.height,
  });

  final String filePath;
  final double width;
  final double height;
}
