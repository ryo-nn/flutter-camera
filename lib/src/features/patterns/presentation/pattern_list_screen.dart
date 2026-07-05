import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera/src/common_widgets/app_error_view.dart';
import 'package:flutter_camera/src/common_widgets/confirm_dialog.dart';
import 'package:flutter_camera/src/core/constants/app_durations.dart';
import 'package:flutter_camera/src/core/error/error_mapper.dart';
import 'package:flutter_camera/src/core/models/plan.dart';
// `currentPlanProvider` の実体は billing/data/firestore_billing_repository.dart に
// 定義されている(design.md 課金(IAP)・ペイウォール設計章「feature間参照: posting(S-07)と
// patterns は billing/domain の型ではなく core/models/plan.dart の Plan と
// currentPlanProvider を参照する」。domain層はdata層に依存できない既存規約により、
// billing feature側の実装ではプロバイダー実体をdata層に置いている)。
import 'package:flutter_camera/src/features/billing/data/firestore_billing_repository.dart'
    show currentPlanProvider;
import 'package:flutter_camera/src/features/patterns/data/firestore_pattern_repository.dart';
import 'package:flutter_camera/src/features/patterns/data/pattern_asset_thumbnail_provider.dart';
import 'package:flutter_camera/src/features/patterns/domain/pattern.dart';
import 'package:flutter_camera/src/features/patterns/presentation/pattern_edit_controller.dart';
import 'package:flutter_camera/src/routing/app_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S-06 パターン管理画面(一覧)。
/// (design.md 画面設計・UIフロー章 S-06 準拠)
class PatternListScreen extends ConsumerWidget {
  const PatternListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presetsAsync = ref.watch(presetPatternsProvider);
    final userPatternsAsync = ref.watch(userPatternsProvider);
    final currentPlan = ref.watch(currentPlanProvider);

    // 削除失敗はSnackBarで通知する(design.md 画面設計・UIフロー章 S-06
    // 「削除実行(失敗時SnackBar)」準拠)。patternId は削除操作のたびに
    // 呼び出し側で family instance を作り分けるため、ここでは代表として
    // 直近操作対象の family を都度 listen する(下記 `_DeleteMenuButton` 内で実施)。

    return Scaffold(
      appBar: AppBar(title: const Text('パターン管理')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(AppRoute.patternNew.name),
        tooltip: 'パターンを作る',
        child: const Icon(Icons.add),
      ),
      body: presetsAsync.when(
        data: (presets) => userPatternsAsync.when(
          data: (userPatterns) => _PatternSections(
            presets: presets,
            userPatterns: userPatterns,
            currentPlan: currentPlan,
          ),
          loading: () => const _LoadingGrid(),
          error: (error, stackTrace) => AppErrorView(
            message: ErrorMapper.toUserMessage(error) ?? '読み込みに失敗しました。',
            onRetry: () => ref.invalidate(userPatternsProvider),
          ),
        ),
        loading: () => const _LoadingGrid(),
        error: (error, stackTrace) => AppErrorView(
          message: ErrorMapper.toUserMessage(error) ?? '読み込みに失敗しました。',
          onRetry: () => ref.invalidate(presetPatternsProvider),
        ),
      ),
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _PatternSections extends ConsumerWidget {
  const _PatternSections({
    required this.presets,
    required this.userPatterns,
    required this.currentPlan,
  });

  final List<Pattern> presets;
  final List<Pattern> userPatterns;
  final Plan currentPlan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('プリセット', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _PresetGrid(presets: presets, currentPlan: currentPlan),
        const SizedBox(height: 24),
        Text('マイパターン', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (userPatterns.isEmpty)
          _MyPatternsEmpty(
            onCreate: () => context.pushNamed(AppRoute.patternNew.name),
          )
        else
          _UserPatternGrid(patterns: userPatterns),
      ],
    );
  }
}

class _PresetGrid extends ConsumerWidget {
  const _PresetGrid({required this.presets, required this.currentPlan});

  final List<Pattern> presets;
  final Plan currentPlan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (presets.isEmpty) {
      return const Text('プリセットがありません。');
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: presets.length,
      itemBuilder: (context, index) {
        final pattern = presets[index];
        final isLocked = pattern.isPremium && currentPlan != Plan.pro;
        return _PatternTile(
          pattern: pattern,
          isPreset: true,
          isLocked: isLocked,
          onTap: () {
            if (isLocked) {
              // design.md リテンション機能設計章「プレミアムパターンのアクセス制御」:
              // タップ時は適用せずペイウォールへ遷移する。extraのpatternIdにより
              // ペイウォール側で「『◯◯』はProプラン限定」の訴求文脈を表示する。
              context.pushNamed(AppRoute.plan.name, extra: pattern.id);
              return;
            }
            _duplicateFromPreset(context, ref, pattern);
          },
          menuItems: [
            if (!isLocked)
              PopupMenuItem(
                child: const Text('複製'),
                onTap: () => Future.microtask(() {
                  if (!context.mounted) return;
                  _duplicateFromPreset(context, ref, pattern);
                }),
              ),
          ],
        );
      },
    );
  }

