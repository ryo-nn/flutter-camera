import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_camera/src/common_widgets/primary_button.dart';
import 'package:flutter_camera/src/core/constants/app_durations.dart';
import 'package:flutter_camera/src/core/error/error_mapper.dart';
import 'package:flutter_camera/src/features/startup/app_startup_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S-01 スプラッシュ(design.md 画面設計・UIフロー章 S-01 参照)。
///
/// `appStartupProvider` の完了を待つのみで、ユーザー操作は受け付けない
/// (エラー時の再試行を除く)。遷移先の判定は行わず、`app_router.dart` の
/// redirect に一元化する(本画面から `context.go` は行わない)。
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _showSpinner = false;
  Timer? _spinnerTimer;

  @override
  void initState() {
    super.initState();
    // 「起動処理が1秒を超えた場合のみ CircularProgressIndicator を表示」
    // (design.md S-01「主要UI要素」準拠)。
    _spinnerTimer = Timer(AppDurations.splashSpinnerDelay, () {
      if (mounted) setState(() => _showSpinner = true);
    });
  }

  @override
  void dispose() {
    _spinnerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final startup = ref.watch(appStartupProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: startup.when(
            data: (_) => const _SplashLogo(),
            loading: () => _SplashLogo(showSpinner: _showSpinner),
            error: (error, stackTrace) => _SplashError(
              // ErrorMapper が UI 文言の唯一の場所(design.md「エラーハンドリング
              // 方針」)。null は理論上発生しない(NetworkExceptionは非null)が、
              // 型上のフォールバックとして error_mapper.dart 既存の
              // 未分類エラー文言(「予期しないエラーが発生しました。
              // 時間をおいて再度お試しください。」)と同一の既存文言を再利用する。
              message: ErrorMapper.toUserMessage(error) ??
                  '予期しないエラーが発生しました。時間をおいて再度お試しください。',
              onRetry: () => ref.invalidate(appStartupProvider),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo({this.showSpinner = false});

  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Icon(
            Icons.camera_alt_rounded,
            size: 96,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'flutter-camera',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        if (showSpinner) ...[
          const SizedBox(height: 32),
          const CircularProgressIndicator(),
        ],
      ],
    );
  }
}

class _SplashError extends StatelessWidget {
  const _SplashError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          PrimaryButton(label: '再試行', onPressed: onRetry),
        ],
      ),
    );
  }
}
