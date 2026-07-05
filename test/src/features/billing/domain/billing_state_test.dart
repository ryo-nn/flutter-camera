import 'package:flutter_camera/src/core/models/plan.dart';
import 'package:flutter_camera/src/features/billing/domain/billing_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BillingState.initial', () {
    test('plan=free・postCredits=0の既定値を返す', () {
      final state = BillingState.initial();

      expect(state.plan, Plan.free);
      expect(state.isTrial, isFalse);
      expect(state.postCredits, 0);
      expect(state.planExpiresAt, isNull);
    });
  });

  group('resolvedPlan', () {
    test('planがfreeなら常にfree', () {
      const state = BillingState(plan: Plan.free);
      expect(state.resolvedPlan(), Plan.free);
    });

    test('planExpiresAtがnull(無期限扱い)ならそのままのplanを返す', () {
      const state = BillingState(plan: Plan.pro);
      expect(state.resolvedPlan(), Plan.pro);
    });

    test('planExpiresAtが未来ならそのままのplanを返す', () {
      final now = DateTime(2026, 7, 4);
      final state = BillingState(
        plan: Plan.pro,
        planExpiresAt: now.add(const Duration(days: 1)),
      );
      expect(state.resolvedPlan(now), Plan.pro);
    });

    test('planExpiresAtが過去なら読み取り時失効ガードによりfreeへ降格する', () {
      final now = DateTime(2026, 7, 4);
      final state = BillingState(
        plan: Plan.pro,
        planExpiresAt: now.subtract(const Duration(days: 1)),
      );
      expect(state.resolvedPlan(now), Plan.free);
    });

    test('planExpiresAtが現在時刻ちょうど(境界値)ならfreeへ降格する', () {
      final now = DateTime(2026, 7, 4, 12);
      final state = BillingState(plan: Plan.light, planExpiresAt: now);
      expect(state.resolvedPlan(now), Plan.free);
    });
  });
}
