import 'dart:async';

import 'package:flutter_camera/src/features/auth/data/firebase_auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'phone_verification_controller.g.dart';

/// 電話番号のSMS認証の実行(`verifyPhoneNumber` → SMSコード → `linkWithCredential`)。
/// (design.md 第9章「乱用対策」節 プロバイダー設計「phoneVerificationControllerProvider」準拠)
///
/// [sendCode] はSMS送信の結果(送信完了・自動検証完了・自動読み取りタイムアウト)を
/// コールバックで呼び出し元(電話番号認証画面)へ通知しつつ、送信失敗時のみ本体の
/// `state` を `AsyncError` にする(画面はステップ遷移をコールバックで、
/// エラー表示は `state` の監視で行う)。
@riverpod
class PhoneVerificationController extends _$PhoneVerificationController {
  @override
  FutureOr<void> build() {}

  /// SMS送信を開始する。`forceResendingToken` を渡すと(直前の [onCodeSent] で
  /// 受け取った値)、同一SMSの重複送信防止をバイパスして再送信できる
  /// (`verifyPhoneNumber` 公式ドキュメント準拠)。
  Future<void> sendCode({
    required String phoneNumber,
    int? forceResendingToken,
    required void Function(String verificationId, int? forceResendingToken)
    onCodeSent,
    required void Function() onAutoVerified,
    required void Function(String verificationId) onCodeAutoRetrievalTimeout,
  }) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(authRepositoryProvider)
          .verifyPhoneNumber(
            phoneNumber: phoneNumber,
            forceResendingToken: forceResendingToken,
            onCodeSent: (verificationId, resendToken) {
              state = const AsyncData<void>(null);
              onCodeSent(verificationId, resendToken);
            },
            onAutoVerified: () {
              state = const AsyncData<void>(null);
              onAutoVerified();
            },
            onVerificationFailed: (exception) {
              state = AsyncError<void>(exception, StackTrace.current);
            },
            onCodeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
          );
    } catch (e, st) {
      // verifyPhoneNumber自体のFuture(送信開始処理)が失敗した場合のみここに到達する。
      // 通常のSMS送信失敗は verificationFailed コールバック経由(上記)で処理される。
      state = AsyncError<void>(e, st);
    }
  }

  /// SMSコード入力によるリンク完了(`linkWithCredential`)を実行する。
  Future<void> confirmCode({
    required String verificationId,
    required String smsCode,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .confirmPhoneNumberVerificationCode(
            verificationId: verificationId,
            smsCode: smsCode,
          ),
    );
  }
}
