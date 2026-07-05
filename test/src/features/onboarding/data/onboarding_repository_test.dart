import 'package:flutter_camera/src/features/onboarding/data/onboarding_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnboardingRepository', () {
    setUp(() {
      // 公式のテスト用インメモリストア(shared_preferences 2.5.5 実装で確認済み。
      // `SharedPreferencesStorePlatform.instance` を差し替える)。
      SharedPreferences.setMockInitialValues({});
    });

    test('isCompleted は未設定時に false を返す', () async {
      final repository = OnboardingRepository();

      expect(await repository.isCompleted(), isFalse);
    });

    test('setCompleted 後は isCompleted が true を返す', () async {
      final repository = OnboardingRepository();

      await repository.setCompleted();

      expect(await repository.isCompleted(), isTrue);
    });

    test('isFirstPostGuideSkipped は未設定時に false を返す', () async {
      final repository = OnboardingRepository();

      expect(await repository.isFirstPostGuideSkipped(), isFalse);
    });

    test('skipFirstPostGuide 後は isFirstPostGuideSkipped が true を返す', () async {
      final repository = OnboardingRepository();

      await repository.skipFirstPostGuide();

      expect(await repository.isFirstPostGuideSkipped(), isTrue);
    });

    test('完了フラグとコーチマークスキップフラグは独立したキーで管理される', () async {
      final repository = OnboardingRepository();

      await repository.setCompleted();

      expect(await repository.isCompleted(), isTrue);
      expect(await repository.isFirstPostGuideSkipped(), isFalse);
    });

    test('isFirstCompletionCelebrationShown は未設定時に false を返す', () async {
      final repository = OnboardingRepository();

      expect(await repository.isFirstCompletionCelebrationShown(), isFalse);
    });

    test(
      'markFirstCompletionCelebrationShown 後は '
      'isFirstCompletionCelebrationShown が true を返す',
      () async {
        final repository = OnboardingRepository();

        await repository.markFirstCompletionCelebrationShown();

        expect(await repository.isFirstCompletionCelebrationShown(), isTrue);
      },
    );

    test('初回投稿完了演出の表示済みフラグは他の2つのフラグと独立したキーで管理される', () async {
      final repository = OnboardingRepository();

      await repository.markFirstCompletionCelebrationShown();

      expect(await repository.isFirstCompletionCelebrationShown(), isTrue);
      expect(await repository.isCompleted(), isFalse);
      expect(await repository.isFirstPostGuideSkipped(), isFalse);
    });
  });
}
