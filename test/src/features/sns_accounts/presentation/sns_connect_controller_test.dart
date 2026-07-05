import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/core/models/sns_provider.dart';
import 'package:flutter_camera/src/features/sns_accounts/data/app_auth_service.dart';
import 'package:flutter_camera/src/features/sns_accounts/data/functions_sns_account_repository.dart';
import 'package:flutter_camera/src/features/sns_accounts/domain/sns_account_repository.dart';
import 'package:flutter_camera/src/features/sns_accounts/domain/sns_authorization.dart';
import 'package:flutter_camera/src/features/sns_accounts/presentation/sns_connect_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAppAuthService extends Mock implements AppAuthService {}

class MockSnsAccountRepository extends Mock implements SnsAccountRepository {}

void main() {
  late MockAppAuthService appAuthService;
  late MockSnsAccountRepository repository;
  late ProviderContainer container;

  setUp(() {
    appAuthService = MockAppAuthService();
    repository = MockSnsAccountRepository();
    container = ProviderContainer(
      overrides: [
        appAuthServiceProvider.overrideWithValue(appAuthService),
        snsAccountRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
  });

  test('build完了後の初期状態はAsyncData(null)(idle)である', () async {
    await container.read(
      snsConnectControllerProvider(SnsProvider.instagram).future,
    );

    expect(
      container.read(snsConnectControllerProvider(SnsProvider.instagram)),
      const AsyncData<void>(null),
    );
  });

  group('connect (Instagram)', () {
    test('認可コード取得→igExchangeToken呼び出しの順で実行しAsyncDataになる', () async {
      when(() => appAuthService.authorizeInstagram()).thenAnswer(
        (_) async => const SnsAuthorizationResult(
          authorizationCode: 'ig-code',
          codeVerifier: null,
          redirectUri: 'app://ig-redirect',
        ),
      );
      when(
        () => repository.exchangeInstagramCode(
          code: any(named: 'code'),
          redirectUri: any(named: 'redirectUri'),
        ),
      ).thenAnswer((_) async {});

      container.read(snsConnectControllerProvider(SnsProvider.instagram));
      await container
          .read(snsConnectControllerProvider(SnsProvider.instagram).notifier)
          .connect();

      verify(
        () => repository.exchangeInstagramCode(
          code: 'ig-code',
          redirectUri: 'app://ig-redirect',
        ),
      ).called(1);
      final state = container.read(
        snsConnectControllerProvider(SnsProvider.instagram),
      );
      expect(state.hasError, isFalse);
      expect(state.isLoading, isFalse);
    });

    test(
      'ユーザーがキャンセルした場合はAsyncErrorにせずSnsAuthorizationCancelledExceptionをrethrowする',
      () async {
        when(
          () => appAuthService.authorizeInstagram(),
        ).thenThrow(const SnsAuthorizationCancelledException());

        container.read(snsConnectControllerProvider(SnsProvider.instagram));

        await expectLater(
          () => container
              .read(
                snsConnectControllerProvider(SnsProvider.instagram).notifier,
              )
              .connect(),
          throwsA(isA<SnsAuthorizationCancelledException>()),
        );

        final state = container.read(
          snsConnectControllerProvider(SnsProvider.instagram),
        );
        expect(state.hasError, isFalse);
        expect(state, const AsyncData<void>(null));
      },
    );

    test(
      'igExchangeToken失敗時はAsyncError(SnsAuthException)になる(呼び出し元へrethrowしない)',
      () async {
        when(() => appAuthService.authorizeInstagram()).thenAnswer(
          (_) async => const SnsAuthorizationResult(
            authorizationCode: 'ig-code',
            codeVerifier: null,
            redirectUri: 'app://ig-redirect',
          ),
        );
        when(
          () => repository.exchangeInstagramCode(
            code: any(named: 'code'),
            redirectUri: any(named: 'redirectUri'),
          ),
        ).thenThrow(
          const SnsAuthException(
            'プロアカウントが必要です',
            provider: SnsProvider.instagram,
            requiresProAccount: true,
          ),
        );

        container.read(snsConnectControllerProvider(SnsProvider.instagram));
        // 呼び出し元(画面)は個別にcatchしないため、connect()自体はエラーを外へ投げない。
        await container
            .read(snsConnectControllerProvider(SnsProvider.instagram).notifier)
            .connect();

        final state = container.read(
          snsConnectControllerProvider(SnsProvider.instagram),
        );
        expect(state.hasError, isTrue);
        expect(
          state.error,
          isA<SnsAuthException>().having(
            (e) => e.requiresProAccount,
            'requiresProAccount',
            isTrue,
          ),
        );
      },
    );
  });

  group('connect (X)', () {
    test('認可コード+PKCE検証子取得→xExchangeToken呼び出しの順で実行する', () async {
      when(() => appAuthService.authorizeX()).thenAnswer(
        (_) async => const SnsAuthorizationResult(
          authorizationCode: 'x-code',
          codeVerifier: 'x-verifier',
          redirectUri: 'app://x-redirect',
        ),
      );
      when(
        () => repository.exchangeXCode(
          code: any(named: 'code'),
          codeVerifier: any(named: 'codeVerifier'),
          redirectUri: any(named: 'redirectUri'),
        ),
      ).thenAnswer((_) async {});

      container.read(snsConnectControllerProvider(SnsProvider.x));
      await container
          .read(snsConnectControllerProvider(SnsProvider.x).notifier)
          .connect();

      verify(
        () => repository.exchangeXCode(
          code: 'x-code',
          codeVerifier: 'x-verifier',
          redirectUri: 'app://x-redirect',
        ),
      ).called(1);
      verifyNever(() => appAuthService.authorizeInstagram());
    });
  });

  group('disconnect', () {
    test('成功時はrepository.disconnectを対象providerで呼びAsyncDataになる', () async {
      when(() => repository.disconnect(SnsProvider.x)).thenAnswer((_) async {});

      container.read(snsConnectControllerProvider(SnsProvider.x));
      await container
          .read(snsConnectControllerProvider(SnsProvider.x).notifier)
          .disconnect();

      verify(() => repository.disconnect(SnsProvider.x)).called(1);
      final state = container.read(snsConnectControllerProvider(SnsProvider.x));
      expect(state.hasError, isFalse);
    });

    test('失敗時はAsyncErrorになる', () async {
      when(() => repository.disconnect(SnsProvider.instagram)).thenThrow(
        const SnsAuthException('連携解除に失敗しました', provider: SnsProvider.instagram),
      );

      container.read(snsConnectControllerProvider(SnsProvider.instagram));
      await container
          .read(snsConnectControllerProvider(SnsProvider.instagram).notifier)
          .disconnect();

      final state = container.read(
        snsConnectControllerProvider(SnsProvider.instagram),
      );
      expect(state.hasError, isTrue);
      expect(state.error, isA<SnsAuthException>());
    });
  });
}
