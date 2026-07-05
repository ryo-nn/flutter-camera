import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera/src/core/utils/tune_color_matrix.dart';
import 'package:flutter_camera/src/features/patterns/data/pattern_asset_thumbnail_provider.dart';
import 'package:flutter_camera/src/features/patterns/domain/filter_params.dart';
import 'package:flutter_camera/src/features/patterns/domain/stamp_layer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// S-06a プレビュー: ベース画像に編集中パターンを即時適用する軽量プレビュー
/// (design.md 画面設計・UIフロー章 S-06a①準拠)。
///
/// 「ベース画像は直近の撮影画像、なければアプリ同梱のプレビュー用画像」とされているが、
/// 直近撮影画像の共有プロバイダーが設計書に定義されていないため、本実装ではプレース
/// ホルダー背景を用いる(coreChangeRequests/notes参照。同梱プレビュー画像アセットの
/// 追加が必要)。
///
/// フィルターは pro_image_editor の `ColorFilterAddons` が返す5×4カラー行列を
/// `ColorFiltered` で直列適用する軽量合成(design.md カメラ・自動加工パイプライン設計
/// §3.1「軽量適用(ColorFiltered+Stack)」に準拠する実装方針)。フレームは最下層固定
/// (操作不可)、スタンプはドラッグ移動・ピンチ拡大縮小・2本指回転に対応する。
class PatternPreview extends StatelessWidget {
  const PatternPreview({
    super.key,
    required this.filterParams,
    required this.frameAssetId,
    required this.stampLayers,
    required this.selectedStampIndex,
    required this.onSelectStamp,
    required this.onStampLayersChanged,
  });

  final FilterParams filterParams;
  final String? frameAssetId;
  final List<StampLayer> stampLayers;
  final int? selectedStampIndex;
  final ValueChanged<int?> onSelectStamp;
  final ValueChanged<List<StampLayer>> onStampLayersChanged;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      // 撮影正規化(4:5センタークロップ)に合わせる(design.md §5準拠)。
      aspectRatio: 4 / 5,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelectStamp(null),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _FilteredBase(filterParams: filterParams),
                  if (frameAssetId != null)
                    IgnorePointer(child: _AssetImage(assetId: frameAssetId!)),
                  for (var i = 0; i < stampLayers.length; i++)
                    _StampOverlay(
                      key: ValueKey('stamp-$i-${stampLayers[i].assetId}'),
                      layer: stampLayers[i],
                      containerSize: size,
                      isSelected: selectedStampIndex == i,
                      onSelect: () => onSelectStamp(i),
                      onChanged: (updated) {
                        final next = [...stampLayers];
                        next[i] = updated;
                        onStampLayersChanged(next);
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// フィルター行列を直列適用する軽量合成(design.md カメラ・自動加工パイプライン設計
/// §2.1準拠の値域から `ColorFilterAddons` を都度算出)。`smoothing` は全面ブラーで近似する
/// (§2.1「smoothingは全面ソフトフォーカスによる近似」)。
class _FilteredBase extends StatelessWidget {
  const _FilteredBase({required this.filterParams});

  final FilterParams filterParams;

  @override
  Widget build(BuildContext context) {
    final matrices = <List<double>>[
      ColorFilterAddons.brightness(filterParams.brightness),
      ColorFilterAddons.contrast(filterParams.contrast),
      ColorFilterAddons.saturation(filterParams.saturation),
      ColorFilterAddons.exposure(filterParams.exposure),
      ColorFilterAddons.hue(filterParams.hue),
      ColorFilterAddons.temperature(filterParams.temperature),
      tintColorMatrix(filterParams.tint),
      ColorFilterAddons.fade(filterParams.fade),
    ];

    Widget child = const ColoredBox(color: Color(0xFFE0E0E0));
    for (final matrix in matrices) {
      child = ColorFiltered(
        colorFilter: ColorFilter.matrix(matrix),
        child: child,
      );
    }
    if (filterParams.smoothing > 0) {
      child = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(
          sigmaX: filterParams.smoothing * 2.0,
          sigmaY: filterParams.smoothing * 2.0,
        ),
        child: child,
      );
    }
    return child;
  }
}

class _StampOverlay extends StatefulWidget {
  const _StampOverlay({
    super.key,
    required this.layer,
    required this.containerSize,
    required this.isSelected,
    required this.onSelect,
    required this.onChanged,
  });

  final StampLayer layer;
  final Size containerSize;
  final bool isSelected;
  final VoidCallback onSelect;
  final ValueChanged<StampLayer> onChanged;

  @override
  State<_StampOverlay> createState() => _StampOverlayState();
}

class _StampOverlayState extends State<_StampOverlay> {
  double _startWidthRatio = 0;
  double _startRotation = 0;

  @override
  Widget build(BuildContext context) {
    final layer = widget.layer;
    final width = layer.widthRatio * widget.containerSize.width;
    final left = layer.cx * widget.containerSize.width - width / 2;
    final top = layer.cy * widget.containerSize.height - width / 2;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: width,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onSelect,
        onScaleStart: (_) {
          widget.onSelect();
          _startWidthRatio = layer.widthRatio;
          _startRotation = layer.rotation;
        },
        onScaleUpdate: (details) {
          final dx = details.focalPointDelta.dx / widget.containerSize.width;
          final dy = details.focalPointDelta.dy / widget.containerSize.height;
          final updated = layer.copyWith(
            cx: StampLayerLimits.clampNormalized(layer.cx + dx),
            cy: StampLayerLimits.clampNormalized(layer.cy + dy),
            widthRatio: StampLayerLimits.clampWidthRatio(
              _startWidthRatio * details.scale,
            ),
            rotation: _startRotation + details.rotation,
          );
          widget.onChanged(updated);
        },
        child: Transform.rotate(
          angle: layer.rotation,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(
              layer.flipX ? -1.0 : 1.0,
              layer.flipY ? -1.0 : 1.0,
              1.0,
            ),
            child: Container(
              decoration: widget.isSelected
                  ? BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    )
                  : null,
              child: _AssetImage(assetId: layer.assetId),
            ),
          ),
        ),
      ),
    );
  }
}

class _AssetImage extends ConsumerWidget {
  const _AssetImage({required this.assetId});

  final String assetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urlAsync = ref.watch(patternAssetDownloadUrlProvider(assetId));
    return urlAsync.when(
      data: (url) => CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const Icon(Icons.broken_image_outlined),
    );
  }
}
