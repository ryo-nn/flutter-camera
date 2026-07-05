import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_camera/src/common_widgets/primary_button.dart';
import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/core/error/error_mapper.dart';
import 'package:flutter_camera/src/features/auth/domain/japan_phone_number_formatter.dart';
import 'package:flutter_camera/src/features/auth/presentation/auth_field_validators.dart';
import 'package:flutter_camera/src/features/auth/presentation/phone_verification_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _resendCooldownSeconds = 60;

enum _Step { phoneInput, codeInput }

/// 電話番号認証画面。S-09「アカウント」セクションの「電話番号認証」行から
/// `Navigator.push` で遷移する(GoRouterルート不要。呼び出し元がroutingを
/// 管轄するため、新規ルート追加は行わない)。
///
/// 無料プランでのX投稿解放条件(SMS認証。design.md 第9章「乱用対策」節
/// 「無料X枠の解放条件: SMS認証」準拠)として、現在ログイン中のFirebase Auth
/// アカウントへ電話番号をリンクする(`verifyPhoneNumber` → SMSコード入力 →
/// `linkWithCredential`。[Firebase Auth phone-auth]
/// (https://firebase.google.com/docs/auth/flutter/phone-auth) 準拠)。
///
/// 成功時は `Navigator.pop(true)` で呼び出し元へ通知する
/// (呼び出し元は電話番号の再取得のため `linkedPhoneNumberProvider` を invalidate する)。
class PhoneVerificationScreen extends ConsumerStatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  ConsumerState<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState
    extends ConsumerState<PhoneVerificationScreen> {
  final _phoneFormKey = GlobalKey<FormState>();
  final _codeFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  _Step _step = _Step.phoneInput;
  bool _isSuccess = false;
  String? _e164PhoneNumber;
  String? _verificationId;
  int? _forceResendingToken;

  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldownSeconds = _resendCooldownSeconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _cooldownSeconds = 0);
      } else {
        setState(() => _cooldownSeconds -= 1);
      }
    });
  }

  Future<void> _sendCode() async {
    if (!(_phoneFormKey.currentState?.validate() ?? false)) return;
    final e164 = JapanPhoneNumberFormatter.toE164(_phoneController.text);
    if (e164 == null) return; // validatorで弾いているため通常到達しない
    _e164PhoneNumber = e164;
    await _dispatchSendCode(e164, forceResendingToken: null);
  }

  Future<void> _resendCode() async {
    final e164 = _e164PhoneNumber;
    if (e164 == null || _cooldownSeconds > 0) return;
    await _dispatchSendCode(e164, forceResendingToken: _forceResendingToken);
  }

  Future<void> _dispatchSendCode(
    String phoneNumber, {
    required int? forceResendingToken,
  }) async {
    await ref
        .read(phoneVerificationControllerProvider.notifier)
        .sendCode(
          phoneNumber: phoneNumber,
          forceResendingToken: forceResendingToken,
          onCodeSent: (verificationId, resendToken) {
            if (!mounted) return;
            setState(() {
              _verificationId = verificationId;
              _forceResendingToken = resendToken;
              _step = _Step.codeInput;
              _codeController.clear();
            });
            _startCooldown();
          },
          onAutoVerified: () {
            if (!mounted) return;
            setState(() => _isSuccess = true);
          },
          onCodeAutoRetrievalTimeout: (verificationId) {
            // 自動読み取りがタイムアウトしても手動でのコード入力は継続できる
            // (verifyPhoneNumber公式ドキュメント準拠)。
            _verificationId = verificationId;
          },
        );
  }

  Future<void> _confirmCode() async {
    if (!(_codeFormKey.currentState?.validate() ?? false)) return;
    final verificationId = _verificationId;
    if (verificationId == null) return;
    await ref
        .read(phoneVerificationControllerProvider.notifier)
        .confirmCode(
          verificationId: verificationId,
          smsCode: _codeController.text.trim(),
        );
    if (!mounted) return;
    final state = ref.read(phoneVerificationControllerProvider);
    if (!state.hasError) {
      setState(() => _isSuccess = true);
    }
  }

  /// SMS認証固有のエラー文言。`credential-already-in-use` 等の汎用文言は
  /// 既存の `ErrorMapper`(core/error/error_mapper.dart。変更禁止)にフォールバックする。
  String _phoneErrorMessage(Object error) {
    if (error is AuthException) {
      switch (error.code) {
        case 'operation-not-allowed':
        case 'quota-exceeded':
          // Firebaseコンソールでの電話番号認証未有効化・SMS従量課金枠超過等、
          // クライアント側では解消できない状態(RYOの運用設定待ち)。
          return '現在ご利用いただけません。時間をおいて再度お試しください。';
        case 'invalid-phone-number':
          return '電話番号の形式が正しくありません。入力内容を確認してください。';
        case 'invalid-verification-code':
          return '認証コードが正しくありません。再度ご確認のうえ入力してください。';
        case 'invalid-verification-id':
        case 'session-expired':
          return '認証コードの有効期限が切れました。最初からやり直してください。';
      }
    }
    return ErrorMapper.toUserMessage(error) ?? 'SMS認証に失敗しました。時間をおいて再度お試しください。';
  }

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(phoneVerificationControllerProvider);
    final isBusy = controllerState.isLoading;
    final errorMessage = controllerState.hasError
        ? _phoneErrorMessage(controllerState.error!)
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('電話番号認証')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _isSuccess
                  ? _SuccessView(
                      onDone: () => Navigator.of(context).pop(true),
                    )
                  : _step == _Step.phoneInput
                  ? _PhoneInputForm(
                      formKey: _phoneFormKey,
                      controller: _phoneController,
                      isBusy: isBusy,
                      errorMessage: errorMessage,
                      onSubmit: _sendCode,
                    )
                  : _CodeInputForm(
                      formKey: _codeFormKey,
                      controller: _codeController,
                      isBusy: isBusy,
                      errorMessage: errorMessage,
                      cooldownSeconds: _cooldownSeconds,
                      onSubmit: _confirmCode,
                      onResend: _resendCode,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoneInputForm extends StatelessWidget {
  const _PhoneInputForm({
    required this.formKey,
    required this.controller,
    required this.isBusy,
    required this.errorMessage,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final bool isBusy;
  final String? errorMessage;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('無料プランでのX投稿には電話番号認証が必要です。SMSで届く認証コードを入力してください。'),
          const SizedBox(height: 24),
          TextFormField(
            controller: controller,
            enabled: !isBusy,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: '電話番号',
              hintText: '09012345678',
            ),
            validator: AuthFieldValidators.japanPhoneNumber,
            onFieldSubmitted: (_) {
              if (!isBusy) onSubmit();
            },
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'SMSを送信',
            isLoading: isBusy,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _CodeInputForm extends StatelessWidget {
  const _CodeInputForm({
    required this.formKey,
    required this.controller,
    required this.isBusy,
    required this.errorMessage,
    required this.cooldownSeconds,
    required this.onSubmit,
    required this.onResend,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final bool isBusy;
  final String? errorMessage;
  final int cooldownSeconds;
  final VoidCallback onSubmit;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('SMSで届いた6桁の認証コードを入力してください。'),
          const SizedBox(height: 24),
          TextFormField(
            controller: controller,
            enabled: !isBusy,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            maxLength: 6,
            decoration: const InputDecoration(labelText: '認証コード'),
            validator: AuthFieldValidators.smsCode,
            onFieldSubmitted: (_) {
              if (!isBusy) onSubmit();
            },
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            label: '認証する',
            isLoading: isBusy,
            onPressed: onSubmit,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: (isBusy || cooldownSeconds > 0) ? null : onResend,
            child: Text(
              cooldownSeconds > 0 ? '再送信まであと$cooldownSeconds秒' : '認証コードを再送信',
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle,
          size: 48,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        const Text('電話番号認証が完了しました。', textAlign: TextAlign.center),
        const SizedBox(height: 24),
        PrimaryButton(label: '閉じる', onPressed: onDone),
      ],
    );
  }
}
