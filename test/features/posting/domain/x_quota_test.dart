import 'package:flutter_camera/src/core/models/plan.dart';
import 'package:flutter_camera/src/features/posting/domain/x_quota.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('XQuota', () {
    test('monthlyRemaining/dailyRemainingは上限-使用量(負値は0にクランプ)', () {
      const quota = XQuota(
        plan: Plan.light,
        monthlyLimit: 30,
        monthlyUsed: 35,
        dailyLimit: 10,
        dailyUsed: 3,
        creditBalance: 0,
      );
      expect(quota.monthlyRemaining, 0);
      expect(quota.dailyRemaining, 7);
    });

    test('totalRemainingは月次残+クレジット残', () {
      const quota = XQuota(
        plan: Plan.pro,
        monthlyLimit: 150,
        monthlyUsed: 140,
        dailyLimit: 30,
        dailyUsed: 5,
        creditBalance: 20,
      );
      expect(quota.totalRemaining, 30);
    });

    test('月次残・クレジット残がともに0ならisExhausted', () {
      const quota = XQuota(
        plan: Plan.free,
        monthlyLimit: 3,
        monthlyUsed: 3,
        dailyLimit: 2,
        dailyUsed: 0,
        creditBalance: 0,
      );
      expect(quota.isExhausted, isTrue);
    });

    test('日次残が0ならクレジットが残っていてもisExhausted', () {
      const quota = XQuota(
        plan: Plan.pro,
        monthlyLimit: 150,
        monthlyUsed: 10,
        dailyLimit: 30,
        dailyUsed: 30,
        creditBalance: 50,
      );
      expect(quota.isExhausted, isTrue);
    });

    test('残数がある場合はisExhausted=false', () {
      const quota = XQuota(
        plan: Plan.light,
        monthlyLimit: 30,
        monthlyUsed: 10,
        dailyLimit: 10,
        dailyUsed: 2,
        creditBalance: 0,
      );
      expect(quota.isExhausted, isFalse);
    });

    test('日次残が月次残より小さい場合はshouldShowDailyHint=true', () {
      const quota = XQuota(
        plan: Plan.pro,
        monthlyLimit: 150,
        monthlyUsed: 10,
        dailyLimit: 30,
        dailyUsed: 29,
        creditBalance: 0,
      );
      expect(quota.shouldShowDailyHint, isTrue);
    });
  });
}
