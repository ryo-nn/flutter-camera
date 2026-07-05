import 'package:flutter/material.dart';
import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/core/error/error_mapper.dart';
import 'package:flutter_camera/src/features/auth/data/firebase_auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// アカウント削除フロー(App Store審査5.1.1(v)必須要件)の再認証ダイアログ。
///
/// S-09「アカウント」セクションの「アカウントを削除」ListTileから、
/// 削除内容・取り消し不可を明示する確認ダイアログ(`showConfirmDialog`)の
/// 承認後に呼び出す想定。
///
/// フロー: メール/パスワードでの再認証
/// ([AuthRepository.reauthenticateWithPassword]。Firebase Authは
/// アカウント削除に直近ログインを要求するため) →
/// Cloud Functions `accountDelete` 呼び出し([AuthRepository.deleteAccount]。
/// 成功時はサーバー側で全データ+Firebase Authユーザーが削除済み)。
///
/// 削除成功後、明示的な画面遷移は行わない。`deleteAccount()` の内部で
/// `signOut()` が実行され `authStateChanges()` がnullを流すため、
/// GoRouterのredirectがサインアウト導線と同一の仕組みで以後の画面遷移を担う。
Future<void> showAccountDeletionDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => const _AccountDeletionDialog(),
  );
}

class _AccountDeletionDialog extends ConsumerStatefulWidget {
  const _AccountDeletionDialog();

  @override
  ConsumerState<_AccountDeletionDialog> createState() =>
      _AccountDeletionDialogState();
}

class _AccountDeletionDialogState
    extends ConsumerState<_AccountDeletionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.reauthenticateWithPassword(
        password: _passwordController.text,
      );
      await repository.deleteAccount();
      // deleteAccount成功後の画面遷移はGoRouterのredirectに委ねる
      // (サインアウト導線と同じ方針。「明示遷移は不要」)。
    } on AppException catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = ErrorMapper.toUserMessage(error) ?? 'アカウントの削除に失敗しました。';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('本人確認'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('アカウント削除の実行には、パスワードの再入力が必要です。'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              enabled: !_isSubmitting,
              obscureText: _obscurePassword,
              autofillHints: const [AutofillHints.password],
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                if (!_isSubmitting) _submit();
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
                  onPressed: _isSubmitting
                      ? null
                      : () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'パスワードを入力してください。';
                }
                return null;
              },
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onError,
                  ),
                )
              : const Text('削除する'),
        ),
      ],
    );
  }
}
