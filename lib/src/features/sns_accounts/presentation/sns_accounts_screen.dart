import 'package:flutter/material.dart';
import 'package:flutter_camera/src/common_widgets/app_error_view.dart';
import 'package:flutter_camera/src/common_widgets/confirm_dialog.dart';
import 'package:flutter_camera/src/common_widgets/primary_button.dart';
import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/core/error/error_mapper.dart';
import 'package:flutter_camera/src/core/models/sns_provider.dart';
// auth featureは実装済み。サインアウト・アカウント削除・電話番号認証(SMS認証)は
// アカウント設定の一部としてauth featureのAuthRepositoryを直接参照する
// (design.md「アカウント」セクション追補。App Store審査5.1.1(v)対応)。
import 'package:flutter_camera/src/features/auth/data/firebase_auth_repository.dart';
import 'package:flutter_camera/src/features/auth/domain/japan_phone_number_formatter.dart';
import 'package:flutter_camera/src/features/auth/presentation/account_deletion_dialog.dart';
import 'package:flutter_camera/src/features/auth/presentation/phone_verification_screen.dart';
import 'package:flutter_camera/src/features/sns_accounts/data/functions_sns_account_repository.dart';
import 'package:flutter_camera/src/features/sns_accounts/domain/sns_authorization.dart';
import 'package:flutter_camera/src/features/sns_accounts/domain/sns_connection.dart';
import 'package:flutter_camera/src/features/sns_accounts/presentation/sns_connect_controller.dart';
// posting featureは実装済み。design.md「追補による既存章への変更点」節
// 「ui章 S-07/S-09: X残数表示を…月次…ベースへ変更」に対応するため、
// posting機能が単一情報源として公開する `xQuotaProvider` / `XQuota` を参照する
// (posting/presentation/post_compose_screen.dart の `_XQuotaHint` と同一の
// 参照先・表示ロジックに揃えている。notes参照)。
import 'package:flutter_camera/src/features/posting/data/firestore_x_quota_repository.dart';
import 'package:flutter_camera/src/features/posting/domain/x_quota.dart';
import 'package:flutter_camera/src/routing/app_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 画面9 SNSアカウント連携設定画面(design.md UIフロー章 S-09準拠)。
class SnsAccountsScreen extends ConsumerWidget {
  const SnsAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _listenConnectController(ref, context, SnsProvider.instagram);
    _listenConnectController(ref, context, SnsProvider.x);

    final connectionsAsync = ref.watch(snsConnectionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('SNSアカウント連携設定')),
      body: connectionsAsync.when(
        data: (connections) => _Body(connections: connections),
        loading: () => const _SnsAccountsSkeleton(),
        error: (error, stackTrace) => AppErrorView(
          message: ErrorMapper.toUserMessage(error) ?? '連携状態を確認できませんでした',
          onRetry: () => ref.invalidate(snsConnectionsProvider),
        ),
      ),
    );
  }

  /// Instagram非プロ判定時はS-09aへ自動遷移し(design.md UIフロー章 S-09「状態」列
  /// 「Instagram非プロ判定: 連携完了直後に判定し、S-09aへ自動遷移」準拠)、
  /// それ以外のエラーは共通のSnackBar表示にフォールバックする
  /// (キャンセルは `AsyncError` にならないため、ここには流れてこない)。
  void _listenConnectController(
    WidgetRef ref,
    BuildContext context,
    SnsProvider provider,
  ) {
    ref.listen(snsConnectControllerProvider(provider), (previous, next) {
      if (next case AsyncError(:final error)) {
        if (error is SnsAuthException && error.requiresProAccount) {
          context.pushNamed(AppRoute.instagramProGuide.name);
          return;
        }
        final message = ErrorMapper.toUserMessage(error);
        if (message == null) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    });
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.connections});

  final List<SnsConnection> connections;

  @override
  Widget build(BuildContext context) {
    final instagram = _connectionFor(connections, SnsProvider.instagram);
    final x = _connectionFor(connections, SnsProvider.x);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Instagram', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _InstagramSection(connection: instagram),
        const SizedBox(height: 24),
        Text('X', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _XSection(connection: x),
        const SizedBox(height: 24),
        Text(
          '連携は外部ブラウザで各SNSのログイン画面が開きます',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 24),
        Text('アカウント', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const _AccountSection(),
      ],
    );
  }

  SnsConnection? _connectionFor(
    List<SnsConnection> connections,
    SnsProvider provider,
  ) {
    for (final connection in connections) {
      if (connection.provider == provider) return connection;
    }
    return null;
  }
}

