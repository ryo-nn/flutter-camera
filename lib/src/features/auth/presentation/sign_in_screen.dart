import 'package:flutter/material.dart';
import 'package:flutter_camera/src/common_widgets/primary_button.dart';
import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/core/error/error_mapper.dart';
import 'package:flutter_camera/src/features/auth/data/firebase_auth_repository.dart';
import 'package:flutter_camera/src/features/auth/presentation/auth_field_validators.dart';
import 'package:flutter_camera/src/features/auth/presentation/sign_in_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _AuthMode { signIn, signUp }

/// S-03 ログイン/サインアップ画面。
/// (design.md 画面設計・UIフロー章「S-03 ログイン/サインアップ」準拠)
///
/// ログイン/新規登録を1画面でタブ切替する。認証成功後の遷移は
/// `authStateChangesProvider` を起点にした GoRouter の redirect が一元的に担うため、
/// 本画面から `/home` への明示的な画面遷移は行わない。
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  _AuthMode _mode = _AuthMode.signIn;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  /// design.md 画面設計・UIフロー章「アクセシビリティ配慮」:
  /// 「エラー発生時は先頭のエラーフィールドへフォーカス移動する」準拠。
  /// 視覚順(メールアドレス→パスワード)と同じ順で最初にエラーのある
  /// フィールドへフォーカスする。
  void _focusFirstInvalidField() {
    if (AuthFieldValidators.email(_emailController.text) != null) {
      _emailFocusNode.requestFocus();
    } else if (AuthFieldValidators.password(_passwordController.text) !=
        null) {
      _passwordFocusNode.requestFocus();
    }
  }

  void _switchMode(_AuthMode mode) {
    if (_mode == mode) return;
    setState(() => _mode = mode);
    // モード切替時に前回の送信エラー表示をクリアする。
    ref.invalidate(signInControllerProvider);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      _focusFirstInvalidField();
      return;
    }
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final controller = ref.read(signInControllerProvider.notifier);
    switch (_mode) {
      case _AuthMode.signIn:
        await controller.signIn(email: email, password: password);
      case _AuthMode.signUp:
        await controller.signUp(email: email, password: password);
    }
  }

  void _openResetPasswordDialog() {
    showDialog<void>(
      context: context,
      builder: (context) =>
          _ResetPasswordDialog(initialEmail: _emailController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signInControllerProvider);
    final isSubmitting = state.isLoading;
    final errorMessage = state.hasError
        ? (ErrorMapper.toUserMessage(state.error!) ??
              '認証に失敗しました。入力内容を確認して再度お試しください。')
        : null;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<_AuthMode>(
                      segments: const [
                        ButtonSegment(
                          value: _AuthMode.signIn,
                          label: Text('ログイン'),
                        ),
                        ButtonSegment(
                          value: _AuthMode.signUp,
                          label: Text('新規登録'),
                        ),
                      ],
                      selected: {_mode},
                      onSelectionChanged: isSubmitting
                          ? null
                          : (selection) => _switchMode(selection.first),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      enabled: !isSubmitting,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'メールアドレス'),
                      validator: AuthFieldValidators.email,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      enabled: !isSubmitting,
                      obscureText: _obscurePassword,
                      autofillHints: [
                        _mode == _AuthMode.signIn
                            ? AutofillHints.password
                            : AutofillHints.newPassword,
                      ],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (!isSubmitting) _submit();
                      },
                      decoration: InputDecoration(
                        labelText: 'パスワード',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          tooltip: _obscurePassword ? 'パスワードを表示' : 'パスワードを隠す',
                          onPressed: isSubmitting
                              ? null
                              : () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                        ),
                      ),
                      validator: AuthFieldValidators.password,
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorMessage,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: _mode == _AuthMode.signIn ? 'ログインする' : '登録する',
                      isLoading: isSubmitting,
                      onPressed: _submit,
                    ),
                    if (_mode == _AuthMode.signIn) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: isSubmitting
                            ? null
                            : _openResetPasswordDialog,
                        child: const Text('パスワードをお忘れの方'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 「パスワードをお忘れの方」タップで開く再設定メール送信ダイアログ。
class _ResetPasswordDialog extends ConsumerStatefulWidget {
  const _ResetPasswordDialog({required this.initialEmail});

  final String initialEmail;

  @override
  ConsumerState<_ResetPasswordDialog> createState() =>
      _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends ConsumerState<_ResetPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _emailController = TextEditingController(
    text: widget.initialEmail,
  );

  bool _isSubmitting = false;
  bool _isSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .sendPasswordResetEmail(email: _emailController.text.trim());
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _isSent = true;
      });
    } on AppException catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage =
            ErrorMapper.toUserMessage(error) ?? 'パスワード再設定メールの送信に失敗しました。';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('パスワードを再設定'),
      content: _isSent
          ? const Text('パスワード再設定用のメールを送信しました。メールをご確認ください。')
          : Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('登録済みのメールアドレス宛にパスワード再設定用のメールを送信します。'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    enabled: !_isSubmitting,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(labelText: 'メールアドレス'),
                    validator: AuthFieldValidators.email,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
      actions: _isSent
          ? [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('閉じる'),
              ),
            ]
          : [
              TextButton(
                onPressed: _isSubmitting
                    ? null
                    : () => Navigator.of(context).pop(),
                child: const Text('キャンセル'),
              ),
              FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('送信する'),
              ),
            ],
    );
  }
}
