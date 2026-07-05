import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/features/auth/data/firebase_auth_repository.dart';
import 'package:flutter_camera/src/features/auth/domain/auth_repository.dart';
import 'package:flutter_camera/src/features/auth/presentation/sign_in_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository authRepository;
  late ProviderContainer container;

  setUp(() {
    authRepository = MockAuthRepository();
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(authRepository)],
    );
    addTearDown(container.dispose);
  });

  test('build完了後の初期状態はAsyncData(null)(idle)である', () async {
    await container.read(signInControllerProvider.future);
    expect(
      container.read(signInControllerProvider),
      const AsyncData<void>(null),
    );
  });

  test(
    'signIn成功時はAuthRepository.signInWithEmailAndPasswordを呼びAsyncDataになる',
    () async {
      when(
        () => authRepository.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {});

      container.read(signInControllerProvider);
      await container
          .read(signInControllerProvider.notifier)
          .signIn(email: 'user@example.com', password: 'password123');

      final state = container.read(signInControllerProvider);
      expect(state.hasError, isFalse);
      expect(state.isLoading, isFalse);
      verify(
        () => authRepository.signInWithEmailAndPassword(
          email: 'user@example.com',
          password: 'password123',
        ),
      ).called(1);
    },
  );

  test('signIn失敗時はAsyncError(AuthException)になる', () async {
    when(
      () => authRepository.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(
      const AuthException('メールアドレスまたはパスワードが正しくありません。', code: 'wrong-password'),
    );

    container.read(signInControllerProvider);
    await container
        .read(signInControllerProvider.notifier)
        .signIn(email: 'user@example.com', password: 'wrong-password');

    final state = container.read(signInControllerProvider);
    expect(state.hasError, isTrue);
    expect(
      state.error,
      isA<AuthException>().having((e) => e.code, 'code', 'wrong-password'),
    );
  });

  test(
    'signUp成功時はAuthRepository.signUpWithEmailAndPasswordを呼びAsyncDataになる',
    () async {
      when(
        () => authRepository.signUpWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {});

      container.read(signInControllerProvider);
      await container
          .read(signInControllerProvider.notifier)
          .signUp(email: 'new@example.com', password: 'password123');

      verify(
        () => authRepository.signUpWithEmailAndPassword(
          email: 'new@example.com',
          password: 'password123',
        ),
      ).called(1);
      expect(container.read(signInControllerProvider).hasError, isFalse);
    },
  );

  test('signUp失敗時はAsyncError(AuthException)になる', () async {
    when(
      () => authRepository.signUpWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(
      const AuthException(
        'このメールアドレスは登録済みです。ログインをお試しください。',
        code: 'email-already-in-use',
      ),
    );

    container.read(signInControllerProvider);
    await container
        .read(signInControllerProvider.notifier)
        .signUp(email: 'exists@example.com', password: 'password123');

    final state = container.read(signInControllerProvider);
    expect(state.hasError, isTrue);
    expect(
      state.error,
      isA<AuthException>().having(
        (e) => e.code,
        'code',
        'email-already-in-use',
      ),
    );
  });
}
