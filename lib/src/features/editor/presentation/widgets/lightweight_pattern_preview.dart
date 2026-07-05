import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_camera/src/core/utils/tune_color_matrix.dart';
import 'package:flutter_camera/src/features/editor/domain/pattern_apply_service.dart';
import 'package:flutter_camera/src/features/patterns/domain/filter_params.dart';
import 'package:flutter_camera/src/features/patterns/domain/pattern.dart';
import 'package:pro_image_editor/pro_image_editor.dart' show ColorFilterAddons;

/// パターンの軽量プレビュー適用(design.md「カメラ・自動加工パイプライン設計」§3.3準拠)。
///
/// `ColorFiltered`(`ColorFilterAddons.*` の5×4行列)+ `ImageFiltered`(smoothing)+
/// `Stack` でフレーム/スタンプPNGを重ねる。GPU合成のみでCPUでの画素処理は行わない。
/// フレーム/スタンプの解決には [PatternApplyService.buildLayerWidgetLoader] を再利用し、
/// S-05a・最終生成と同一のアセット配置ロジックを共有する(design.md §4.3)。
///
/// アセットは事前に [PatternApplyService.precachePatternAssets] でキャッシュ済みである
/// ことが前提(呼び出し側の責務)。
class LightweightPatternPreview extends StatelessWidget {
  const LightweightPatternPreview({
    super.key,
    required this.imageFile,
    required this.pattern,
    required this.service,
    required this.aspectRatio,
  });

  /// プレビュー対象の背景画像(正規化後PNG、またはS-05a確定候補JPEG)。
  final File imageFile;

  /// 適用するパターン。`null` は「加工なし」。
  final Pattern? pattern;

  final PatternApplyService service;

  /// 背景画像のアスペクト比(width/height。design.md §5により常に4:5)。
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final filterParams = pattern?.filterParams;
    Widget photo = Image.file(imageFile, fit: BoxFit.contain);
    if (filterParams != null) {
      photo = _applyLightweightFilter(photo, filterParams);
    }

    final currentPattern = pattern;
    if (currentPattern == null) {
      return AspectRatio(aspectRatio: aspectRatio, child: photo);
    }

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final displayWidth = constraints.maxWidth;
          final displayHeight = constraints.maxHeight;
          final loader = service.buildLayerWidgetLoader(
            canvasWidth: displayWidth,
            canvasHeight: displayHeight,
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              photo,
              if (currentPattern.frameAssetId != null)
                Positioned.fill(
                  child: loader('frame:${currentPattern.frameAssetId}'),
                ),
              for (final stamp in currentPattern.stampLayers)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment(2 * stamp.cx - 1, 2 * stamp.cy - 1),
                    child: Transform.rotate(
                      angle: stamp.rotation,
                      child: loader(
                        'stamp:${stamp.assetId}',
                        meta: {'widthRatio': stamp.widthRatio},
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _applyLightweightFilter(Widget photo, FilterParams p) {
    var w = photo;
    for (final m in [
      if (p.brightness != 0) ColorFilterAddons.brightness(p.brightness),
      if (p.contrast != 0) ColorFilterAddons.contrast(p.contrast),
      if (p.saturation != 0) ColorFilterAddons.saturation(p.saturation),
      if (p.exposure != 0) ColorFilterAddons.exposure(p.exposure),
      if (p.hue != 0) ColorFilterAddons.hue(p.hue),
      if (p.temperature != 0) ColorFilterAddons.temperature(p.temperature),
      if (p.tint != 0) tintColorMatrix(p.tint),
      if (p.fade != 0) ColorFilterAddons.fade(p.fade),
    ]) {
      w = ColorFiltered(colorFilter: ColorFilter.matrix(m), child: w);
    }
    if (p.smoothing > 0) {
      final sigma = p.smoothing * 2.0;
      w = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: w,
      );
    }
    return w;
  }
}