  void _duplicateFromPreset(
    BuildContext context,
    WidgetRef ref,
    Pattern preset,
  ) {
    ref.read(patternDuplicateSourceProvider.notifier).select(preset);
    context.pushNamed(AppRoute.patternNew.name);
  }
}

class _UserPatternGrid extends ConsumerWidget {
  const _UserPatternGrid({required this.patterns});

  final List<Pattern> patterns;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: patterns.length,
      itemBuilder: (context, index) {
        final pattern = patterns[index];
        return _PatternTile(
          pattern: pattern,
          isPreset: false,
          isLocked: false,
          onTap: () => context.pushNamed(
            AppRoute.patternEdit.name,
            pathParameters: {'patternId': pattern.id},
          ),
          menuItems: [
            PopupMenuItem(
              child: const Text('編集'),
              onTap: () => Future.microtask(() {
                if (!context.mounted) return;
                context.pushNamed(
                  AppRoute.patternEdit.name,
                  pathParameters: {'patternId': pattern.id},
                );
              }),
            ),
            PopupMenuItem(
              child: const Text('削除'),
              onTap: () => Future.microtask(() {
                if (!context.mounted) return;
                _confirmAndDelete(context, ref, pattern);
              }),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    WidgetRef ref,
    Pattern pattern,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: '削除しますか?',
      message: '『${pattern.name}』を削除しますか?この操作は取り消せません。',
      confirmLabel: '削除する',
      isDestructive: true,
    );
    if (!confirmed) return;
    if (!context.mounted) return;

    await ref.read(patternEditControllerProvider(pattern.id).notifier).delete();

    // 削除失敗時のSnackBar表示(design.md 画面設計・UIフロー章 S-06準拠)。
    if (!context.mounted) return;
    final result = ref.read(patternEditControllerProvider(pattern.id));
    if (result case AsyncError(:final error)) {
      final message = ErrorMapper.toUserMessage(error);
      if (message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }
}

class _MyPatternsEmpty extends StatelessWidget {
  const _MyPatternsEmpty({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('まだマイパターンがありません。最初のパターンを作りましょう。'),
          const SizedBox(height: 12),
          FilledButton(onPressed: onCreate, child: const Text('パターンを作る')),
        ],
      ),
    );
  }
}

class _PatternTile extends StatelessWidget {
  const _PatternTile({
    required this.pattern,
    required this.isPreset,
    required this.isLocked,
    required this.onTap,
    required this.menuItems,
  });

  final Pattern pattern;
  final bool isPreset;
  final bool isLocked;
  final VoidCallback onTap;
  final List<PopupMenuEntry<void>> menuItems;

  bool get _isNew {
    final publishedAt = pattern.publishedAt;
    if (publishedAt == null) return false;
    return DateTime.now().difference(publishedAt) <
        AppDurations.newPatternBadgeThreshold;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: pattern.name,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  clipBehavior: Clip.none,
                  children: [
                    _Thumbnail(pattern: pattern),
                    if (isPreset)
                      const Positioned(
                        left: 4,
                        top: 4,
                        child: _Badge(label: 'プリセット'),
                      ),
                    if (_isNew)
                      const Positioned(
                        right: 4,
                        top: 4,
                        child: _Badge(label: 'NEW'),
                      ),
                    if (isLocked)
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Icon(
                          Icons.lock,
                          size: 20,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    if (menuItems.isNotEmpty)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: PopupMenuButton<void>(
                          icon: const Icon(Icons.more_vert),
                          tooltip: 'その他の操作',
                          itemBuilder: (context) => menuItems,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pattern.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// フレームサムネイル(design.md 画面設計・UIフロー章 S-06「サムネイル+パターン名」)。
/// `frameAssetId` が無い場合はプレースホルダアイコンを表示する。
class _Thumbnail extends ConsumerWidget {
  const _Thumbnail({required this.pattern});

  final Pattern pattern;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frameAssetId = pattern.frameAssetId;
    if (frameAssetId == null) {
      return const Center(child: Icon(Icons.auto_awesome, size: 32));
    }
    final urlAsync = ref.watch(patternAssetDownloadUrlProvider(frameAssetId));
    return urlAsync.when(
      data: (url) => CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) =>
            const Icon(Icons.broken_image_outlined),
      ),
      loading: () =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (error, stackTrace) => const Icon(Icons.broken_image_outlined),
    );
  }
}

/// 汎用バッジ(プリセット/NEW共通)。
class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: scheme.tertiary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 9, color: scheme.onTertiary),
      ),
    );
  }
}
