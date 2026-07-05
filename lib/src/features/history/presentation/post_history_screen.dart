import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera/src/common_widgets/app_error_view.dart';
import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/core/error/error_mapper.dart';
import 'package:flutter_camera/src/core/firebase/firebase_providers.dart';
import 'package:flutter_camera/src/features/history/data/firestore_post_history_repository.dart';
import 'package:flutter_camera/src/features/history/presentation/first_completion_celebration_provider.dart';
import 'package:flutter_camera/src/features/history/presentation/monthly_stats_provider.dart';
import 'package:flutter_camera/src/features/history/presentation/widgets/dashboard_summary.dart';
import 'package:flutter_camera/src/features/history/presentation/widgets/first_completion_celebration_widgets.dart';
import 'package:flutter_camera/src/features/posting/domain/post.dart';
import 'package:flutter_camera/src/features/posting/domain/post_target_status.dart';
import 'package:flutter_camera/src/routing/app_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 画面8 投稿履歴/ステータス画面(成果ダッシュボード + 時系列一覧)。
/// design.md UIフロー章 S-08節 + retention章「成果ダッシュボード(S-08改訂)」節 準拠。
class PostHistoryScreen extends ConsumerWidget {
  const PostHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(postHistoryProvider);

    // S-08 初回投稿完了直後の演出(design.md 第9章「3日トライアル導線の接続」節)。
    // 完了カード・通知プレ許可ダイアログはステップ遷移のたびに一度だけ表示する
    // (トライアルバナーはダイアログではなく `_HistoryBody` 内にインライン表示するため
    // ここでは扱わない)。
    ref.listen<FirstCompletionCelebrationStep?>(firstCompletionCelebrationProvider, (
      previous,
      next,
    ) {
      switch (next) {
        case FirstCompletionCelebrationStep.completionCard:
          unawaited(showFirstCompletionCard(context, ref));
        case FirstCompletionCelebrationStep.notificationPermission:
          unawaited(showNotificationPermissionDialog(context, ref));
        case FirstCompletionCelebrationStep.trialBanner:
        case null:
          break;
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('投稿履歴')),
      body: historyAsync.when(
        data: (posts) => _HistoryBody(posts: posts),
        loading: () => const _HistorySkeleton(),
        error: (error, stackTrace) => AppErrorView(
          message: ErrorMapper.toUserMessage(error) ?? '投稿履歴を読み込めませんでした',
          onRetry: () => ref.invalidate(postHistoryProvider),
        ),
      ),
    );
  }
}

class _HistorySkeleton extends StatelessWidget {
  const _HistorySkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(
        5,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 72,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class _HistoryBody extends ConsumerWidget {
  const _HistoryBody({required this.posts});

  final List<Post> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (posts.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => ref.invalidate(postHistoryProvider),
        child: ListView(
          children: [
            const SizedBox(height: 120),
            const Center(child: Text('まだ投稿がありません。撮影してみましょう。')),
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton(
                onPressed: () => context.goNamed(AppRoute.home.name),
                child: const Text('撮影する'),
              ),
            ),
          ],
        ),
      );
    }

    final statsAsync = ref.watch(monthlyStatsProvider);
    // S-08 初回投稿完了直後の演出(design.md 第9章「3日トライアル導線の接続」節)の
    // 最終ステップ。ダイアログではなくダッシュボード上部にインライン表示する。
    final showTrialBanner =
        ref.watch(firstCompletionCelebrationProvider) ==
        FirstCompletionCelebrationStep.trialBanner;
    final leadingCount = showTrialBanner ? 2 : 1;
    final statsIndex = showTrialBanner ? 1 : 0;

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(postHistoryProvider),
      child: ListView.builder(
        itemCount: posts.length + leadingCount,
        itemBuilder: (context, index) {
          if (showTrialBanner && index == 0) {
            return const TrialBanner();
          }
          if (index == statsIndex) {
            return statsAsync.when(
              data: (stats) => DashboardSummary(stats: stats),
              loading: () => const SizedBox(
                height: 96,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => const SizedBox.shrink(),
            );
          }
          final post = posts[index - leadingCount];
          return _PostHistoryTile(
            post: post,
            onTap: () => _showDetail(context, post),
          );
        },
      ),
    );
  }

  void _showDetail(BuildContext context, Post post) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PostDetailSheet(post: post),
    );
  }
}

class _PostHistoryTile extends StatelessWidget {
  const _PostHistoryTile({required this.post, required this.onTap});

