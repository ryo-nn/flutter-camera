import 'package:flutter/material.dart';
import 'package:flutter_camera/src/core/constants/app_sizes.dart';
import 'package:flutter_camera/src/core/models/plan.dart';
import 'package:flutter_camera/src/features/billing/data/firestore_billing_repository.dart'
    show currentPlanProvider;
// `patternsProvider` は data 層(patterns/data/firestore_pattern_repository.dart)に
// 定義されている(design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計
// 「patternsProvider」)。
import 'package:flutter_camera/src/features/patterns/data/firestore_pattern_repository.dart'
    show patternsProvider;
import 'package:flutter_camera/src/features/onboarding/presentation/first_post_guide_provider.dart';
import 'package:flutter_camera/src/features/onboarding/presentation/widgets/first_post_guide_overlay.dart';
import 'package:flutter_camera/src/features/patterns/domain/pattern.dart';
import 'package:flutter_camera/src/features/patterns/presentation/selected_pattern_provider.dart';
import 'package:flutter_camera/src/routing/app_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// パターン選択カルーセル(design.md 画面設計・UIフロー章 S-04 主要UI要素④準拠)。
///
/// 「先頭に『加工なし』、続いて運営プリセット(プリセットバッジ付き)、
/// その後にマイパターン、末尾に『+ パターンを作る』タイル」の構成。
/// 選択状態は `selectedPatternProvider`(patterns feature。撮影→加工画面間で共有)を
/// 直接読み書きする。S-05(加工プレビュー画面)からも「S-04と同一コンポーネント」として
/// 再利用される想定(design.md カメラ・自動加工パイプライン設計 §3.1準拠)。
class PatternCarousel extends ConsumerWidget {
  const PatternCarousel({super.key});

  static const _tileSize = 72.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patternsAsync = ref.watch(patternsProvider);
    final selected = ref.watch(selectedPatternProvider);

    return SizedBox(
      height: _tileSize + 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: patternsAsync.when(
              data: (patterns) =>
                  _PatternTiles(patterns: patterns, selected: selected),
              loading: () => const _SkeletonTiles(),
              error: (error, stackTrace) =>
                  _ErrorTile(onRetry: () => ref.invalidate(patternsProvider)),
            ),
          ),
          // ⑥カルーセル右端の「編集」テキストボタン(パターン管理へ)。
          TextButton(
            onPressed: () => context.pushNamed(AppRoute.patterns.name),
            child: const Text('編集'),
          ),
        ],
      ),
    );
  }
}

class _PatternTiles extends ConsumerWidget {
  const _PatternTiles({required this.patterns, required this.selected});

  final List<Pattern> patterns;
  final Pattern? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 先頭「加工なし」+ パターン一覧 + 末尾「+ パターンを作る」。
    final itemCount = patterns.length + 2;

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.carouselTileSpacing,
      ),
      itemCount: itemCount,
      separatorBuilder: (_, _) =>
          const SizedBox(width: AppSizes.carouselTileSpacing),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _PatternTile(
            label: '加工なし',
            icon: Icons.block,
            isSelected: selected == null,
            onTap: () =>
                ref.read(selectedPatternProvider.notifier).select(null),
          );
        }
        if (index == patterns.length + 1) {
          return _AddPatternTile(
            onTap: () => context.pushNamed(AppRoute.patterns.name),
          );
        }
        final pattern = patterns[index - 1];
        final isSelected = selected?.id == pattern.id;
        final isPreset = pattern.ownerType == PatternOwnerType.preset;
        // design.md リテンション機能設計章「プレミアムパターンのアクセス制御」:
        // Pro未加入時のプレミアムパターンはロック表示とし、タップで適用せず
        // ペイウォール(/plan)へ patternId 付きで遷移する(S-06と同一挙動)。
        final isLocked =
            pattern.isPremium && ref.watch(currentPlanProvider) != Plan.pro;
        final tile = _PatternTile(
          label: pattern.name,
          icon: Icons.auto_awesome,
          isPreset: isPreset,
          isSelected: isSelected,
          isLocked: isLocked,
          onTap: () {
            if (isLocked) {
              context.pushNamed(AppRoute.plan.name, extra: pattern.id);
              return;
            }
            ref.read(selectedPatternProvider.notifier).select(pattern);
            // design.md 第9章「S-04 初回投稿ガイド(コーチマーク)」:
            // プリセットタイルタップで①→②ステップへ進める。
            if (isPreset) {
              ref.read(firstPostGuideProvider.notifier).advanceToShutterStep();
            }
          },
        );
        // カルーセルのプリセットタイルをハイライト対象とする
        // (design.md 第9章「S-04 初回投稿ガイド(コーチマーク)」準拠)。
        return isPreset
            ? FirstPostGuideHighlight(
                step: FirstPostGuideStep.selectPattern,
                child: tile,
              )
            : tile;
      },
    );
  }
}

