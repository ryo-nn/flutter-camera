import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/core/models/plan.dart';
import 'package:flutter_camera/src/features/billing/data/firestore_billing_repository.dart';
import 'package:flutter_camera/src/features/billing/domain/billing_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class MockHttpsCallable extends Mock implements HttpsCallable {}

class MockHttpsCallableResult extends Mock
    implements HttpsCallableResult<Map<String, dynamic>> {}

void main() {
  late MockFirebaseFirestore firestore;
  late MockDocumentReference docRef;
  late MockFirebaseFunctions functions;
  late FirestoreBillingRepository repository;

  const uid = 'uid-1';

  setUp(() {
    firestore = MockFirebaseFirestore();
    docRef = MockDocumentReference();
    functions = MockFirebaseFunctions();
    when(() => firestore.doc('users/$uid/billing/state')).thenReturn(docRef);
    repository = FirestoreBillingRepository(firestore, functions, uid);
  });

  group('watchBillingState', () {
    test('ドキュメント不存在時はBillingState.initial()を発行する', () async {
      final snapshot = MockDocumentSnapshot();
      when(() => snapshot.data()).thenReturn(null);
      when(() => docRef.snapshots()).thenAnswer((_) => Stream.value(snapshot));

      final state = await repository.watchBillingState().first;

      expect(state, BillingState.initial());
    });

    test('ドキュメント存在時はFirestoreの値からBillingStateを組み立てる', () async {
      final snapshot = MockDocumentSnapshot();
      when(() => snapshot.data()).thenReturn({
        'plan': 'pro',
        'isTrial': true,
        'planProductId': 'fcam_pro_1m',
        'planExpiresAt': Timestamp.fromDate(DateTime.utc(2026, 8, 1)),
        'postCredits': 5,
        'updatedAt': Timestamp.fromDate(DateTime.utc(2026, 7, 1)),
      });
      when(() => docRef.snapshots()).thenAnswer((_) => Stream.value(snapshot));

      final state = await repository.watchBillingState().first;

      expect(state.plan, Plan.pro);
      expect(state.isTrial, isTrue);
      expect(state.postCredits, 5);
      // Timestamp.toDate()はローカルタイムゾーンのDateTimeを返す仕様
      // (cloud_firestore_platform_interfaceの公式実装準拠)のため、
      // 時刻(瞬間)の一致で比較する。
      expect(
        state.planExpiresAt?.isAtSameMomentAs(DateTime.utc(2026, 8, 1)),
        isTrue,
      );
    });
  });

  group('refreshCustomer', () {
    test('rcRefreshCustomerの応答をBillingRefreshResultへ変換する', () async {
      final callable = MockHttpsCallable();
      final result = MockHttpsCallableResult();
      when(() => functions.httpsCallable('rcRefreshCustomer')).thenReturn(callable);
      when(() => callable.call<Map<String, dynamic>>()).thenAnswer((_) async => result);
      when(() => result.data).thenReturn({
        'plan': 'light',
        'isTrial': false,
        'postCredits': 3,
      });

      final refreshResult = await repository.refreshCustomer();

      expect(refreshResult.plan, Plan.light);
      expect(refreshResult.isTrial, isFalse);
      expect(refreshResult.postCredits, 3);
    });

    test('FirebaseFunctionsExceptionはBillingExceptionへ変換する', () async {
      final callable = MockHttpsCallable();
      when(() => functions.httpsCallable('rcRefreshCustomer')).thenReturn(callable);
      when(() => callable.call<Map<String, dynamic>>()).thenThrow(
        FirebaseFunctionsException(message: '同期失敗', code: 'internal'),
      );

      await expectLater(
        repository.refreshCustomer(),
        throwsA(isA<BillingException>()),
      );
    });
  });
}
