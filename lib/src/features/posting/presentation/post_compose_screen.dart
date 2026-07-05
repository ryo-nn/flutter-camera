import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_camera/src/common_widgets/app_error_view.dart';
import 'package:flutter_camera/src/common_widgets/confirm_dialog.dart';
import 'package:flutter_camera/src/common_widgets/primary_button.dart';
import 'package:flutter_camera/src/core/device/device_id_service.dart';
import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/core/error/error_mapper.dart';
import 'package:flutter_camera/src/core/models/sns_provider.dart';
import 'package:flutter_camera/src/features/posting/data/firestore_x_quota_repository.dart';
import 'package:flutter_camera/src/features/posting/data/functions_post_repository.dart';
import 'package:flutter_camera/src/features/posting/domain/caption_rules.dart';
import 'package:flutter_camera/src/features/posting/domain/post_media.dart';
import 'package:flutter_camera/src/features/posting/domain/post_target_status.dart';
import 'package:flutter_camera/src/features/posting/domain/video_target_rules.dart';
import 'package:flutter_camera/src/features/posting/domain/x_quota.dart';
import 'package:flutter_camera/src/features/posting/presentation/post_compose_controller.dart';
import 'package:flutter_camera/src/features/posting/presentation/widgets/posting_progress_modal.dart';
import 'package:flutter_camera/src/routing/app_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// auth featureは未実装だが、既存 routing/app_router.dart が同一パスで
// authStateChangesProvider を参照しており、配置は確認済み(notes参照)。
import 'package:flutter_camera/src/features/auth/data/firebase_auth_repository.dart';
// sns_accounts featureは未実装。design.mdディレクトリ構造の
// `functions_sns_account_repository.dart # トークン交換 Functions 呼び出し・連携状態購読`
// というコメントから `snsConnectionsProvider` の配置場所を推測している。
// `SnsConnection` のフィールド名(provider/status/username/isProAccount)も
// 設計書「Freezed(provider/接続状態/アカウント名/プロ判定)」からの推測。notes参照。
import 'package:flutter_camera/src/features/sns_accounts/data/functions_sns_account_repository.dart';
import 'package:flutter_camera/src/features/sns_accounts/domain/sns_connection.dart';

/// 画面7 SNS投稿画面(投稿先選択・キャプション入力・URL検出ブロックバリデーション・
/// X残回数表示・一括投稿の実行)。design.md UIフロー章 S-07節 準拠。
///
/// 動画対応追加分: [media] は画像(`PostMedia.image`)・動画(`PostMedia.video`)の
/// いずれも受け付ける。動画の場合はIG/Xそれぞれのターゲット別バリデーション
/// (`VideoTargetRules`)によりチェック不可+理由表示を行う。
class PostComposeScreen extends ConsumerStatefulWidget {
  const PostComposeScreen({super.key, required this.media});

  final PostMedia media;

  @override
  ConsumerState<PostComposeScreen> createState() => _PostComposeScreenState();
}

class _PostComposeScreenState extends ConsumerState<PostComposeScreen> {
  final _captionController = TextEditingController();
  bool _instagramSelected = false;
  bool _xSelected = false;
  String? _shownPostId;
  String? _navigatedPostId;

  @override
  void initState() {
    super.initState();
    _captionController.addListener(_onCaptionChanged);
  }

  @override
  void dispose() {
    _captionController.removeListener(_onCaptionChanged);
    _captionController.dispose();
    super.dispose();
  }

  void _onCaptionChanged() => setState(() {});

  bool get _hasSelection => _instagramSelected || _xSelected;

  String get _caption => _captionController.text;

  bool get _instagramExceeded {
    if (!_instagramSelected) return false;
    return _caption.length > CaptionRules.instagramMaxLength ||
        CaptionRules.instagramHashtagCount(_caption) >
            CaptionRules.instagramMaxHashtags ||
        CaptionRules.instagramMentionCount(_caption) >
            CaptionRules.instagramMaxMentions;
  }

