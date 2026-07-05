import 'package:flutter/material.dart';
import 'package:flutter_camera/src/common_widgets/primary_button.dart';
import 'package:flutter_camera/src/core/error/error_listener.dart';
import 'package:flutter_camera/src/core/models/sns_provider.dart';
import 'package:flutter_camera/src/features/sns_accounts/domain/sns_authorization.dart';
import 'package:flutter_camera/src/features/sns_accounts/presentation/sns_connect_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// coreChangeRequests参照: url_launcher が pubspec.yaml 未追加のため要追加依頼
// (camera featureの `app_settings` 追加依頼と同様のパターン)。
import 'package:url_launcher/url_launcher.dart';

/// 画面9a Instagramプロアカウント切替案内画面(design.md UIフロー章 S-09a準拠)。
///
/// [InstagramProGuideMode.settings]: S-09(連携設定)・S-07・S-08の非プロ検出/失敗理由
/// から到達する通常経路。「再連携する」でS-09の連携フローを再実行できる。
/// [InstagramProGuideMode.onboarding]: design.md「追補による既存章への変更点」節
/// 「S-02オンボーディングのページ内容を改訂(…プロアカウント切替ガイドリンク…)」に対応する
/// 未認証到達経路(`/onboarding/instagram-guide`)。未ログインのため連携の再実行はできず、
/// 「再連携する」ボタンは表示しない(routing/app_router.dart で実装済みの2ルートから
/// 同一Widgetを再利用する設計。notes参照)。
class InstagramProGuideScreen extends ConsumerWidget {
  const InstagramProGuideScreen({super.key, required this.mode});

  final InstagramProGuideMode mode;

  static const _steps = [
    'Instagramアプリでプロフィールを開き、右上のメニューから「設定とアクティビティ」を開く',
    '「アカウントの種類とツール」をタップ',
    '「プロアカウントに切り替える」をタップ',
    'カテゴリを選び、「クリエイター」または「ビジネス」を選択して完了',
    'このアプリに戻り「再連携する」をタップ',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSettingsMode = mode == InstagramProGuideMode.settings;
    if (isSettingsMode) {
      ref.listenAppError(
        snsConnectControllerProvider(SnsProvider.instagram),
        context,
      );
    }
    final isBusy =
        isSettingsMode &&
        ref
            .watch(snsConnectControllerProvider(SnsProvider.instagram))
            .isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Instagramプロアカウントへの切り替え')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            ExcludeSemantics(
              child: Icon(
                Icons.warning_amber,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Instagramプロアカウントへの切り替えが必要です',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const Text(
              'Instagramの仕様により、このアプリから投稿できるのはプロアカウント'
              '(ビジネスまたはクリエイター)のみです。連携されたアカウントは個人アカウント'
              'のため投稿できません。',
            ),
            const SizedBox(height: 16),
            const Text('切り替えは無料で、いつでも個人アカウントに戻せます。'),
            const SizedBox(height: 24),
            for (var i = 0; i < _steps.length; i++)
              _StepTile(index: i + 1, text: _steps[i]),
            const SizedBox(height: 16),
            Text(
              'メニューの名称はInstagramアプリの更新により変わる場合があります。'
              '最新の手順は公式ヘルプをご確認ください。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _openHelp,
              child: const Text('Instagram公式ヘルプで手順を見る'),
            ),
            if (isSettingsMode) ...[
              const SizedBox(height: 12),
              PrimaryButton(
                label: '再連携する',
                isLoading: isBusy,
                onPressed: isBusy ? null : () => _reconnect(context, ref),
              ),
            ],
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(isSettingsMode ? 'あとで' : '戻る'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openHelp() async {
    final uri = Uri.parse('https://help.instagram.com/502981923235522');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _reconnect(BuildContext context, WidgetRef ref) async {
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
}

enum InstagramProGuideMode { onboarding, settings }

class _StepTile extends StatelessWidget {
  const _StepTile({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 12, child: Text('$index')),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