class _InstagramSection extends ConsumerWidget {
  const _InstagramSection({required this.connection});

  final SnsConnection? connection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = ref
        .watch(snsConnectControllerProvider(SnsProvider.instagram))
        .isLoading;

    if (connection == null || !connection!.isConnected) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('投稿にはプロアカウント(ビジネス/クリエイター)が必要です'),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Instagramと連携する',
                isLoading: isBusy,
                onPressed: isBusy ? null : () => _connect(context, ref),
              ),
              if (isBusy) ...[const SizedBox(height: 8), const Text('連携処理中…')],
            ],
          ),
        ),
      );
    }

    if (connection!.requiresProAccountSwitch) {
      return Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'このアカウントはプロアカウントではないため投稿できません',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () =>
                    context.pushNamed(AppRoute.instagramProGuide.name),
                child: const Text('切り替え手順を見る'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: ListTile(
        title: Text(connection!.username ?? ''),
        subtitle: Text(_accountTypeLabel(connection!.accountType)),
        trailing: isBusy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : TextButton(
                onPressed: () => _disconnect(context, ref),
                child: const Text('連携を解除'),
              ),
      ),
    );
  }

  String _accountTypeLabel(String? accountType) {
    return switch (accountType?.toUpperCase()) {
      'BUSINESS' => 'ビジネス',
      'MEDIA_CREATOR' => 'クリエイター',
      _ => '',
    };
  }

  Future<void> _connect(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(snsConnectControllerProvider(SnsProvider.instagram).notifier)
          .connect();
    } on SnsAuthorizationCancelledException {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('連携をキャンセルしました')));
    }
  }

  Future<void> _disconnect(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: '連携解除',
      message: 'Instagramとの連携を解除しますか?このアプリからの投稿ができなくなります。',
      confirmLabel: '解除する',
      isDestructive: true,
    );
    if (!confirmed) return;
    await ref
        .read(snsConnectControllerProvider(SnsProvider.instagram).notifier)
        .disconnect();
  }
}

class _XSection extends ConsumerWidget {
  const _XSection({required this.connection});

  final SnsConnection? connection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = ref
        .watch(snsConnectControllerProvider(SnsProvider.x))
        .isLoading;

    if (connection == null || !connection!.isConnected) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PrimaryButton(
                label: 'Xと連携する',
                isLoading: isBusy,
                onPressed: isBusy ? null : () => _connect(context, ref),
              ),
              if (isBusy) ...[const SizedBox(height: 8), const Text('連携処理中…')],
            ],
          ),
        ),
      );
    }

    final quotaAsync = ref.watch(xQuotaProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(connection!.username ?? '')),
                if (isBusy)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  TextButton(
                    onPressed: () => _disconnect(context, ref),
                    child: const Text('連携を解除'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            quotaAsync.when(
              data: (quota) => _XQuotaText(quota: quota),
              loading: () => const Text('残り回数を確認しています…'),
              error: (error, stackTrace) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _connect(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(snsConnectControllerProvider(SnsProvider.x).notifier)
          .connect();
    } on SnsAuthorizationCancelledException {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('連携をキャンセルしました')));
    }
  }

  Future<void> _disconnect(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: '連携解除',
      message: 'Xとの連携を解除しますか?このアプリからの投稿ができなくなります。',
      confirmLabel: '解除する',
      isDestructive: true,
    );
    if (!confirmed) return;
    await ref
        .read(snsConnectControllerProvider(SnsProvider.x).notifier)
        .disconnect();
  }
}

