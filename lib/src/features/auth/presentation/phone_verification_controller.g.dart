// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_verification_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 電話番号のSMS認証の実行(`verifyPhoneNumber` → SMSコード → `linkWithCredential`)。
/// (design.md 第9章「乱用対策」節 プロバイダー設計「phoneVerificationControllerProvider」準拠)
///
/// [sendCode] はSMS送信の結果(送信完了・自動検証完了・自動読み取りタイムアウト)を
/// コールバックで呼び出し元(電話番号認証画面)へ通知しつつ、送信失敗時のみ本体の
/// `state` を `AsyncError` にする(画面はステップ遷移をコールバックで、
/// エラー表示は `state` の監視で行う)。

@ProviderFor(PhoneVerificationController)
final phoneVerificationControllerProvider =
    PhoneVerificationControllerProvider._();

/// 電話番号のSMS認証の実行(`verifyPhoneNumber` → SMSコード → `linkWithCredential`)。
/// (design.md 第9章「乱用対策」節 プロバイダー設計「phoneVerificationControllerProvider」準拠)
///
/// [sendCode] はSMS送信の結果(送信完了・自動検証完了・自動読み取りタイムアウト)を
/// コールバックで呼び出し元(電話番号認証画面)へ通知しつつ、送信失敗時のみ本体の
/// `state` を `AsyncError` にする(画面はステップ遷移をコールバックで、
/// エラー表示は `state` の監視で行う)。
final class PhoneVerificationControllerProvider
    extends $AsyncNotifierProvider<PhoneVerificationController, void> {
  /// 電話番号のSMS認証の実行(`verifyPhoneNumber` → SMSコード → `linkWithCredential`)。
  /// (design.md 第9章「乱用対策」節 プロバイダー設計「phoneVerificationControllerProvider」準拠)
  ///
  /// [sendCode] はSMS送信の結果(送信完了・自動検証完了・自動読み取りタイムアウト)を
  /// コールバックで呼び出し元(電話番号認証画面)へ通知しつつ、送信失敗時のみ本体の
  /// `state` を `AsyncError` にする(画面はステップ遷移をコールバックで、
  /// エラー表示は `state` の監視で行う)。
  PhoneVerificationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'phoneVerificationControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$phoneVerificationControllerHash();

  @$internal
  @override
  PhoneVerificationController create() => PhoneVerificationController();
}

String _$phoneVerificationControllerHash() =>
    r'3071643428735ba6d54af33e292dec0d9de843e2';

/// 電話番号のSMS認証の実行(`verifyPhoneNumber` → SMSコード → `linkWithCredential`)。
/// (design.md 第9章「乱用対策」節 プロバイダー設計「phoneVerificationControllerProvider」準拠)
///
/// [sendCode] はSMS送信の結果(送信完了・自動検証完了・自動読み取りタイムアウト)を
/// コールバックで呼び出し元(電話番号認証画面)へ通知しつつ、送信失敗時のみ本体の
/// `state` を `AsyncError` にする(画面はステップ遷移をコールバックで、
/// エラー表示は `state` の監視で行う)。

abstract class _$PhoneVerificationController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
