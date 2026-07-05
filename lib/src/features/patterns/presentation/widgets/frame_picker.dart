import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera/src/common_widgets/app_error_view.dart';
import 'package:flutter_camera/src/core/error/error_mapper.dart';
import 'package:flutter_camera/src/core/models/asset.dart';
import 'package:flutter_camera/src/features/patterns/data/firestore_pattern_repository.dart';
import 'package:flutter_camera/src/features/patterns/data/pattern_asset_thumbnail_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S-06a「フレーム」タブ: 横スクロール選択(先頭「なし」+フレームアセット一覧、単一選択)。
/// (design.md 画面設計・UIフロー章 S-06a準拠)
class FramePicker extends ConsumerWidget {
  const FramePicker({
    super.key,
    required this.selectedFrameAssetId,
    required this.onChanged,
  });

  final String? selectedFrameAssetId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(selectableFrameAssetsProvider);
    return assetsAsync.when(
      data: (assets) => _FrameList(
        assets: assets,
        selectedFrameAssetId: selectedFrameAssetId,
        onChanged: onChanged,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => AppErrorView(
        message: ErrorMapper.toUserMessage(error) ?? '読み込みに失敗しました。',
        onRetry: () => ref.invalidate(selectableFrameAssetsProvider),
      ),
    );
  }
}

class _FrameList extends StatelessWidget {
  const _FrameList({
    required this.assets,
    required this.selectedFrameAssetId,
    required this.onChanged,
  });

  final List<Asset> assets;
  final String? selectedFrameAssetId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      itemCount: assets.length + 1,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _FrameTile(
            label: 'なし',
            isSelected: selectedFrameAssetId == null,
            onTap: () => onChanged(null),
            child: const Icon(Icons.block),
          );
        }
        final asset = assets[index - 1];
        return _FrameTile(
          label: asset.name,
          isSelected: selectedFrameAssetId == asset.id,
          onTap: () => onChanged(asset.id),
          child: _FrameThumbnail(assetId: asset.id),
        );
      },
    );
  }
}

class _FrameTile extends StatelessWidget {
  const _FrameTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.child,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: isSelected,
      label: isSelected ? '$label、選択中' : label,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 64,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? scheme.primary : scheme.outline,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: child,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FrameThumbnail extends ConsumerWidget {
  const _FrameThumbnail({required this.assetId});

  final String assetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urlAsync = ref.watch(patternAssetDownloadUrlProvider(assetId));
    return urlAsync.when(
      data: (url) => CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
      loading: () =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (error, stackTrace) => const Icon(Icons.broken_image_outlined),
    );
  }
}