  bool get _xUrlDetected => _xSelected && CaptionRules.containsUrl(_caption);

  bool get _xExceeded {
    if (!_xSelected) return false;
    return CaptionRules.xWeightedLength(_caption) >
        CaptionRules.xMaxWeightedLength;
  }

  /// 動画対応追加分: IG/Xそれぞれのターゲット別動画バリデーション
  /// (design.md追補「ターゲット別バリデーション」)。画像の場合は常に `null`。
  String? get _instagramVideoIneligibleReason {
    final media = widget.media;
    if (media is! PostMediaVideo) return null;
    return VideoTargetRules.instagramIneligibleReason(
      durationSec: media.durationSec,
      fileSizeBytes: media.fileSizeBytes,
    );
  }

  String? get _xVideoIneligibleReason {
    final media = widget.media;
    if (media is! PostMediaVideo) return null;
    return VideoTargetRules.xIneligibleReason(
      durationSec: media.durationSec,
      fileSizeBytes: media.fileSizeBytes,
      contentType: media.contentType,
    );
  }

  bool get _instagramVideoBlocked =>
      _instagramSelected && _instagramVideoIneligibleReason != null;

  bool get _xVideoBlocked => _xSelected && _xVideoIneligibleReason != null;

  bool get _canSubmit =>
      _hasSelection &&
      !_instagramExceeded &&
      !_xExceeded &&
      !_xUrlDetected &&
      !_instagramVideoBlocked &&
      !_xVideoBlocked;

