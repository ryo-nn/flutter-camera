import 'package:flutter_camera/src/core/models/plan.dart';
import 'package:flutter_camera/src/features/history/domain/pattern_ranking_navigation.dart';
import 'package:flutter_camera/src/features/patterns/domain/filter_params.dart';
import 'package:flutter_camera/src/features/patterns/domain/pattern.dart';
import 'package:flutter_test/flutter_test.dart';

Pattern _pattern({
  required String id,
  bool isPremium = false,
}) {
  final now = DateTime(2026, 1, 1);
  return Pattern(
    id: id,
    ownerType: PatternOwnerType.preset,
    name: 'テストパターン',
    filterParams: const FilterParams(),
    isPremium: isPremium,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('resolvePatternRankingTapAction', () {
    test('通常パターンはSelectPatternAndGoHomeを返す', () {
      final pattern = _pattern(id: 'p1');

      final action = resolvePatternRankingTapAction(
        pattern: pattern,
        currentPlan: Plan.free,
      );

      expect(action, isA<SelectPatternAndGoHome>());
      expect((action as SelectPatternAndGoHome).pattern, pattern);
    });

    test('プレミアムパターン+Proプランは選択してS-04へ遷移する', () {
      final pattern = _pattern(id: 'p1', isPremium: true);

      final action = resolvePatternRankingTapAction(
        pattern: pattern,
        currentPlan: Plan.pro,
      );

      expect(action, isA<SelectPatternAndGoHome>());
    });

    test('プレミアムパターン+非Proプランは既存のロック挙動(S-10へextraで遷移)に従う', () {
      final pattern = _pattern(id: 'p1', isPremium: true);

      final action = resolvePatternRankingTapAction(
        pattern: pattern,
        currentPlan: Plan.light,
      );

      expect(action, isA<NavigateToPaywall>());
      expect((action as NavigateToPaywall).patternId, 'p1');
    });

    test('パターンが削除済み等でnullの場合は何もせずS-04へ遷移する', () {
      final action = resolvePatternRankingTapAction(
        pattern: null,
        currentPlan: Plan.free,
      );

      expect(action, isA<GoHomeOnly>());
    });
  });
}
