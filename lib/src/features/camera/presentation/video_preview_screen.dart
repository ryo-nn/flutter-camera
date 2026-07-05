import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_camera/src/common_widgets/app_error_view.dart';
import 'package:flutter_camera/src/common_widgets/confirm_dialog.dart';
import 'package:flutter_camera/src/common_widgets/primary_button.dart';
import 'package:flutter_camera/src/features/camera/domain/captured_video.dart';
import 'package:flutter_camera/src/features/posting/domain/post_media.dart';
import 'package:flutter_camera/src/features/posting/domain/video_content_type.dart';
import 'package:flutter_camera/src/routing/app_route.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

/// S-05v 動画プレビュー画面(design.md追補: フォトライブラリ取り込み・動画撮影モード
/// 追加分)。
///
/// 動画加工(パターン適用等)はv1対象外のため、S-05(加工プレビュー)のような
/// 正規化・パターン適用パイプラインは経由しない。`video_player` による再生確認
/// (再生/一時停止・ループ)のみを行い、「次へ」で動画の長さ・ファイルサイズを
/// 確定して S-07(SNS投稿画面)へ引き継ぐ。
class VideoPreviewScreen extends StatefulWidget {
  const VideoPreviewScreen({super.key, required this.capturedVideo});

  final CapturedVideo capturedVideo;

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  late final VideoPlayerController _controller;
  bool _isPreparing = true;
  bool _hasError = false;
  bool _isProceeding = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(
      File(widget.capturedVideo.videoPath),
    )..setLooping(true);
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      await _controller.initialize();
      if (!mounted) return;
      setState(() => _isPreparing = false);
      await _controller.play();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isPreparing = false;
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_controller.value.isPlaying) {
      await _controller.pause();
    } else {
      await _controller.play();
    }
    if (mounted) setState(() {});
  }

  /// 「撮り直す」: 確認ダイアログ経由でS-04へ戻る(S-05の既存の作法と同一)。
  Future<void> _confirmDiscardAndLeave() async {
    final confirmed = await showConfirmDialog(
      context,
      title: '撮影に戻りますか?',
      message: '撮影した動画を破棄して撮影に戻りますか?',
      confirmLabel: '破棄する',
      isDestructive: true,
    );
    if (confirmed && mounted) {
      context.go(AppRoute.home.path);
    }
  }

  /// 「次へ」: 動画の長さ・ファイルサイズを確定して S-07 へ引き継ぐ。
  Future<void> _proceed() async {
    if (_isProceeding) return;
    setState(() => _isProceeding = true);
    try {
      final duration = _controller.value.duration;
      final fileSizeBytes = await File(widget.capturedVideo.videoPath).length();
      final media = PostMedia.video(
        filePath: widget.capturedVideo.videoPath,
        durationSec: duration.inMicroseconds / Duration.microsecondsPerSecond,
        fileSizeBytes: fileSizeBytes,
        contentType: VideoContentType.fromFilePath(widget.capturedVideo.videoPath),
      );
      if (!mounted) return;
      context.pushNamed(AppRoute.postCompose.name, extra: media);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('動画の情報を取得できませんでした。もう一度お試しください。')),
      );
    } finally {
      if (mounted) setState(() => _isProceeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controlsDisabled = _isProceeding;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _confirmDiscardAndLeave();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('動画プレビュー')),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(child: _buildPreviewArea()),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: controlsDisabled
                            ? null
                            : _confirmDiscardAndLeave,
                        child: const Text('撮り直す'),
                      ),
                    ),
                    Expanded(
                      child: PrimaryButton(
                        label: '次へ',
                        isLoading: _isProceeding,
                        onPressed: (_isPreparing || _hasError || controlsDisabled)
                            ? null
                            : _proceed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewArea() {
    if (_hasError) {
      return AppErrorView(
        message: '動画を再生できませんでした。',
        onRetry: () {
          setState(() {
            _isPreparing = true;
            _hasError = false;
          });
          _initializePlayer();
        },
      );
    }
    if (_isPreparing) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: GestureDetector(
        onTap: _togglePlayback,
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_controller),
              if (!_controller.value.isPlaying)
                const Icon(Icons.play_arrow, size: 64, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}