  @override
  Widget build(BuildContext context) {
    ref.listen(postComposeControllerProvider, (previous, next) {
      if (next case AsyncError(:final error)) {
        if (error is SnsPostException &&
            error.apiErrorCode == 'x_phone_verification_required') {
          // freeプランでのX投稿にはSMS認証が必要(quota章「デバイス単位の無料枠管理」節
          // (0)節準拠)。通常のエラー表示(SnackBar)ではなく、S-09(SNS連携設定)への
          // 導線を持つダイアログで案内する。
          unawaited(_showPhoneVerificationRequiredDialog());
          return;
        }
        final message = ErrorMapper.toUserMessage(error);
        // null の場合は非エラー扱い(例: 購入キャンセル)。SnackBarを出さない。
        if (message == null) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    });
    ref.listen(postComposeControllerProvider, (previous, next) {
      final postId = next.value;
      if (postId != null && postId != _shownPostId) {
        _shownPostId = postId;
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => PostingProgressModal(postId: postId),
        );
      }
    });

    // 進捗モーダルのクローズ・S-08への置換遷移は、モーダル自身のcontextではなく
    // 本画面(PostComposeScreen)の安定したcontextで行う(モーダルのcontextは
    // pop直後に無効化されるため、pop→go を同一contextで連続実行すると事故になり得る)。
    final shownPostId = _shownPostId;
    if (shownPostId != null) {
      ref.listen(postStatusProvider(shownPostId), (previous, next) {
        final post = next.value;
        if (post == null || _navigatedPostId == shownPostId) return;
        final terminal =
            post.overallStatus == PostOverallStatus.succeeded ||
            post.overallStatus == PostOverallStatus.partial ||
            post.overallStatus == PostOverallStatus.failed;
        if (!terminal) return;
        _navigatedPostId = shownPostId;
        final navigator = Navigator.of(context, rootNavigator: true);
        if (navigator.canPop()) navigator.pop();
        context.goNamed(AppRoute.history.name);
      });
    }

    final connectionsAsync = ref.watch(snsConnectionsProvider);
    final controllerState = ref.watch(postComposeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('SNSに投稿')),
      body: connectionsAsync.when(
        data: (connections) => _buildBody(context, connections),
        loading: () => const _PostComposeSkeleton(),
        error: (error, stackTrace) => AppErrorView(
          message: ErrorMapper.toUserMessage(error) ?? '投稿先の状態を確認できませんでした',
          onRetry: () => ref.invalidate(snsConnectionsProvider),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: PrimaryButton(
          label: '投稿する',
          isLoading: controllerState.isLoading,
          onPressed: _canSubmit ? _handleSubmit : null,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<SnsConnection> connections) {
    final instagramConnection = _connectionFor(
      connections,
      SnsProvider.instagram,
    );
    final xConnection = _connectionFor(connections, SnsProvider.x);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildThumbnail(),
        const SizedBox(height: 24),
        Text('投稿先', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _InstagramTargetRow(
          connection: instagramConnection,
          selected: _instagramSelected,
          onChanged: (v) => setState(() => _instagramSelected = v),
          ineligibleReason: _instagramVideoIneligibleReason,
          showReelNote: widget.media is PostMediaVideo,
        ),
        const SizedBox(height: 12),
        _XTargetRow(
          connection: xConnection,
          selected: _xSelected,
          onChanged: (v) => setState(() => _xSelected = v),
          ineligibleReason: _xVideoIneligibleReason,
        ),
        const SizedBox(height: 24),
        Text('キャプション', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _captionController,
          minLines: 4,
          maxLines: 8,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'キャプションを入力',
          ),
        ),
        const SizedBox(height: 8),
        _buildCounters(context),
      ],
    );
  }

  /// 動画対応追加分: サムネイル生成パッケージを追加しないため、動画は再生アイコン+
  /// ファイル情報(長さ・サイズ)のプレースホルダーで代替する(design.md追補)。
  Widget _buildThumbnail() {
    return switch (widget.media) {
      PostMediaImage(:final editedImage) => _ImageThumbnail(
        filePath: editedImage.filePath,
      ),
      PostMediaVideo(:final durationSec, :final fileSizeBytes) =>
        _VideoInfoThumbnail(
          durationSec: durationSec,
          fileSizeBytes: fileSizeBytes,
        ),
    };
  }

  Widget _buildCounters(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;
    final rows = <Widget>[];
    if (_instagramSelected) {
      final remaining = CaptionRules.instagramMaxLength - _caption.length;
      rows.add(
        Text(
          'Instagram: 残り$remaining文字'
          '(ハッシュタグ${CaptionRules.instagramHashtagCount(_caption)}/${CaptionRules.instagramMaxHashtags}・'
          '@タグ${CaptionRules.instagramMentionCount(_caption)}/${CaptionRules.instagramMaxMentions})',
          style: TextStyle(color: _instagramExceeded ? errorColor : null),
        ),
      );
    }
    if (_xSelected) {
      final remaining =
          CaptionRules.xMaxWeightedLength -
          CaptionRules.xWeightedLength(_caption);
      rows.add(
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'X: あと$remaining文字',
            style: TextStyle(color: _xExceeded ? errorColor : null),
          ),
        ),
      );
      if (_xUrlDetected) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Xへの投稿では、本文にURLを含めることができません',
              style: TextStyle(color: errorColor),
            ),
          ),
        );
      }
    }
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }

  Future<void> _handleSubmit() async {
    final confirmed = await showConfirmDialog(
      context,
      title: '投稿確認',
      message: '選択したSNSに投稿します。よろしいですか?',
      confirmLabel: '投稿する',
    );
    if (!confirmed) return;
    if (!mounted) return;

    final uid = ref.read(authStateChangesProvider).value?.uid;
    if (uid == null) {
      // redirectにより通常到達しない想定だが、念のためエラーハンドリング方針に
      // 沿ってSnackBarで案内する(error_mapper.dartのAuthException文言を利用)。
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ErrorMapper.toUserMessage(
                  const AuthException('ログインが必要です', code: 'not-authenticated'),
                ) ??
                'ログインが必要です',
          ),
        ),
      );
      return;
    }

    // deviceId/platformはfreeプランでXターゲットを選択した場合にサーバー側が
    // 要求する(quota章「デバイス単位の無料枠管理」節)。Xターゲット未選択時は
    // プラットフォームチャネル呼び出し自体が不要なため取得しない。
    String? deviceId;
    String? platform;
    if (_xSelected) {
      final deviceIdService = ref.read(deviceIdServiceProvider);
      deviceId = await deviceIdService.getDeviceId();
      platform = deviceIdService.getPlatform();
      if (!mounted) return;
    }

    await ref
        .read(postComposeControllerProvider.notifier)
        .submit(
          uid: uid,
          media: widget.media,
          caption: _caption,
          instagram: _instagramSelected,
          x: _xSelected,
          deviceId: deviceId,
          platform: platform,
        );
  }

  /// design.md quota章「(0)freeプランのSMS認証クレーム検証」節に対応する誘導
  /// (`x_phone_verification_required`。サーバーの `X_PHONE_VERIFICATION_REQUIRED`
  /// reasonに対応)。「設定へ」でS-09(SNS連携設定)へ遷移する。
  Future<void> _showPhoneVerificationRequiredDialog() async {
    if (!mounted) return;
    final confirmed = await showConfirmDialog(
      context,
      title: '電話番号認証が必要です',
      message: '無料プランでXへ投稿するには電話番号認証が必要です。',
      confirmLabel: '設定へ',
    );
    if (!confirmed || !mounted) return;
    context.goNamed(AppRoute.snsAccounts.name);
  }

  SnsConnection? _connectionFor(
    List<SnsConnection> connections,
    SnsProvider provider,
  ) {
    for (final c in connections) {
      if (c.provider == provider) return c;
    }
    return null;
  }
}

