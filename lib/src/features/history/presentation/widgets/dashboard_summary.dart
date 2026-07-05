import 'package:flutter/material.dart';
// `currentPlanProvider` の実体は billing/data/firestore_billing_repository.dart に
// 定義されている(design.md 課金(IAP)・ペイウォール設計章「feature間参照」節準拠。
// patterns/presentation/pattern_list_screen.dart と同様の既存参照パターンに倣う)。
import 'package:flutter_camera/src/features/billing/data/firestore_billing_repository.dart'
    show currentPlanProvider;
import 'package:flutter_camera/src/features/history/domain/monthly_stats.dart';
import 'package:flutter_camera/src/features/history/domain/pattern_ranking_navigation.dart';
// `patternByIdProvider` は data 層(patterns/data/firestore_pattern_repository.dart)に
// 定義されている(design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計
// 「patternByIdProvider」)。
import 'package:flutter_camera/src/features/patterns/data/firestore_pattern_repository.dart'
    show patternByIdProvider;
import 'package:flutter_camera/src/features/patterns/domain/pattern.dart';
import 'package:flutter_camera/src/features/patterns/presentation/selected_pattern_provider.dart';
import 'package:flutter_camera/src/routing/app_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S-08 投稿履歴画面の成果ダッシュボードサマリー(retention章「成果ダッシュボード(S-08改訂)」
/// 節準拠)。既存の時系列リストの上部に追加するセクションで、リスト仕様・詳細
/// ボトムシートは変更しない。
class DashboardSummary extends ConsumerWidget {
  const DashboardSummary({super.key, required this.stats});

  final MonthlyStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (stats.totalPosts == 0) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('今月はまだ投稿がありません。撮影してみましょう。'),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => context.goNamed(AppRoute.home.name),
              child: const Text('撮影する'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今月の投稿 ${stats.totalPosts}件',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              Chip(
                avatar: const Icon(Icons.camera_alt, size: 18),
                label: Text('Instagram ${stats.instagramSucceeded}件'),
              ),
              Chip(
                avatar: const Icon(Icons.alternate_email, size: 18),
                label: Text('X ${stats.xSucceeded}件'),
              ),
            ],
          ),
          if (stats.patternRanking.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('よく使うパターン', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: stats.patternRanking.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final usage = stats.patternRanking[index];
                  return _PatternRankingTile(
                    name: usage.patternName,
                    count: usage.count,
                    onTap: () =>
                        _handlePatternTap(context, ref, usage.patternId),
                  );
                },
              ),
            ),
          ],
          const Divider(height: 32),
        ],
      ),
    );
  }

  /// 「よく使うパターン」タイルタップ時の処理(retention章「成果ダッシュボード
  /// (S-08改訂)」節準拠)。パターンIDから本体を解決し、
  /// [resolvePatternRankingTapAction] の判定に従って遷移する:
  /// - 通常パターン: 選択状態にしてS-04(ホーム)へ
  /// - プレミアムパターンかつ非Proプラン: 既存のロック挙動(S-10へ`extra`で
  ///   patternIdを渡す)に従う
  /// - 削除済み等で解決できない場合: 何もせずS-04へ
  Future<void> _handlePatternTap(
    BuildContext context,
    WidgetRef ref,
    String patternId,
  ) async {
    Pattern? pattern;
    try {
      pattern = await ref.read(patternByIdProvider(patternId).future);
    } catch (_) {
      // 削除済み等で解決できない場合はnull扱いとし、GoHomeOnlyに委ねる。
      pattern = null;
    }
    if (!context.mounted) return;

    final action = resolvePatternRankingTapAction(
      pattern: pattern,
      currentPlan: ref.read(currentPlanProvider),
    );
    switch (action) {
      case SelectPatternAndGoHome(:final pattern):
        ref.read(selectedPatternProvider.notifier).select(pattern);
        context.goNamed(AppRoute.home.name);
      case NavigateToPaywall(:final patternId):
        context.pushNamed(AppRoute.plan.name, extra: patternId);
      case GoHomeOnly():
        context.goNamed(AppRoute.home.name);
    }
  }
}

class _PatternRankingTile extends StatelessWidget {
  const _PatternRankingTile({
    required this.name,
    required this.count,
    required this.onTap,
  });

  final String name;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$name、$count回使用。タップで撮影画面へ',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 88,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                child: Text(name.isNotEmpty ? name.substring(0, 1) : '?'),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text('$count回', style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}