/// X残数表示(design.md「追補による既存章への変更点」節
/// 「ui章 S-07/S-09: X残数表示を…月次…ベースへ変更」準拠。
/// posting機能の `_XQuotaHint`(post_compose_screen.dart)と表示文言を揃えている)。
class _XQuotaText extends StatelessWidget {
  const _XQuotaText({required this.quota});

  final XQuota quota;

  @override
  Widget build(BuildContext context) {
    if (quota.isExhausted) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今月の投稿上限に達しています',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => context.goNamed(AppRoute.plan.name),
                child: const Text('プランを見る'),
              ),
            ],
          ),
        ],
      );
    }
    final creditHint = quota.creditBalance > 0
        ? '(+クレジット${quota.creditBalance}回)'
        : '';
    final dailyHint = quota.shouldShowDailyHint
        ? '\n本日あと${quota.dailyRemaining}回'
        : '';
    return Text('今月あと${quota.totalRemaining}回投稿できます$creditHint$dailyHint');
  }
}

/// S-09末尾「アカウント」セクション。サインアウト・アカウント削除
/// (App Store審査5.1.1(v)必須要件)・電話番号認証(無料プランのX投稿解放条件)を
/// まとめる(design.md 第9章「乱用対策」節「無料X枠の解放条件: SMS認証」準拠)。
class _AccountSection extends ConsumerWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _PhoneVerificationTile(),
          const Divider(height: 1),
          ListTile(
            title: const Text('サインアウト'),
            onTap: () => _signOut(context, ref),
          ),
          const Divider(height: 1),
          ListTile(
            title: Text(
              'アカウントを削除',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () => _deleteAccount(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'サインアウト',
      message: 'サインアウトしますか?',
      confirmLabel: 'サインアウトする',
      isDestructive: true,
    );
    if (!confirmed) return;
    try {
      await ref.read(authRepositoryProvider).signOut();
    } on AppException catch (e) {
      if (!context.mounted) return;
      final message = ErrorMapper.toUserMessage(e);
      if (message == null) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'アカウントを削除',
      message:
          'アカウントを削除すると、投稿履歴・SNS連携情報を含むすべてのデータが完全に削除されます。'
          'この操作は取り消せません。本当に削除しますか?',
      confirmLabel: '削除に進む',
      isDestructive: true,
    );
    if (!confirmed) return;
    if (!context.mounted) return;
    // 再認証(パスワード再入力)→ 削除実行。エラーはダイアログ内でインライン表示する。
    await showAccountDeletionDialog(context);
  }
}

/// 「電話番号認証」行。認証済みならマスク表示した電話番号を、未認証なら
/// 無料プランでのX投稿に必要である旨を表示する。タップで電話番号認証画面
/// (`PhoneVerificationScreen`)へ `Navigator.push` する。
class _PhoneVerificationTile extends ConsumerWidget {
  const _PhoneVerificationTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phoneNumber = ref.watch(linkedPhoneNumberProvider);
    final isVerified = phoneNumber != null;
    final maskedPhoneNumber = phoneNumber == null
        ? null
        : JapanPhoneNumberFormatter.maskForDisplay(phoneNumber);

    return ListTile(
      title: const Text('電話番号認証'),
      subtitle: Text(
        isVerified
            ? '${maskedPhoneNumber ?? phoneNumber} — 認証済み'
            : '未認証 — 無料プランでのX投稿に必要です',
      ),
      trailing: isVerified
          ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
          : const Icon(Icons.chevron_right),
      onTap: isVerified ? null : () => _openVerification(context, ref),
    );
  }

  Future<void> _openVerification(BuildContext context, WidgetRef ref) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const PhoneVerificationScreen()),
    );
    ref.invalidate(linkedPhoneNumberProvider);
  }
}

class _SnsAccountsSkeleton extends StatelessWidget {
  const _SnsAccountsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(2, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          height: 96,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}
