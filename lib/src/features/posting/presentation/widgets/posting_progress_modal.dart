import 'package:flutter/material.dart';
import 'package:flutter_camera/src/core/models/sns_provider.dart';
import 'package:flutter_camera/src/features/posting/data/functions_post_repository.dart';
import 'package:flutter_camera/src/features/posting/domain/post.dart';
import 'package:flutter_camera/src/features/posting/domain/post_target_failure_reason.dart';
import 'package:flutter_camera/src/features/posting/domain/post_target_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S-07「投稿する」実行後の全画面進捗モーダル。
/// (UIフロー章 S-07節「posting: 全画面モーダルでSNSごとの進捗行」準拠。
/// モーダル表示中は閉じられない=誤操作防止)
///
/// `posts/{postId}` をリアルタイム購読して進捗行を描画するだけの「dumb」な
/// ウィジェットとし、終端状態(succeeded/partial/failed)検知後のモーダルクローズ・
/// S-08への遷移は呼び出し元(`PostComposeScreen`)が自身の安定した
/// `BuildContext` で行う(モーダル自身のcontextはpop直後に無効化されるため、
/// pop→go を同一widgetのcontextで連続実行すると
/// 「deactivated widgetのlookup」エラーになり得る事故を避けるための設計)。
class PostingProgressModal extends ConsumerWidget {
  const PostingProgressModal({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postStatusProvider(postId));

    return PopScope(
      canPop: false,
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: postAsync.when(
            data: (post) => _ProgressBody(post: post),
            loading: () => const _LoadingBody(),
            error: (error, stackTrace) => const _LoadingBody(),
          ),
        ),
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('投稿を準備しています…'),
      ],
    );
  }
}

class _ProgressBody extends StatelessWidget {
  const _ProgressBody({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('投稿しています', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (post.instagram.selected)
          Semantics(
            liveRegion: true,
            child: _TargetProgressRow(
              label: 'Instagram',
              target: post.instagram,
            ),
          ),
        if (post.instagram.selected && post.x.selected)
          const SizedBox(height: 12),
        if (post.x.selected)
          Semantics(
            liveRegion: true,
            child: _TargetProgressRow(label: 'X', target: post.x),
          ),
      ],
    );
  }
}

class _TargetProgressRow extends StatelessWidget {
  const _TargetProgressRow({required this.label, required this.target});

  final String label;
  final PostTarget target;

  @override
  Widget build(BuildContext context) {
    final (icon, color, text) = switch (target.status) {
      PostTargetStatus.succeeded => (
        Icons.check_circle,
        Colors.green,
        '$labelへの投稿が完了しました',
      ),
      PostTargetStatus.failed => (
        Icons.cancel,
        Theme.of(context).colorScheme.error,
        '$labelへの投稿に失敗しました',
      ),
      PostTargetStatus.processing => (
        Icons.autorenew,
        Colors.grey,
        target.provider == SnsProvider.instagram
            ? 'Instagramへアップロード・投稿中…'
            : 'Xへ投稿中…',
      ),
      _ => (Icons.hourglass_empty, Colors.grey, '$labelへの投稿を待機中…'),
    };
    // design.md 画面設計・UIフロー章「アクセシビリティ配慮」: S-07のステータス行は
    // 「X、投稿失敗、本日の投稿上限に達しました」のように結果と理由を読み上げ可能にする
    // (S-08のステータスチップと同じ `postTargetFailureReason` を用いた文言統一)。
    final semanticsLabel =
        target.status == PostTargetStatus.failed && target.errorMessage != null
        ? '$label、投稿失敗、${postTargetFailureReason(target)}'
        : text;
    return Semantics(
      label: semanticsLabel,
      excludeSemantics: true,
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
