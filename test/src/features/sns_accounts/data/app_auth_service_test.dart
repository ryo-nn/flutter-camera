import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_camera/src/features/sns_accounts/data/app_auth_service.dart';
import 'package:flutter_camera/src/features/sns_accounts/domain/sns_authorization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFlutterAppAuth extends Mock implements FlutterAppAuth {}

void main() {
  late MockFlutterAppAuth appAuth;
  late FlutterAppAuthService service;

  setUpAll(() {
    // AuthorizationRequestは issuer/discoveryUrl/serviceConfiguration の
    // いずれかを要求する(flutter_appauth_platform_interfaceの実行時assertで確認済み)
    // ため、フォールバック値にも serviceConfiguration を与える。
    registerFallbackValue(
      AuthorizationRequest(
        'client-id',
        'redirect-uri',
        serviceConfiguration: const AuthorizationServiceConfiguration(
          authorizationEndpoint: 'https://example.com/authorize',
          tokenEndpoint: 'https://example.com/token',
        ),
      ),
    );
  });

  setUp(() {
    appAuth = MockFlutterAppAuth();
    service = FlutterAppAuthService(appAuth);
  });

  group('authorizeInstagram', () {
    test('AuthorizationResponseの値をSnsAuthorizationResultへ写す', () async {
      when(() => appAuth.authorize(any())).thenAnswer(
        (_) async => const AuthorizationResponse(
          authorizationCode: 'ig-code',
          codeVerifier: 'ig-verifier',
        ),
      );

      final result = await service.authorizeInstagram();

      expect(result.authorizationCode, 'ig-code');
      expect(result.codeVerifier, 'ig-verifier');
    });

    test('Instagramのスコープ・認可エンドポイントでAuthorizationRequestを構築する', () async {
      when(() => appAuth.authorize(any())).thenAnswer(
        (_) async => const AuthorizationResponse(authorizationCode: 'code'),
      );

      await service.authorizeInstagram();

      final captured =
          verify(() => appAuth.authorize(captureAny())).captured.single
              as AuthorizationRequest;
      expect(
        captured.scopes,
        containsAll(<String>[
          'instagram_business_basic',
          'instagram_business_content_publish',
        ]),
      );
      expect(
        captured.serviceConfiguration?.authorizationEndpoint,
        'https://www.instagram.com/oauth/authorize',
      );
    });

    test(
      'FlutterAppAuthUserCancelledExceptionをSnsAuthorizationCancelledExceptionへ変換する',
      () async {
        when(() => appAuth.authorize(any())).thenThrow(
          FlutterAppAuthUserCancelledException(
            code: 'cancelled',
            platformErrorDetails: FlutterAppAuthPlatformErrorDetails(),
          ),
        );

        await expectLater(
          () => service.authorizeInstagram(),
          throwsA(isA<SnsAuthorizationCancelledException>()),
        );
      },
    );

    test('authorizationCodeがnullの応答はキャンセル扱いにフォールバックする', () async {
      when(
        () => appAuth.authorize(any()),
      ).thenAnswer((_) async => const AuthorizationResponse());

      await expectLater(
        () => service.authorizeInstagram(),
        throwsA(isA<SnsAuthorizationCancelledException>()),
      );
    });

    test('その他の例外はAppAuth側の例外のまま伝播する(data層で握りつぶさない)', () async {
      when(() => appAuth.authorize(any())).thenThrow(Exception('boom'));

      await expectLater(
        () => service.authorizeInstagram(),
        throwsA(isException),
      );
    });
  });

  group('authorizeX', () {
    test('Xのスコープ・認可エンドポイント・PKCE検証子でAuthorizationRequestを構築する', () async {
      when(() => appAuth.authorize(any())).thenAnswer(
        (_) async => const AuthorizationResponse(
          authorizationCode: 'x-code',
          codeVerifier: 'x-verifier',
        ),
      );

      final result = await service.authorizeX();

      final captured =
          verify(() => appAuth.authorize(captureAny())).captured.single
              as AuthorizationRequest;
      expect(
        captured.scopes,
        containsAll(<String>[
          'tweet.read',
          'tweet.write',
          'users.read',
          'media.write',
          'offline.access',
        ]),
      );
      expect(
        captured.serviceConfiguration?.authorizationEndpoint,
        'https://x.com/i/oauth2/authorize',
      );
      expect(result.codeVerifier, 'x-verifier');
    });
  });
}
