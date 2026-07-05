import 'package:flutter/material.dart';
import 'package:flutter_camera/src/features/history/presentation/first_completion_celebration_provider.dart';
import 'package:flutter_camera/src/routing/app_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S-08 初回投稿完了直後の演出(design.md 第9章「3日トライアル導線の接続」節)の
/// 「はじめての投稿が完了しました」完了カード。
///
/// `post_history_screen.dart` が [firstCompletionCelebrationProvider] の状態変化を
/// `ref.listen` で検知して表示する。「つぎへ」操作のみで閉じる(戻る導線は持たない)。
Future<void> showFirstCompletionCard(BuildContext context, WidgetRef ref) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      title: const Text('はじめての投稿が完了しました'),
      content: const Text(
        'SNSへの初めての投稿、お疲れさまでした。\n'
        'これからも撮って、選んで、投稿するだけの手軽さをお楽しみください。',
      ),
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            ref
                .read(firstCompletionCelebrationProvider.notifier)
                .advanceToNotificationPermission();
          },
          child: const Text('つぎへ'),
        ),
      ],
    ),
  );
}

/// 完了カードの直後に表示する通知プレ許可ダイアログ。
///
/// 「許可する」でOSの通知許可リクエストを実行し、「あとで」では要求せずに
/// いずれもトライアルバナー表示へ進む([FirstCompletionCelebration] 側で処理)。
Future<void> showNotificationPermissionDialog(
  BuildContext context,
  WidgetRef ref,
) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      title: const Text('投稿の完了をお知らせします'),
      content: const Text(
        '投稿の処理が完了したタイミングを通知でお知らせします。\n'
        'あとから端末の設定でオフにすることもできます。',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            ref
                .read(firstCompletionCelebrationProvider.notifier)
                .skipNotificationPermission();
          },
          child: const Text('あとで'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            ref
                .read(firstCompletionCelebrationProvider.notifier)
                .requestNotificationPermission();
          },
          child: const Text('許可する'),
        ),
      ],
    ),
  );
}

/// 通知プレ許可ダイアログの直後に表示する「Proを3日間無料で試す」バナー
/// (design.md 第9章「初回のみ表示。オンボーディング中・初回投稿前にはペイウォールを
/// 割り込ませない=価値実感後に訴求する」準拠)。タップでS-10(ペイウォール)へ遷移する
/// (トライアル開始処理自体はbilling担当の [PaywallScreen] 側)。
class TrialBanner extends ConsumerWidget {
  const TrialBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onColor = Theme.of(context).colorScheme.onPrimaryContainer;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.pushNamed(AppRoute.plan.name),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.workspace_premium, color: onColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Proを3日間無料で試す',
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(color: onColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'プレミアムパターンやX投稿の上限アップが使えます',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: onColor),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: onColor),
                  tooltip: '閉じる',
                  onPressed: () => ref
                      .read(firstCompletionCelebrationProvider.notifier)
                      .dismissTrialBanner(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
