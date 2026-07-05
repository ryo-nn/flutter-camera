import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_camera/src/core/firebase/firebase_providers.dart';
import 'package:flutter_camera/src/features/editor/data/asset_cache_service.dart';
import 'package:flutter_camera/src/features/editor/data/image_normalization_service.dart';
import 'package:flutter_camera/src/features/editor/data/offstage_jpeg_generator.dart';
import 'package:flutter_camera/src/features/editor/data/pattern_import_map_builder.dart';
import 'package:flutter_camera/src/features/editor/domain/pattern_apply_service.dart';
import 'package:flutter_camera/src/features/patterns/domain/pattern.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pro_image_editor_apply_service.g.dart';

/// Instagram Graph APIのファイルサイズ上限(design.md §5)。
const _maxJpegBytes = 8 * 1024 * 1024;

/// [PatternApplyService] の pro_image_editor 実装(design.md「カメラ・自動加工
/// パイプライン設計」準拠)。
class ProImageEditorApplyService implements PatternApplyService {
  ProImageEditorApplyService({
    required AssetCacheService assetCacheService,
    ImageNormalizationService normalizationService =
        const ImageNormalizationService(),
    OffstageJpegGenerator offstageGenerator = const OffstageJpegGenerator(),
  }) : _assetCache = assetCacheService,
       _normalizationService = normalizationService,
       _offstageGenerator = offstageGenerator;

  final AssetCacheService _assetCache;
  final ImageNormalizationService _normalizationService;
  final OffstageJpegGenerator _offstageGenerator;

  @override
  Future<NormalizedImage> normalizeCapture(String sourceImagePath) {
    return _normalizationService.normalizeCapture(sourceImagePath);
  }

  @override
  Future<void> precachePatternAssets(Pattern? pattern) {
    if (pattern == null) return Future.value(); // 「加工なし」はキャッシュ不要
    // id は Storageフルパスではなく assetId(`assets/{assetId}`)。
    // AssetCacheService側でstoragePathへ解決する(coreChangeRequests参照)。
    final assetIds = <String>[
      if (pattern.frameAssetId != null) pattern.frameAssetId!,
      for (final stamp in pattern.stampLayers) stamp.assetId,
    ];
    return _assetCache.precacheAll(assetIds);
  }

  @override
  Widget Function(String id, {Map<String, dynamic>? meta})
  buildLayerWidgetLoader({
    required double canvasWidth,
    required double canvasHeight,
  }) {
    // design.md §4.3 `patternWidgetLoader` 準拠。
    return (String id, {Map<String, dynamic>? meta}) {
      final sep = id.indexOf(':');
      if (sep < 0) {
        throw ArgumentError('unknown layer id: $id');
      }
      final kind = id.substring(0, sep); // 'frame' | 'stamp'
      final assetId = id.substring(sep + 1);
      final file = File(_assetCache.resolveSync(assetId));

      switch (kind) {
        case 'frame':
          return SizedBox(
            width: canvasWidth,
            height: canvasHeight,
            child: Image.file(file, fit: BoxFit.cover),
          );
        case 'stamp':
          final ratio = (meta?['widthRatio'] as num?)?.toDouble() ?? 0.3;
          return SizedBox(
            width: canvasWidth * ratio,
            child: Image.file(file, fit: BoxFit.contain),
          );
        default:
          throw ArgumentError('unknown layer id: $id');
      }
    };
  }

  @override
  Future<Map<String, dynamic>> buildImportStateHistoryMap({
    required Pattern? pattern,
    required double imageWidth,
    required double imageHeight,
  }) {
    return buildPatternImportMapInBackground(
      pattern: pattern,
      imgW: imageWidth,
      imgH: imageHeight,
    );
  }

  @override
  Future<Uint8List> finalizeJpeg({
    required String normalizedImagePath,
    required Pattern? pattern,
    required double imageWidth,
    required double imageHeight,
    Uint8List? confirmedCandidateJpeg,
  }) async {
    Uint8List bytes;
    if (confirmedCandidateJpeg != null) {
      bytes = confirmedCandidateJpeg;
    } else {
      bytes = await _generate(
        normalizedImagePath: normalizedImagePath,
        pattern: pattern,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        jpegQuality: 90,
      );
    }

    if (bytes.lengthInBytes > _maxJpegBytes) {
      // design.md §5: 超過時はq80で再生成。
      bytes = await _generate(
        normalizedImagePath: normalizedImagePath,
        pattern: pattern,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        jpegQuality: 80,
      );
    }

    return bytes;
  }

  Future<Uint8List> _generate({
    required String normalizedImagePath,
    required Pattern? pattern,
    required double imageWidth,
    required double imageHeight,
    required int jpegQuality,
  }) async {
    await precachePatternAssets(pattern);
    final importMap = await buildImportStateHistoryMap(
      pattern: pattern,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );
    final widgetLoader = buildLayerWidgetLoader(
      canvasWidth: imageWidth,
      canvasHeight: imageHeight,
    );
    return _offstageGenerator.capture(
      normalizedImagePath: normalizedImagePath,
      importStateHistoryMap: importMap,
      widgetLoader: widgetLoader,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      jpegQuality: jpegQuality,
    );
  }
}

/// パターン適用サービスのDI(design.md アプリアーキテクチャ設計
/// プロバイダー設計「patternApplyServiceProvider」準拠)。
@Riverpod(keepAlive: true)
PatternApplyService patternApplyService(Ref ref) {
  final storage = ref.watch(firebaseStorageProvider);
  final firestore = ref.watch(firestoreProvider);
  return ProImageEditorApplyService(
    assetCacheService: AssetCacheService(
      storage: storage,
      firestore: firestore,
    ),
  );
}
