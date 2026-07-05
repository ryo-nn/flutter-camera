import 'package:flutter_camera/src/core/models/plan.dart';
import 'package:flutter_camera/src/features/patterns/domain/pattern.dart';

/// S-08「よく使うパターン」タイルタップ時の遷移先決定(retention章「成果ダッシュボード
/// (S-08改訂)」節「タップで該当パターンを選択した状態のS-04へ遷移」準拠)。
///
/// BuildContext/ref に依存しない純関数として切り出し、単体テスト可能にする
/// (`history/domain/monthly_stats.dart` の `MonthlyStats.fromPosts` と同様の方針)。
sealed class PatternRankingTapAction {
  const PatternRankingTapAction();
}

/// パターンを選択状態にしてS-04(ホーム)へ遷移する。
final class SelectPatternAndGoHome extends PatternRankingTapAction {
  const SelectPatternAndGoHome(this.pattern);
  final Pattern pattern;
}

/// プレミアムパターンかつ現在のプランがProでないため、S-10(ペイウォール)へ
/// `patternId` を `extra` として渡して遷移する(第9章 追補「プレミアムパターンの
/// ロックタイルタップ(S-04/S-06)」節「S-10へ遷移(`extra` でpatternIdを渡す)」準拠)。
final class NavigateToPaywall extends PatternRankingTapAction {
  const NavigateToPaywall(this.patternId);
  final String patternId;
}

/// パターンが削除済み等で解決できないため、何もせずS-04へ遷移する。
final class GoHomeOnly extends PatternRankingTapAction {
  const GoHomeOnly();
}

/// [pattern] はタップされたパターンIDから取得を試みた結果(削除済み・取得失敗時は
/// `null`)。[currentPlan] は現在のプラン(`currentPlanProvider` 準拠)。
PatternRankingTapAction resolvePatternRankingTapAction({
  required Pattern? pattern,
  required Plan currentPlan,
}) {
  if (pattern == null) return const GoHomeOnly();
  if (pattern.isPremium && currentPlan != Plan.pro) {
    return NavigateToPaywall(pattern.id);
  }
  return SelectPatternAndGoHome(pattern);
}
