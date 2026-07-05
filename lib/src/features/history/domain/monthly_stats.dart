import 'package:flutter_camera/src/features/posting/domain/post.dart';
import 'package:flutter_camera/src/features/posting/domain/post_target_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'monthly_stats.freezed.dart';

/// S-08 成果ダッシュボードの集計モデル(retention章「成果ダッシュボード」節準拠)。
/// Firestore直読みしないため fromJson は不要(design.md記載どおり)。
@freezed
sealed class MonthlyStats with _$MonthlyStats {
  const MonthlyStats._();

  const factory MonthlyStats({
    required int totalPosts,
    required int instagramSucceeded,
    required int xSucceeded,
    required List<PatternUsage> patternRanking, // 上位3件
  }) = _MonthlyStats;

  static const empty = MonthlyStats(
    totalPosts: 0,
    instagramSucceeded: 0,
    xSucceeded: 0,
    patternRanking: [],
  );

  /// 当月(JST基準)の投稿一覧から集計する(retention章「集計定義とモデル」節準拠。
  /// 純Dartの `MonthlyStats.fromPosts(List<Post>, {required DateTime monthStartJst})`
  /// として domain に置き、単体テスト可能にする、との記載どおり)。
  ///
  /// - 今月の投稿数: `overallStatus in (succeeded, partial)` の投稿ドキュメント数。
  /// - Instagram/X成功数: 上記の集合のうち、各ターゲットの `status == succeeded` の数。
  /// - パターンランキング: `patternId` でgroup-byした上位3件。`patternId == null`
  ///   (「加工なし」投稿)は対象外。同数時は直近使用が新しい順。
  static MonthlyStats fromPosts(
    List<Post> posts, {
    required DateTime monthStartJst,
  }) {
    final counted = posts.where((post) {
      final isCurrentMonth = !post.createdAt.isBefore(monthStartJst);
      final isCountedStatus =
          post.overallStatus == PostOverallStatus.succeeded ||
          post.overallStatus == PostOverallStatus.partial;
      return isCurrentMonth && isCountedStatus;
    }).toList();

    final instagramSucceeded = counted
        .where((post) => post.instagram.status == PostTargetStatus.succeeded)
        .length;
    final xSucceeded = counted
        .where((post) => post.x.status == PostTargetStatus.succeeded)
        .length;

    final accumulators = <String, _PatternAccumulator>{};
    for (final post in counted) {
      final patternId = post.patternId;
      if (patternId == null) continue;
      final existing = accumulators[patternId];
      if (existing == null) {
        accumulators[patternId] = _PatternAccumulator(
          name: post.patternName ?? '',
          count: 1,
          lastUsedAt: post.createdAt,
        );
      } else {
        accumulators[patternId] = _PatternAccumulator(
          name: existing.name,
          count: existing.count + 1,
          lastUsedAt: existing.lastUsedAt.isAfter(post.createdAt)
              ? existing.lastUsedAt
              : post.createdAt,
        );
      }
    }

    final ranking =
        accumulators.entries
            .map(
              (e) => (
                usage: PatternUsage(
                  patternId: e.key,
                  patternName: e.value.name,
                  count: e.value.count,
                ),
                lastUsedAt: e.value.lastUsedAt,
              ),
            )
            .toList()
          ..sort((a, b) {
            final byCount = b.usage.count.compareTo(a.usage.count);
            if (byCount != 0) return byCount;
            return b.lastUsedAt.compareTo(a.lastUsedAt);
          });

    return MonthlyStats(
      totalPosts: counted.length,
      instagramSucceeded: instagramSucceeded,
      xSucceeded: xSucceeded,
      patternRanking: ranking.take(3).map((e) => e.usage).toList(),
    );
  }
}

class _PatternAccumulator {
  const _PatternAccumulator({
    required this.name,
    required this.count,
    required this.lastUsedAt,
  });

  final String name;
  final int count;
  final DateTime lastUsedAt;
}

/// パターンランキングの1項目(retention章「Freezedモデル追加」節・コード例準拠)。
@freezed
sealed class PatternUsage with _$PatternUsage {
  const factory PatternUsage({
    required String patternId,
    required String patternName,
    required int count,
  }) = _PatternUsage;
}