class _PatternTile extends StatelessWidget {
  const _PatternTile({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.isPreset = false,
    this.isLocked = false,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isPreset;

  /// プレミアムパターンのロック状態(Pro未加入)。ロック中はタップで
  /// ペイウォールへ遷移する(onTap側の責務)。
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // アクセシビリティ配慮: 「パターン名+選択状態」をselectedフラグ付きで通知
    // (design.md 画面設計・UIフロー章「アクセシビリティ配慮」準拠。例:「ナチュラル、選択中」)。
    return Semantics(
      button: true,
      selected: isSelected,
      label: isLocked
          ? '$label、Proプラン限定'
          : isSelected
          ? '$label、選択中'
          : label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: PatternCarousel._tileSize,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: PatternCarousel._tileSize,
                    height: PatternCarousel._tileSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.surfaceContainerHighest,
                      border: isSelected
                          ? Border.all(color: scheme.primary, width: 3)
                          : null,
                    ),
                    child: Icon(icon, color: scheme.onSurfaceVariant),
                  ),
                  if (isPreset)
                    const Positioned(left: -4, top: -4, child: _PresetBadge()),
                  if (isLocked)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: scheme.tertiary,
                        child: Icon(
                          Icons.lock,
                          size: 12,
                          color: scheme.onTertiary,
                        ),
                      ),
                    ),
                  if (isSelected)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: scheme.primary,
                        child: Icon(
                          Icons.check,
                          size: 14,
                          color: scheme.onPrimary,
                        ),
                      ),
                    ),
                ],
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

/// 運営プリセットのタイル左上バッジ(design.md 画面設計・UIフロー章 S-04準拠)。
class _PresetBadge extends StatelessWidget {
  const _PresetBadge();

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
        'プリセット',
        style: TextStyle(fontSize: 9, color: scheme.onTertiary),
      ),
    );
  }
}

class _AddPatternTile extends StatelessWidget {
  const _AddPatternTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const label = 'パターンを作る';
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: PatternCarousel._tileSize,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: PatternCarousel._tileSize,
                height: PatternCarousel._tileSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: scheme.outline),
                ),
                child: Icon(Icons.add, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                '+ $label',
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

/// loading状態: スケルトンタイル(プリセット・マイパターン共通)
/// (design.md 画面設計・UIフロー章 S-04「状態」準拠)。
class _SkeletonTiles extends StatelessWidget {
  const _SkeletonTiles();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.carouselTileSpacing,
      ),
      itemCount: 4,
      separatorBuilder: (_, _) =>
          const SizedBox(width: AppSizes.carouselTileSpacing),
      itemBuilder: (context, index) => Container(
        width: PatternCarousel._tileSize,
        height: PatternCarousel._tileSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }
}

/// error状態: 「パターンを読み込めませんでした」+再読込タイル
/// (design.md 画面設計・UIフロー章 S-04「状態」準拠)。
class _ErrorTile extends StatelessWidget {
  const _ErrorTile({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: const Text('パターンを読み込めませんでした'),
      ),
    );
  }
}
