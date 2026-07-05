import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/core/firebase/firebase_providers.dart';
import 'package:flutter_camera/src/features/auth/domain/app_user.dart';
import 'package:flutter_camera/src/features/auth/domain/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_auth_repository.g.dart';

const _usersCollection = 'users';
const _accountDeleteFunctionName = 'accountDelete';

/// [AuthRepository] の Firebase 実装。
///
/// `users/{uid}` プロフィールの読み取りと合成した `AppUser` を
/// `authStateChanges()` として公開する(design.md データモデル章参照)。
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._firestore, this._functions);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  @override
  Stream<AppUser?> authStateChanges() {
    late final StreamController<AppUser?> controller;
    StreamSubscription<User?>? authSub;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? profileSub;

    Future<void> cancelProfileSub() async {
      await profileSub?.cancel();
      profileSub = null;
    }

    controller = StreamController<AppUser?>.broadcast(
      onListen: () {
        authSub = _auth.authStateChanges().listen((user) async {
          // ユーザー切替のたびに直前のプロフィール購読を止めてから
          // 新しい購読へ切り替える(switchMap相当。rxdart非依存で実装)。
          await cancelProfileSub();
          if (user == null) {
            controller.add(null);
            return;
          }
          profileSub = _firestore
              .collection(_usersCollection)
              .doc(user.uid)
              .snapshots()
              .listen((snapshot) {
                final data = snapshot.data();
                controller.add(
                  data == null
                      ? null
                      : AppUser.fromJson({...data, 'uid': snapshot.id}),
                );
              }, onError: controller.addError);
        }, onError: controller.addError);
      },
      onCancel: () async {
        await cancelProfileSub();
        await authSub?.cancel();
        authSub = null;
      },
    );

    return controller.stream;
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'サインインに失敗しました', code: e.code);
    }
  }

  @override
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final UserCredential credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'アカウント作成に失敗しました', code: e.code);
    }

    final user = credential.user;
    if (user == null) {
      throw const AuthException('アカウント作成に失敗しました', code: 'unknown');
    }

    try {
      await _firestore.collection(_usersCollection).doc(user.uid).set({
        'uid': user.uid,
        'displayName': _defaultDisplayName(email),
        'photoUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      // プロフィール作成に失敗した場合、認証アカウントだけが残る不整合を防ぐため
      // 作成済みのFirebase Authアカウントを削除する(ベストエフォート)。
      await _safeDeleteUser(user);
      throw AuthException(e.message ?? 'プロフィールの作成に失敗しました', code: e.code);
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'パスワード再設定メールの送信に失敗しました', code: e.code);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'サインアウトに失敗しました', code: e.code);
    }
  }

  @override
  Future<void> reauthenticateWithPassword({required String password}) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw const AuthException('ログイン情報を確認できませんでした', code: 'internal-error');
    }
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    try {
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? '再認証に失敗しました', code: e.code);
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _functions
          .httpsCallable(_accountDeleteFunctionName)
          .call<Map<String, dynamic>>();
    } on FirebaseFunctionsException catch (e) {
      throw AuthException(e.message ?? 'アカウントの削除に失敗しました', code: e.code);
    }
    // サーバー側でFirebase Authユーザーは削除済みだが、クライアントのFirebaseAuth
    // インスタンスは自動では検知しないため、明示的にsignOutしてauthStateChanges
    // ストリームを確実にnull化する(GoRouterのredirectが以後の画面遷移を担う)。
    await signOut();
  }

  @override
  String? get linkedPhoneNumber => _auth.currentUser?.phoneNumber;

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    int? forceResendingToken,
    required void Function(String verificationId, int? forceResendingToken)
    onCodeSent,
    required void Function() onAutoVerified,
    required void Function(AuthException exception) onVerificationFailed,
    required void Function(String verificationId) onCodeAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: forceResendingToken,
        verificationCompleted: (credential) async {
          try {
            await _auth.currentUser?.linkWithCredential(credential);
            await _auth.currentUser?.getIdToken(true);
            onAutoVerified();
          } on FirebaseAuthException catch (e) {
            onVerificationFailed(
              AuthException(e.message ?? '電話番号のリンクに失敗しました', code: e.code),
            );
          }
        },
        verificationFailed: (e) {
          onVerificationFailed(
            AuthException(e.message ?? 'SMSの送信に失敗しました', code: e.code),
          );
        },
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'SMSの送信に失敗しました', code: e.code);
    }
  }

  @override
  Future<void> confirmPhoneNumberVerificationCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    try {
      await _auth.currentUser?.linkWithCredential(credential);
      await _auth.currentUser?.getIdToken(true);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? '電話番号のリンクに失敗しました', code: e.code);
    }
  }

  Future<void> _safeDeleteUser(User user) async {
    try {
      await user.delete();
    } on FirebaseAuthException {
      // 削除に失敗しても呼び出し元には元のプロフィール作成失敗を伝える(ベストエフォート)。
    }
  }

  /// サインアップ画面(S-03)にはメール/パスワードのみで表示名入力欄がないため、
  /// メールアドレスのローカルパートを初期表示名とする(users/{uid}.displayName は
  /// 1〜30文字必須。Firestore Security Rules準拠)。
  static String _defaultDisplayName(String email) {
    final localPart = email.split('@').first;
    if (localPart.isEmpty) return 'ユーザー';
    return localPart.length > 30 ? localPart.substring(0, 30) : localPart;
  }
}

/// 認証リポジトリ実装の DI。
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計「authRepositoryProvider」)
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return FirebaseAuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
    ref.watch(firebaseFunctionsProvider),
  );
}

/// 認証状態の購読(ルートガード判定の単一情報源)。
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計「authStateChangesProvider」)
@Riverpod(keepAlive: true)
Stream<AppUser?> authStateChanges(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
}

/// 現在ログイン中ユーザーにリンク済みの電話番号(S-09「電話番号認証」行の表示用)。
/// 電話番号リンクはFirestoreの `users/{uid}` プロフィールを変更しないため
/// `authStateChangesProvider` では検知できず、リンク完了後は呼び出し側が
/// `ref.invalidate(linkedPhoneNumberProvider)` で明示的に再取得する。
@riverpod
String? linkedPhoneNumber(Ref ref) {
  return ref.watch(authRepositoryProvider).linkedPhoneNumber;
}
