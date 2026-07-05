import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/features/auth/data/firebase_auth_repository.dart';
import 'package:flutter_camera/src/features/auth/domain/auth_repository.dart';
import 'package:flutter_camera/src/features/auth/presentation/phone_verification_controller.dart';
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
    await container.read(phoneVerificationControllerProvider.future);
    expect(
      container.read(phoneVerificationControllerProvider),
      const AsyncData<void>(null),
    );
  });

  group('sendCode', () {
    test('onCodeSentが呼ばれるとAsyncData(null)になり、値をコールバックへ渡す', () async {
      when(
        () => authRepository.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          forceResendingToken: any(named: 'forceResendingToken'),
          onCodeSent: any(named: 'onCodeSent'),
          onAutoVerified: any(named: 'onAutoVerified'),
          onVerificationFailed: any(named: 'onVerificationFailed'),
          onCodeAutoRetrievalTimeout: any(named: 'onCodeAutoRetrievalTimeout'),
        ),
      ).thenAnswer((invocation) async {
        final onCodeSent =
            invocation.namedArguments[#onCodeSent]
                as void Function(String, int?);
        onCodeSent('verification-id-1', 42);
      });

      container.read(phoneVerificationControllerProvider);
      String? receivedVerificationId;
      await container
          .read(phoneVerificationControllerProvider.notifier)
          .sendCode(
            phoneNumber: '+819012345678',
            onCodeSent: (verificationId, _) =>
                receivedVerificationId = verificationId,
            onAutoVerified: () {},
            onCodeAutoRetrievalTimeout: (_) {},
          );

      expect(receivedVerificationId, 'verification-id-1');
      final state = container.read(phoneVerificationControllerProvider);
      expect(state.hasError, isFalse);
      expect(state.isLoading, isFalse);
    });

    test('onAutoVerifiedが呼ばれるとAsyncData(null)になり、コールバックを呼ぶ', () async {
      when(
        () => authRepository.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          forceResendingToken: any(named: 'forceResendingToken'),
          onCodeSent: any(named: 'onCodeSent'),
          onAutoVerified: any(named: 'onAutoVerified'),
          onVerificationFailed: any(named: 'onVerificationFailed'),
          onCodeAutoRetrievalTimeout: any(named: 'onCodeAutoRetrievalTimeout'),
        ),
      ).thenAnswer((invocation) async {
        final onAutoVerified =
            invocation.namedArguments[#onAutoVerified] as void Function();
        onAutoVerified();
      });

      container.read(phoneVerificationControllerProvider);
      var autoVerifiedCalled = false;
      await container
          .read(phoneVerificationControllerProvider.notifier)
          .sendCode(
            phoneNumber: '+819012345678',
            onCodeSent: (_, _) {},
            onAutoVerified: () => autoVerifiedCalled = true,
            onCodeAutoRetrievalTimeout: (_) {},
          );

      expect(autoVerifiedCalled, isTrue);
      expect(container.read(phoneVerificationControllerProvider).hasError, isFalse);
    });

    test('onVerificationFailedが呼ばれるとAsyncError(AuthException)になる', () async {
      when(
        () => authRepository.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          forceResendingToken: any(named: 'forceResendingToken'),
          onCodeSent: any(named: 'onCodeSent'),
          onAutoVerified: any(named: 'onAutoVerified'),
          onVerificationFailed: any(named: 'onVerificationFailed'),
          onCodeAutoRetrievalTimeout: any(named: 'onCodeAutoRetrievalTimeout'),
        ),
      ).thenAnswer((invocation) async {
        final onVerificationFailed =
            invocation.namedArguments[#onVerificationFailed]
                as void Function(AuthException);
        onVerificationFailed(
          const AuthException('SMSの送信に失敗しました', code: 'invalid-phone-number'),
        );
      });

      container.read(phoneVerificationControllerProvider);
      await container
          .read(phoneVerificationControllerProvider.notifier)
          .sendCode(
            phoneNumber: 'invalid',
            onCodeSent: (_, _) {},
            onAutoVerified: () {},
            onCodeAutoRetrievalTimeout: (_) {},
          );

      final state = container.read(phoneVerificationControllerProvider);
      expect(state.hasError, isTrue);
      expect(
        state.error,
        isA<AuthException>().having(
          (e) => e.code,
          'code',
          'invalid-phone-number',
        ),
      );
    });

    test('verifyPhoneNumber自体が例外を投げた場合もAsyncErrorになる', () async {
      when(
        () => authRepository.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          forceResendingToken: any(named: 'forceResendingToken'),
          onCodeSent: any(named: 'onCodeSent'),
          onAutoVerified: any(named: 'onAutoVerified'),
          onVerificationFailed: any(named: 'onVerificationFailed'),
          onCodeAutoRetrievalTimeout: any(named: 'onCodeAutoRetrievalTimeout'),
        ),
      ).thenThrow(
        const AuthException('SMSの送信に失敗しました', code: 'operation-not-allowed'),
      );

      container.read(phoneVerificationControllerProvider);
      await container
          .read(phoneVerificationControllerProvider.notifier)
          .sendCode(
            phoneNumber: '+819012345678',
            onCodeSent: (_, _) {},
            onAutoVerified: () {},
            onCodeAutoRetrievalTimeout: (_) {},
          );

      final state = container.read(phoneVerificationControllerProvider);
      expect(state.hasError, isTrue);
      expect(
        state.error,
        isA<AuthException>().having(
          (e) => e.code,
          'code',
          'operation-not-allowed',
        ),
      );
    });
  });

  group('confirmCode', () {
    test('成功時はAsyncDataになる', () async {
      when(
        () => authRepository.confirmPhoneNumberVerificationCode(
          verificationId: any(named: 'verificationId'),
          smsCode: any(named: 'smsCode'),
        ),
      ).thenAnswer((_) async {});

      container.read(phoneVerificationControllerProvider);
      await container
          .read(phoneVerificationControllerProvider.notifier)
          .confirmCode(verificationId: 'verification-id-1', smsCode: '123456');

      final state = container.read(phoneVerificationControllerProvider);
      expect(state.hasError, isFalse);
      expect(state.isLoading, isFalse);
      verify(
        () => authRepository.confirmPhoneNumberVerificationCode(
          verificationId: 'verification-id-1',
          smsCode: '123456',
        ),
      ).called(1);
    });

    test('失敗時はAsyncError(AuthException)になる', () async {
      when(
        () => authRepository.confirmPhoneNumberVerificationCode(
          verificationId: any(named: 'verificationId'),
          smsCode: any(named: 'smsCode'),
        ),
      ).thenThrow(
        const AuthException('認証コードが正しくありません', code: 'invalid-verification-code'),
      );

      container.read(phoneVerificationControllerProvider);
      await container
          .read(phoneVerificationControllerProvider.notifier)
          .confirmCode(verificationId: 'verification-id-1', smsCode: '000000');

      final state = container.read(phoneVerificationControllerProvider);
      expect(state.hasError, isTrue);
      expect(
        state.error,
        isA<AuthException>().having(
          (e) => e.code,
          'code',
          'invalid-verification-code',
        ),
      );
    });
  });
}
