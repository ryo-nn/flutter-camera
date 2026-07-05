import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/features/auth/domain/app_user.dart';

/// 認証リポジトリの抽象インターフェース。
///
/// data 層(`FirebaseAuthRepository`)が実装を提供し、`authRepositoryProvider`
/// (data/firebase_auth_repository.dart)経由で DI する。
/// presentation 層は本インターフェース型のみに依存する
/// (design.md アプリアーキテクチャ設計「レイヤー責務と依存方向」準拠)。
///
/// SDK例外(`FirebaseAuthException` 等)は実装側で `AppException`
/// (`core/error/app_exception.dart` の `AuthException`)へ変換して throw する。
abstract interface class AuthRepository {
  /// 認証状態の購読(`users/{uid}` プロフィールと合成した `AppUser`)。
  /// GoRouter の redirect 判定(`authStateChangesProvider`)の単一情報源となる。
  Stream<AppUser?> authStateChanges();

  /// メール/パスワードでのサインイン(S-03)。
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// メール/パスワードでの新規登録(S-03)。
  /// Firebase Authアカウント作成に続けて `users/{uid}` プロフィールドキュメントを
  /// 作成する(design.md データモデル章: 「クライアントがサインアップ直後に作成する」)。
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// パスワード再設定メールの送信(S-03「パスワードをお忘れの方」)。
  Future<void> sendPasswordResetEmail({required String email});

  /// サインアウト。
  Future<void> signOut();

  /// メール/パスワードでの再認証。
  ///
  /// アカウント削除(App Store審査5.1.1(v)対応)の前段として必須(Firebase Authは
  /// アカウント削除等の機密操作に「直近のログイン」を要求するため。再認証が古い場合は
  /// `requires-recent-login` が別途発生し得る)。
  Future<void> reauthenticateWithPassword({required String password});

  /// アカウント削除。Cloud Functions `accountDelete`(asia-northeast1・引数なし)を
  /// 呼び出す(App Store審査5.1.1(v)必須要件)。成功時はサーバー側で全データ+
  /// Firebase Authユーザーが削除済みのため、`authStateChanges()` を確実にnull化する
  /// ためクライアント側でも [signOut] を実行する。
  Future<void> deleteAccount();

  /// 現在ログイン中ユーザーにリンク済みの電話番号(E.164形式。未認証は `null`)。
  /// 無料プランのX投稿解放条件(SMS認証)の状態表示に使う(design.md 第9章
  /// 「乱用対策」節「無料X枠の解放条件: SMS認証」準拠)。
  String? get linkedPhoneNumber;

  /// 電話番号のSMS認証(Firebase Auth `verifyPhoneNumber`)を開始する。
  ///
  /// SMS送信・自動検証・送信失敗・自動読み取りタイムアウトの各イベントは
  /// コールバックで通知する(design.md 第9章「乱用対策」節
  /// 「クライアントフロー」準拠。[Firebase Auth phone-auth]
  /// (https://firebase.google.com/docs/auth/flutter/phone-auth) 準拠)。
  ///
  /// - [onCodeSent]: SMS送信完了。以後 [confirmPhoneNumberVerificationCode] へ渡す
  ///   `verificationId` を通知する(第2引数は再送信用トークン)
  /// - [onAutoVerified]: Android端末での自動検証が完了し、電話番号のリンクまで
  ///   完了したことを通知する(コード入力不要)
  /// - [onVerificationFailed]: SMS送信自体の失敗(不正な電話番号・SMS未有効化 等)
  /// - [onCodeAutoRetrievalTimeout]: 自動読み取りタイムアウト(手動でのコード入力は継続可能)
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    int? forceResendingToken,
    required void Function(String verificationId, int? forceResendingToken)
    onCodeSent,
    required void Function() onAutoVerified,
    required void Function(AuthException exception) onVerificationFailed,
    required void Function(String verificationId) onCodeAutoRetrievalTimeout,
  });

  /// SMSコード入力による電話番号リンクの完了([PhoneAuthProvider.credential] →
  /// `currentUser.linkWithCredential`。[account-linking]
  /// (https://firebase.google.com/docs/auth/flutter/account-linking) 準拠)。
  ///
  /// 成功後はIDトークンを強制リフレッシュし、`snsPublishPost` が検証する
  /// `phone_number` クレームを即時反映する(design.md 第9章「乱用対策」節
  /// 「サーバー側検証」の「リンク直後はクライアント側でIDトークンの強制リフレッシュが
  /// 必要」に対応)。
  Future<void> confirmPhoneNumberVerificationCode({
    required String verificationId,
    required String smsCode,
  });
}