class _PostComposeSkeleton extends StatelessWidget {
  const _PostComposeSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 56,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class _ImageThumbnail extends StatelessWidget {
  const _ImageThumbnail({required this.filePath});

  final String filePath;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => Dialog(
          child: Semantics(
            label: '投稿画像の拡大表示',
            image: true,
            child: Image.file(File(filePath)),
          ),
        ),
      ),
      child: Semantics(
        label: '投稿画像のサムネイル。タップで拡大表示',
        image: true,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.file(File(filePath), fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

/// 動画対応追加分: サムネイル生成パッケージを追加しないため、再生アイコン+
/// ファイル情報(長さ・サイズ)で代替する(design.md追補)。
class _VideoInfoThumbnail extends StatelessWidget {
  const _VideoInfoThumbnail({
    required this.durationSec,
    required this.fileSizeBytes,
  });

  final double durationSec;
  final int fileSizeBytes;

  @override
  Widget build(BuildContext context) {
    final totalSeconds = durationSec.round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final durationLabel = minutes > 0 ? '$minutes分$seconds秒' : '$seconds秒';
    final sizeMb = fileSizeBytes / (1024 * 1024);
    final label = '動画・$durationLabel・${sizeMb.toStringAsFixed(1)}MB';

    return Semantics(
      label: '投稿動画のサムネイル。$label',
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: 1,
          child: ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_fill,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InstagramTargetRow extends StatelessWidget {
  const _InstagramTargetRow({
    required this.connection,
    required this.selected,
    required this.onChanged,
    this.ineligibleReason,
    this.showReelNote = false,
  });

  final SnsConnection? connection;
  final bool selected;
  final ValueChanged<bool> onChanged;

  /// 動画対応追加分: 非nullの場合、チェック不可+理由表示にする
  /// (design.md追補「ターゲット別バリデーション」)。
  final String? ineligibleReason;

  /// 動画対応追加分: 「Instagramへはリールとして投稿されます」の注記表示可否。
  final bool showReelNote;

  @override
  Widget build(BuildContext context) {
    final status = connection?.status;
    if (status != SnsConnectionStatus.connected) {
      return _DisconnectedRow(
        label: 'Instagram',
        onConnect: () => context.goNamed(AppRoute.snsAccounts.name),
      );
    }
    if (connection?.isProAccount == false) {
      return Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: ListTile(
          leading: const Icon(Icons.warning_amber),
          title: const Text('プロアカウントへの切り替えが必要です'),
          subtitle: const Text('Instagram'),
          trailing: TextButton(
            onPressed: () => context.goNamed(AppRoute.instagramProGuide.name),
            child: const Text('手順を見る'),
          ),
        ),
      );
    }
    final reason = ineligibleReason;
    final errorColor = Theme.of(context).colorScheme.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          value: selected,
          onChanged: reason == null ? (v) => onChanged(v ?? false) : null,
          title: const Text('Instagram'),
          subtitle: Text(reason ?? connection?.username ?? ''),
          secondary: const Icon(Icons.camera_alt),
        ),
        if (reason != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(reason, style: TextStyle(color: errorColor)),
          ),
        if (reason == null && showReelNote)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Instagramへはリールとして投稿されます',
              style: TextStyle(fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class _XTargetRow extends ConsumerWidget {
  const _XTargetRow({
    required this.connection,
    required this.selected,
    required this.onChanged,
    this.ineligibleReason,
  });

  final SnsConnection? connection;
  final bool selected;
  final ValueChanged<bool> onChanged;

  /// 動画対応追加分: 非nullの場合、チェック不可+理由表示にする
  /// (design.md追補「ターゲット別バリデーション」)。
  final String? ineligibleReason;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (connection?.status != SnsConnectionStatus.connected) {
      return _DisconnectedRow(
        label: 'X',
        onConnect: () => context.goNamed(AppRoute.snsAccounts.name),
      );
    }

    final quotaAsync = ref.watch(xQuotaProvider);
    final reason = ineligibleReason;

    return Card(
      child: Column(
        children: [
          quotaAsync.when(
            data: (quota) => CheckboxListTile(
              value: selected,
              onChanged: (quota.isExhausted || reason != null)
                  ? null
                  : (v) => onChanged(v ?? false),
              title: const Text('X'),
              subtitle: Text(connection?.username ?? ''),
              secondary: const Icon(Icons.alternate_email),
            ),
            loading: () => const CheckboxListTile(
              value: false,
              onChanged: null,
              title: Text('X'),
              subtitle: Text('残り回数を確認しています…'),
            ),
            error: (error, stackTrace) => CheckboxListTile(
              value: selected,
              onChanged: reason == null ? (v) => onChanged(v ?? false) : null,
              title: const Text('X'),
              subtitle: Text(connection?.username ?? ''),
            ),
          ),
          if (reason != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                reason,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          quotaAsync.maybeWhen(
            data: (quota) => _XQuotaHint(quota: quota),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _XQuotaHint extends StatelessWidget {
  const _XQuotaHint({required this.quota});

  final XQuota quota;

  @override
  Widget build(BuildContext context) {
    if (quota.isExhausted) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今月の投稿上限に達しました',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () => context.goNamed(AppRoute.plan.name),
                  child: const Text('プランを変更'),
                ),
                OutlinedButton(
                  onPressed: () => context.goNamed(AppRoute.plan.name),
                  child: const Text('クレジットを購入'),
                ),
              ],
            ),
          ],
        ),
      );
    }
    final creditHint = quota.creditBalance > 0
        ? '(+クレジット${quota.creditBalance}回)'
        : '';
    final dailyHint = quota.shouldShowDailyHint
        ? '\n本日あと${quota.dailyRemaining}回'
        : '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Text('今月あと${quota.totalRemaining}回$creditHint$dailyHint'),
    );
  }
}

class _DisconnectedRow extends StatelessWidget {
  const _DisconnectedRow({required this.label, required this.onConnect});

  final String label;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label),
        subtitle: const Text('未連携'),
        trailing: OutlinedButton(
          onPressed: onConnect,
          child: const Text('連携する'),
        ),
      ),
    );
  }
}