  final Post post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateLabel = _formatDate(post.createdAt);
    return ListTile(
      onTap: onTap,
      leading: _PostThumbnail(
        imagePath: post.imagePath,
        label: '$dateLabelの投稿画像',
      ),
      title: Text(dateLabel),
      subtitle: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          if (post.instagram.selected)
            _StatusChip(label: 'Instagram', target: post.instagram),
          if (post.x.selected) _StatusChip(label: 'X', target: post.x),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.target});

  final String label;
  final PostTarget target;

  @override
  Widget build(BuildContext context) {
    final (icon, color, text) = switch (target.status) {
      PostTargetStatus.succeeded => (
        Icons.check_circle,
        Colors.green,
        '$label 成功',
      ),
      PostTargetStatus.failed => (
        Icons.cancel,
        Theme.of(context).colorScheme.error,
        '$label 失敗',
      ),
      _ => (Icons.hourglass_top, Colors.grey, '投稿中'),
    };
    return Semantics(
      label:
          target.status == PostTargetStatus.failed &&
              target.errorMessage != null
          ? '$label、投稿失敗、${_failureReason(target)}'
          : '$label、$text',
      excludeSemantics: true,
      child: Chip(
        avatar: Icon(icon, color: color, size: 18),
        label: Text(text),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _PostThumbnail extends ConsumerStatefulWidget {
  const _PostThumbnail({required this.imagePath, required this.label});

  final String imagePath;
  final String label;

  @override
  ConsumerState<_PostThumbnail> createState() => _PostThumbnailState();
}

class _PostThumbnailState extends ConsumerState<_PostThumbnail> {
  late final Future<String> _urlFuture;

  @override
  void initState() {
    super.initState();
    // FutureBuilderのfutureは毎ビルド再生成しない(再生成すると再フェッチ・
    // ちらつきの原因になる)。initStateで一度だけ取得する。
    _urlFuture = ref
        .read(firebaseStorageProvider)
        .ref(widget.imagePath)
        .getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      image: true,
      child: FutureBuilder<String>(
        future: _urlFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(
              width: 48,
              height: 48,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          return ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: snapshot.data!,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}

class _PostDetailSheet extends StatelessWidget {
  const _PostDetailSheet({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          _PostThumbnail(imagePath: post.imagePath, label: '投稿画像'),
          const SizedBox(height: 16),
          Text(post.caption.isEmpty ? '(キャプションなし)' : post.caption),
          const Divider(height: 32),
          if (post.instagram.selected)
            _DetailTargetRow(label: 'Instagram', target: post.instagram),
          if (post.x.selected) _DetailTargetRow(label: 'X', target: post.x),
        ],
      ),
    );
  }
}

class _DetailTargetRow extends StatelessWidget {
  const _DetailTargetRow({required this.label, required this.target});

  final String label;
  final PostTarget target;

  @override
  Widget build(BuildContext context) {
    final isSuccess = target.status == PostTargetStatus.succeeded;
    final isFailed = target.status == PostTargetStatus.failed;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSuccess
                    ? Icons.check_circle
                    : isFailed
                    ? Icons.cancel
                    : Icons.hourglass_top,
                color: isSuccess
                    ? Colors.green
                    : isFailed
                    ? Theme.of(context).colorScheme.error
                    : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(label, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          if (isFailed) ...[
            const SizedBox(height: 4),
            Text(_failureReason(target)),
            if (target.errorCode == 'ig_not_professional') ...[
              const SizedBox(height: 4),
              TextButton(
                onPressed: () =>
                    context.goNamed(AppRoute.instagramProGuide.name),
                child: const Text('プロアカウント切替の手順を見る'),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// 「◯月◯日 HH:mm」形式の簡易日時フォーマット(`intl` パッケージが本プロジェクトの
/// 依存関係に未追加のため、素のDartのみで実装する。coreChangeRequests参照)。
String _formatDate(DateTime dateTime) {
  final local = dateTime.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.month}月${local.day}日 $hour:$minute';
}

/// backend章「onCallエラーコード一覧」+ quota/retention章追加分の `errorCode` を
/// `ErrorMapper` 経由で日本語文言化する(UI章「エラー文言は必ずerror_mapperで一元化」
/// 方針準拠。Firestoreの生 `errorMessage` は開発者向けログ用のため画面には出さない)。
String _failureReason(PostTarget target) {
  if (target.errorCode == null) {
    return '投稿に失敗しました。時間をおいて再度お試しください。';
  }
  return ErrorMapper.toUserMessage(
        SnsPostException(
          target.errorMessage ?? '',
          provider: target.provider,
          apiErrorCode: target.errorCode,
        ),
      ) ??
      '投稿に失敗しました。時間をおいて再度お試しください。';
}
