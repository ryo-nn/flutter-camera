// FirebaseAuthExceptionのコンストラクタは@protected指定だが、テストでの直接生成は
// firebase_authパッケージ自身のテストでも使われる標準的な手法のため許容する。
// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/features/auth/data/firebase_auth_repository.dart';
import 'package:flutter_camera/src/features/auth/domain/app_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class MockHttpsCallable extends Mock implements HttpsCallable {}

class MockHttpsCallableResult extends Mock
    implements HttpsCallableResult<Map<String, dynamic>> {}

void main() {
  late MockFirebaseAuth auth;
  late MockFirebaseFirestore firestore;
  late MockCollectionReference collection;
  late MockDocumentReference docRef;
  late MockFirebaseFunctions functions;
  late FirebaseAuthRepository repository;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(
      EmailAuthProvider.credential(email: 'fallback@example.com', password: 'x'),
    );
  });

  setUp(() {
    auth = MockFirebaseAuth();
    firestore = MockFirebaseFirestore();
    collection = MockCollectionReference();
    docRef = MockDocumentReference();
    functions = MockFirebaseFunctions();
    repository = FirebaseAuthRepository(auth, firestore, functions);

    when(() => firestore.collection('users')).thenReturn(collection);
  });

  group('signInWithEmailAndPassword', () {
    test('FirebaseAuthへ委譲する', () async {
      when(
        () => auth.signInWithEmailAndPassword(
          email: 'user@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => MockUserCredential());

      await repository.signInWithEmailAndPassword(
        email: 'user@example.com',
        password: 'password123',
      );

      verify(
        () => auth.signInWithEmailAndPassword(
          email: 'user@example.com',
          password: 'password123',
        ),
      ).called(1);
    });

    test('FirebaseAuthExceptionをAuthExceptionへ変換する', () async {
      when(
        () => auth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        FirebaseAuthException(code: 'wrong-password', message: 'wrong'),
      );

      await expectLater(
        () => repository.signInWithEmailAndPassword(
          email: 'user@example.com',
          password: 'wrong',
        ),
        throwsA(
          isA<AuthException>().having((e) => e.code, 'code', 'wrong-password'),
        ),
      );
    });
  });

  group('signUpWithEmailAndPassword', () {
    test('アカウント作成後にusers/{uid}をメールのローカルパートで作成する', () async {
      final credential = MockUserCredential();
      final user = MockUser();
      when(() => user.uid).thenReturn('uid-1');
      when(() => credential.user).thenReturn(user);
      when(
        () => auth.createUserWithEmailAndPassword(
          email: 'nanami@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => credential);
      when(() => collection.doc('uid-1')).thenReturn(docRef);
      when(() => docRef.set(any())).thenAnswer((_) async {});

      await repository.signUpWithEmailAndPassword(
        email: 'nanami@example.com',
        password: 'password123',
      );

      final captured =
          verify(() => docRef.set(captureAny())).captured.single
              as Map<String, dynamic>;
      expect(captured['uid'], 'uid-1');
      expect(captured['displayName'], 'nanami');
      expect(captured['photoUrl'], isNull);
      expect(captured['createdAt'], isA<FieldValue>());
      expect(captured['updatedAt'], isA<FieldValue>());
    });

    test('FirebaseAuthExceptionをAuthExceptionへ変換する(アカウント作成失敗)', () async {
      when(
        () => auth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        FirebaseAuthException(code: 'email-already-in-use', message: 'used'),
      );

      await expectLater(
        () => repository.signUpWithEmailAndPassword(
          email: 'exists@example.com',
          password: 'password123',
        ),
        throwsA(
          isA<AuthException>().having(
            (e) => e.code,
            'code',
            'email-already-in-use',
          ),
        ),
      );
    });

    test('users/{uid}作成に失敗した場合は作成済みのFirebase Authアカウントを削除する', () async {
      final credential = MockUserCredential();
      final user = MockUser();
      when(() => user.uid).thenReturn('uid-1');
      when(() => user.delete()).thenAnswer((_) async {});
      when(() => credential.user).thenReturn(user);
      when(
        () => auth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => credential);
      when(() => collection.doc('uid-1')).thenReturn(docRef);
      when(() => docRef.set(any())).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      );

      await expectLater(
        () => repository.signUpWithEmailAndPassword(
          email: 'nanami@example.com',
          password: 'password123',
        ),
        throwsA(isA<AuthException>()),
      );

      verify(() => user.delete()).called(1);
    });
  });

  group('sendPasswordResetEmail', () {
    test('FirebaseAuthへ委譲する', () async {
      when(
        () => auth.sendPasswordResetEmail(email: 'user@example.com'),
      ).thenAnswer((_) async {});

      await repository.sendPasswordResetEmail(email: 'user@example.com');

      verify(
        () => auth.sendPasswordResetEmail(email: 'user@example.com'),
      ).called(1);
    });

    test('FirebaseAuthExceptionをAuthExceptionへ変換する', () async {
      when(
        () => auth.sendPasswordResetEmail(email: any(named: 'email')),
      ).thenThrow(
        FirebaseAuthException(code: 'user-not-found', message: 'not found'),
      );

      await expectLater(
        () => repository.sendPasswordResetEmail(email: 'nobody@example.com'),
        throwsA(
          isA<AuthException>().having((e) => e.code, 'code', 'user-not-found'),
        ),
      );
    });
  });

  group('signOut', () {
    test('FirebaseAuthへ委譲する', () async {
      when(() => auth.signOut()).thenAnswer((_) async {});

      await repository.signOut();

      verify(() => auth.signOut()).called(1);
    });

    test('FirebaseAuthExceptionをAuthExceptionへ変換する', () async {
      when(() => auth.signOut()).thenThrow(
        FirebaseAuthException(code: 'network-request-failed', message: 'x'),
      );

      await expectLater(
        () => repository.signOut(),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('authStateChanges', () {
    test('未ログイン時はnullを流す', () async {
      final authController = StreamController<User?>();
      when(
        () => auth.authStateChanges(),
      ).thenAnswer((_) => authController.stream);

      final results = <AppUser?>[];
      final sub = repository.authStateChanges().listen(results.add);

      authController.add(null);
      await Future<void>.delayed(Duration.zero);

      expect(results, [null]);

      await sub.cancel();
      await authController.close();
    });

    test('ログイン中はusers/{uid}のスナップショットと合成したAppUserを流す', () async {
      final authController = StreamController<User?>();
      final docController =
          StreamController<DocumentSnapshot<Map<String, dynamic>>>();

      when(
        () => auth.authStateChanges(),
      ).thenAnswer((_) => authController.stream);
      when(() => collection.doc('uid-1')).thenReturn(docRef);
      when(() => docRef.snapshots()).thenAnswer((_) => docController.stream);

      final user = MockUser();
      when(() => user.uid).thenReturn('uid-1');

      final snapshot = MockDocumentSnapshot();
      when(() => snapshot.id).thenReturn('uid-1');
      when(() => snapshot.data()).thenReturn({
        'uid': 'uid-1',
        'displayName': 'テストユーザー',
        'photoUrl': null,
        'createdAt': Timestamp.fromDate(DateTime.utc(2026, 1, 1)),
        'updatedAt': Timestamp.fromDate(DateTime.utc(2026, 1, 2)),
      });

      final results = <AppUser?>[];
      final sub = repository.authStateChanges().listen(results.add);

      authController.add(user);
      await Future<void>.delayed(Duration.zero);
      expect(results, isEmpty); // ドキュメント到着前はまだ何も流れない

      docController.add(snapshot);
      await Future<void>.delayed(Duration.zero);
      expect(results, hasLength(1));
      expect(results.single?.uid, 'uid-1');
      expect(results.single?.displayName, 'テストユーザー');

      authController.add(null);
      await Future<void>.delayed(Duration.zero);
      expect(results, hasLength(2));
      expect(results.last, isNull);

      await sub.cancel();
      await authController.close();
      await docController.close();
    });

    test('プロフィールドキュメントが存在しない場合はnullを流す', () async {
      final authController = StreamController<User?>();
      final docController =
          StreamController<DocumentSnapshot<Map<String, dynamic>>>();

      when(
        () => auth.authStateChanges(),
      ).thenAnswer((_) => authController.stream);
      when(() => collection.doc('uid-1')).thenReturn(docRef);
      when(() => docRef.snapshots()).thenAnswer((_) => docController.stream);

      final user = MockUser();
      when(() => user.uid).thenReturn('uid-1');

      final snapshot = MockDocumentSnapshot();
      when(() => snapshot.data()).thenReturn(null);

      final results = <AppUser?>[];
      final sub = repository.authStateChanges().listen(results.add);

      authController.add(user);
      await Future<void>.delayed(Duration.zero);
      docController.add(snapshot);
      await Future<void>.delayed(Duration.zero);

      expect(results, [null]);

      await sub.cancel();
      await authController.close();
      await docController.close();
    });
  });

  group('reauthenticateWithPassword', () {
    test('現在のユーザーのemailでEmailAuthProvider資格情報を再認証する', () async {
      final user = MockUser();
      when(() => user.email).thenReturn('nanami@example.com');
      when(
        () => user.reauthenticateWithCredential(any()),
      ).thenAnswer((_) async => MockUserCredential());
      when(() => auth.currentUser).thenReturn(user);

      await repository.reauthenticateWithPassword(password: 'password123');

      final captured =
          verify(
            () => user.reauthenticateWithCredential(captureAny()),
          ).captured.single as AuthCredential;
      expect(captured.signInMethod, 'password');
    });

    test('FirebaseAuthExceptionをAuthExceptionへ変換する', () async {
      final user = MockUser();
      when(() => user.email).thenReturn('nanami@example.com');
      when(() => user.reauthenticateWithCredential(any())).thenThrow(
        FirebaseAuthException(code: 'wrong-password', message: 'wrong'),
      );
      when(() => auth.currentUser).thenReturn(user);

      await expectLater(
        () => repository.reauthenticateWithPassword(password: 'wrong'),
        throwsA(
          isA<AuthException>().having((e) => e.code, 'code', 'wrong-password'),
        ),
      );
    });

    test('currentUserがnullの場合はAuthExceptionを投げる', () async {
      when(() => auth.currentUser).thenReturn(null);

      await expectLater(
        () => repository.reauthenticateWithPassword(password: 'password123'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('deleteAccount', () {
    test('accountDeleteを引数なしで呼び出した後、signOutでローカルセッションをnull化する', () async {
      final callable = MockHttpsCallable();
      final result = MockHttpsCallableResult();
      when(() => result.data).thenReturn(<String, dynamic>{});
      when(() => functions.httpsCallable('accountDelete')).thenReturn(callable);
      when(
        () => callable.call<Map<String, dynamic>>(),
      ).thenAnswer((_) async => result);
      when(() => auth.signOut()).thenAnswer((_) async {});

      await repository.deleteAccount();

      verify(() => callable.call<Map<String, dynamic>>()).called(1);
      verify(() => auth.signOut()).called(1);
    });

    test('FirebaseFunctionsExceptionをAuthExceptionへ変換する', () async {
      final callable = MockHttpsCallable();
      when(() => functions.httpsCallable('accountDelete')).thenReturn(callable);
      when(() => callable.call<Map<String, dynamic>>()).thenThrow(
        FirebaseFunctionsException(code: 'unauthenticated', message: 'no auth'),
      );

      await expectLater(
        () => repository.deleteAccount(),
        throwsA(
          isA<AuthException>().having((e) => e.code, 'code', 'unauthenticated'),
        ),
      );
      verifyNever(() => auth.signOut());
    });
  });

  group('linkedPhoneNumber', () {
    test('currentUserの電話番号を返す', () {
      final user = MockUser();
      when(() => user.phoneNumber).thenReturn('+819012345678');
      when(() => auth.currentUser).thenReturn(user);

      expect(repository.linkedPhoneNumber, '+819012345678');
    });

    test('未ログイン・未認証の場合はnullを返す', () {
      when(() => auth.currentUser).thenReturn(null);

      expect(repository.linkedPhoneNumber, isNull);
    });
  });

  group('verifyPhoneNumber', () {
    test('codeSentコールバックをonCodeSentへ委譲する', () async {
      when(
        () => auth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          forceResendingToken: any(named: 'forceResendingToken'),
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
        ),
      ).thenAnswer((invocation) async {
        final codeSent =
            invocation.namedArguments[#codeSent] as PhoneCodeSent;
        codeSent('verification-id-1', 42);
      });

      String? receivedVerificationId;
      int? receivedResendToken;
      await repository.verifyPhoneNumber(
        phoneNumber: '+819012345678',
        onCodeSent: (verificationId, resendToken) {
          receivedVerificationId = verificationId;
          receivedResendToken = resendToken;
        },
        onAutoVerified: () {},
        onVerificationFailed: (_) {},
        onCodeAutoRetrievalTimeout: (_) {},
      );

      expect(receivedVerificationId, 'verification-id-1');
      expect(receivedResendToken, 42);
    });

    test('verificationFailedコールバックをAuthExceptionへ変換してonVerificationFailedへ委譲する', () async {
      when(
        () => auth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          forceResendingToken: any(named: 'forceResendingToken'),
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
        ),
      ).thenAnswer((invocation) async {
        final verificationFailed =
            invocation.namedArguments[#verificationFailed]
                as PhoneVerificationFailed;
        verificationFailed(
          FirebaseAuthException(
            code: 'invalid-phone-number',
            message: 'invalid',
          ),
        );
      });

      AuthException? received;
      await repository.verifyPhoneNumber(
        phoneNumber: 'invalid',
        onCodeSent: (_, _) {},
        onAutoVerified: () {},
        onVerificationFailed: (exception) => received = exception,
        onCodeAutoRetrievalTimeout: (_) {},
      );

      expect(received?.code, 'invalid-phone-number');
    });

    test(
      'verificationCompleted(Android自動検証)はlinkWithCredential成功後にonAutoVerifiedを呼ぶ',
      () async {
        final user = MockUser();
        when(() => user.linkWithCredential(any())).thenAnswer(
          (_) async => MockUserCredential(),
        );
        when(() => user.getIdToken(true)).thenAnswer((_) async => 'token');
        when(() => auth.currentUser).thenReturn(user);

        final credential = PhoneAuthProvider.credential(
          verificationId: 'verification-id-1',
          smsCode: '123456',
        );
        when(
          () => auth.verifyPhoneNumber(
            phoneNumber: any(named: 'phoneNumber'),
            forceResendingToken: any(named: 'forceResendingToken'),
            verificationCompleted: any(named: 'verificationCompleted'),
            verificationFailed: any(named: 'verificationFailed'),
            codeSent: any(named: 'codeSent'),
            codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          ),
        ).thenAnswer((invocation) async {
          final verificationCompleted =
              invocation.namedArguments[#verificationCompleted]
                  as Future<void> Function(PhoneAuthCredential);
          await verificationCompleted(credential);
        });

        var autoVerifiedCalled = false;
        await repository.verifyPhoneNumber(
          phoneNumber: '+819012345678',
          onCodeSent: (_, _) {},
          onAutoVerified: () => autoVerifiedCalled = true,
          onVerificationFailed: (_) {},
          onCodeAutoRetrievalTimeout: (_) {},
        );

        expect(autoVerifiedCalled, isTrue);
        verify(() => user.linkWithCredential(any())).called(1);
        verify(() => user.getIdToken(true)).called(1);
      },
    );

    test(
      'verificationCompletedでlinkWithCredentialが失敗した場合はonVerificationFailedを呼ぶ',
      () async {
        final user = MockUser();
        when(() => user.linkWithCredential(any())).thenThrow(
          FirebaseAuthException(
            code: 'credential-already-in-use',
            message: 'already used',
          ),
        );
        when(() => auth.currentUser).thenReturn(user);

        final credential = PhoneAuthProvider.credential(
          verificationId: 'verification-id-1',
          smsCode: '123456',
        );
        when(
          () => auth.verifyPhoneNumber(
            phoneNumber: any(named: 'phoneNumber'),
            forceResendingToken: any(named: 'forceResendingToken'),
            verificationCompleted: any(named: 'verificationCompleted'),
            verificationFailed: any(named: 'verificationFailed'),
            codeSent: any(named: 'codeSent'),
            codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          ),
        ).thenAnswer((invocation) async {
          final verificationCompleted =
              invocation.namedArguments[#verificationCompleted]
                  as Future<void> Function(PhoneAuthCredential);
          await verificationCompleted(credential);
        });

        AuthException? received;
        await repository.verifyPhoneNumber(
          phoneNumber: '+819012345678',
          onCodeSent: (_, _) {},
          onAutoVerified: () {},
          onVerificationFailed: (exception) => received = exception,
          onCodeAutoRetrievalTimeout: (_) {},
        );

        expect(received?.code, 'credential-already-in-use');
      },
    );
  });

  group('confirmPhoneNumberVerificationCode', () {
    test('PhoneAuthCredentialでlinkWithCredentialし、IDトークンを強制リフレッシュする', () async {
      final user = MockUser();
      when(
        () => user.linkWithCredential(any()),
      ).thenAnswer((_) async => MockUserCredential());
      when(() => user.getIdToken(true)).thenAnswer((_) async => 'token');
      when(() => auth.currentUser).thenReturn(user);

      await repository.confirmPhoneNumberVerificationCode(
        verificationId: 'verification-id-1',
        smsCode: '123456',
      );

      verify(() => user.linkWithCredential(any())).called(1);
      verify(() => user.getIdToken(true)).called(1);
    });

    test('FirebaseAuthExceptionをAuthExceptionへ変換する', () async {
      final user = MockUser();
      when(() => user.linkWithCredential(any())).thenThrow(
        FirebaseAuthException(
          code: 'invalid-verification-code',
          message: 'invalid code',
        ),
      );
      when(() => auth.currentUser).thenReturn(user);

      await expectLater(
        () => repository.confirmPhoneNumberVerificationCode(
          verificationId: 'verification-id-1',
          smsCode: '000000',
        ),
        throwsA(
          isA<AuthException>().having(
            (e) => e.code,
            'code',
            'invalid-verification-code',
          ),
        ),
      );
    });
  });
}
