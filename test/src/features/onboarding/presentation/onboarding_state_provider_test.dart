import 'package:flutter_camera/src/features/onboarding/data/onboarding_repository.dart';
import 'package:flutter_camera/src/features/onboarding/presentation/onboarding_state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockOnboardingRepository extends Mock implements OnboardingRepository {}

void main() {
  late _MockOnboardingRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _MockOnboardingRepository();
    when(() => repository.setCompleted()).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        onboardingRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
  });

  group('onboardingStateProvider', () {
    test('初期値は false(復元前の安全な既定値)', () {
      expect(container.read(onboardingStateProvider), isFalse);
    });

    test('restore は永続化を伴わず state のみ反映する(appStartupProvider専用)', () {
      container.read(onboardingStateProvider.notifier).restore(true);

      expect(container.read(onboardingStateProvider), isTrue);
      verifyNever(() => repository.setCompleted());
    });

    test('complete は state を true にし、リポジトリへ永続化する', () async {
      await container.read(onboardingStateProvider.notifier).complete();

      expect(container.read(onboardingStateProvider), isTrue);
      verify(() => repository.setCompleted()).called(1);
    });
  });
}
