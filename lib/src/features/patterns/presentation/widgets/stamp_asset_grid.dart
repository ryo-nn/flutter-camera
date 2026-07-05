import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera/src/common_widgets/app_error_view.dart';
import 'package:flutter_camera/src/core/error/error_mapper.dart';
import 'package:flutter_camera/src/core/models/asset.dart';
import 'package:flutter_camera/src/features/patterns/data/firestore_pattern_repository.dart';
import 'package:flutter_camera/src/features/patterns/data/pattern_asset_thumbnail_provider.dart';
import 'package:flutter_camera/src/features/patterns/domain/stamp_layer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S-06a「スタンプ」タブ: アセットグリッドから複数選択(design.md 画面設計・UIフロー章
/// S-06a準拠)。タップで既定位置(中央・幅比率0.3・回転なし)の [StampLayer] を末尾に
/// 追加する。配置の微調整はプレビュー上のドラッグ・ピンチ・回転で行う。
class StampAssetGrid extends ConsumerWidget {
  const StampAssetGrid({
    super.key,
    required this.canAddMore,
    required this.onAdd,
  });

  final bool canAddMore;
  final ValueChanged<String> onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(selectableStampAssetsProvider);
    return Column(
      children: [
        if (!canAddMore)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'スタンプは最大${StampLayerLimits.maxLayers}件まで配置できます。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        Expanded(
          child: assetsAsync.when(
            data: (assets) => GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: assets.length,
              itemBuilder: (context, index) {
                final asset = assets[index];
                return _StampAssetTile(
                  asset: asset,
                  enabled: canAddMore,
                  onTap: () => onAdd(asset.id),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => AppErrorView(
              message: ErrorMapper.toUserMessage(error) ?? '読み込みに失敗しました。',
              onRetry: () => ref.invalidate(selectableStampAssetsProvider),
            ),
          ),
        ),
      ],
    );
  }
}

class _StampAssetTile extends ConsumerWidget {
  const _StampAssetTile({
    required this.asset,
    required this.enabled,
    required this.onTap,
  });

  final Asset asset;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urlAsync = ref.watch(patternAssetDownloadUrlProvider(asset.id));
    return Semantics(
      button: true,
      label: asset.name,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: urlAsync.when(
              data: (url) =>
                  CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
              loading: () => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (error, stackTrace) =>
                  const Icon(Icons.broken_image_outlined),
            ),
          ),
        ),
      ),
    );
  }
}
