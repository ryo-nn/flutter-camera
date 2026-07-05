import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/core/models/sns_provider.dart';
import 'package:flutter_camera/src/features/sns_accounts/data/functions_sns_account_repository.dart';
import 'package:flutter_camera/src/features/sns_accounts/domain/sns_connection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class MockHttpsCallable extends Mock implements HttpsCallable {}

class MockHttpsCallableResult extends Mock
    implements HttpsCallableResult<Map<String, dynamic>> {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late MockFirebaseFunctions functions;
  late MockFirebaseFirestore firestore;
  late MockHttpsCallable callable;
  late FunctionsSnsAccountRepository repository;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    functions = MockFirebaseFunctions();
    firestore = MockFirebaseFirestore();
    callable = MockHttpsCallable();
    repository = FunctionsSnsAccountRepository(functions, firestore, 'uid-1');
  });

  group('exchangeInstagramCode', () {
    test('igExchangeTokenをcode/redirectUriで呼び出す', () async {
      when(
        () => functions.httpsCallable('igExchangeToken'),
      ).thenReturn(callable);
      final result = MockHttpsCallableResult();
      when(() => result.data).thenReturn(<String, dynamic>{});
      when(
        () => callable.call<Map<String, dynamic>>(any()),
      ).thenAnswer((_) async => result);

      await repository.exchangeInstagramCode(
        code: 'auth-code',
        redirectUri: 'app://redirect',
      );

      final captured =
          verify(
                () => callable.call<Map<String, dynamic>>(captureAny()),
              ).captured.single
              as Map<String, dynamic>;
      expect(captured['code'], 'auth-code');
      expect(captured['redirectUri'], 'app://redirect');
      expect(captured.containsKey('codeVerifier'), isFalse);
    });

    test(
      'IG_NOT_PROFESSIONAL_ACCOUNTはrequiresProAccount=trueのSnsAuthExceptionへ変換する',
      () async {
        when(
          () => functions.httpsCallable('igExchangeToken'),
        ).thenReturn(callable);
        when(() => callable.call<Map<String, dynamic>>(any())).thenThrow(
          FirebaseFunctionsException(
            code: 'failed-precondition',
            message: 'not professional',
            details: {'reason': 'IG_NOT_PROFESSIONAL_ACCOUNT'},
          ),
        );

        await expectLater(
          () => repository.exchangeInstagramCode(
            code: 'auth-code',
            redirectUri: 'app://redirect',
          ),
          throwsA(
            isA<SnsAuthException>()
                .having((e) => e.provider, 'provider', SnsProvider.instagram)
                .having(
                  (e) => e.requiresProAccount,
                  'requiresProAccount',
                  isTrue,
                ),
          ),
        );
      },
    );

    test('その他のreasonはrequiresProAccount=falseのSnsAuthExceptionへ変換する', () async {
      when(
        () => functions.httpsCallable('igExchangeToken'),
      ).thenReturn(callable);
      when(() => callable.call<Map<String, dynamic>>(any())).thenThrow(
        FirebaseFunctionsException(
          code: 'internal',
          message: 'boom',
          details: {'reason': 'SOME_OTHER_REASON'},
        ),
      );

      await expectLater(
        () => repository.exchangeInstagramCode(
          code: 'auth-code',
          redirectUri: 'app://redirect',
        ),
        throwsA(
          isA<SnsAuthException>().having(
            (e) => e.requiresProAccount,
            'requiresProAccount',
            isFalse,
          ),
        ),
      );
    });
  });

  group('exchangeXCode', () {
    test('xExchangeTokenをcode/codeVerifier/redirectUriで呼び出す', () async {
      when(
        () => functions.httpsCallable('xExchangeToken'),
      ).thenReturn(callable);
      final result = MockHttpsCallableResult();
      when(() => result.data).thenReturn(<String, dynamic>{});
      when(
        () => callable.call<Map<String, dynamic>>(any()),
      ).thenAnswer((_) async => result);

      await repository.exchangeXCode(
        code: 'x-code',
        codeVerifier: 'verifier',
        redirectUri: 'app://redirect',
      );

      final captured =
          verify(
                () => callable.call<Map<String, dynamic>>(captureAny()),
              ).captured.single
              as Map<String, dynamic>;
      expect(captured['code'], 'x-code');
      expect(captured['codeVerifier'], 'verifier');
      expect(captured['redirectUri'], 'app://redirect');
    });
  });

  group('disconnect', () {
    test('snsDisconnectをprovider名の生値(小文字)で呼び出す', () async {
      when(() => functions.httpsCallable('snsDisconnect')).thenReturn(callable);
      final result = MockHttpsCallableResult();
      when(() => result.data).thenReturn(<String, dynamic>{});
      when(
        () => callable.call<Map<String, dynamic>>(any()),
      ).thenAnswer((_) async => result);

      await repository.disconnect(SnsProvider.x);

      final captured =
          verify(
                () => callable.call<Map<String, dynamic>>(captureAny()),
              ).captured.single
              as Map<String, dynamic>;
      expect(captured['provider'], 'x');
    });
  });

  group('watchConnections', () {
    test('Firestoreの各ドキュメントをSnsConnectionへ変換する', () async {
      final collection = MockCollectionReference();
      final snapshot = MockQuerySnapshot();
      final instagramDoc = MockQueryDocumentSnapshot();
      final xDoc = MockQueryDocumentSnapshot();

      when(
        () => firestore.collection('users/uid-1/snsConnections'),
      ).thenReturn(collection);
      when(
        () => collection.snapshots(),
      ).thenAnswer((_) => Stream.value(snapshot));
      when(() => snapshot.docs).thenReturn([instagramDoc, xDoc]);

      when(() => instagramDoc.id).thenReturn('instagram');
      when(() => instagramDoc.data()).thenReturn({
        'provider': 'instagram',
        'status': 'connected',
        'username': 'nanami_ig',
        'accountType': 'business',
        'updatedAt': Timestamp.fromDate(DateTime.utc(2026, 1, 1)),
      });

      when(() => xDoc.id).thenReturn('x');
      when(() => xDoc.data()).thenReturn({
        'provider': 'x',
        'status': 'expired',
        'username': 'nanami_x',
      });

      final connections = await repository.watchConnections().first;

      expect(connections, hasLength(2));
      final instagram = connections.firstWhere(
        (c) => c.provider == SnsProvider.instagram,
      );
      expect(instagram.status, SnsConnectionStatus.connected);
      expect(instagram.username, 'nanami_ig');
      // account_typeの大文字小文字を区別しない判定(backend章準拠)。
      expect(instagram.isProAccount, isTrue);
      // Timestamp.toDate()はローカルタイムゾーンのDateTimeを返す仕様
      // (cloud_firestore_platform_interfaceの公式実装準拠)のため、
      // 時刻(瞬間)の一致で比較する。
      expect(
        instagram.updatedAt?.isAtSameMomentAs(DateTime.utc(2026, 1, 1)),
        isTrue,
      );

      final x = connections.firstWhere((c) => c.provider == SnsProvider.x);
      expect(x.status, SnsConnectionStatus.expired);
      expect(x.isProAccount, isNull);
    });
  });
}
