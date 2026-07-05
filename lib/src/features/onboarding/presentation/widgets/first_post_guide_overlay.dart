import 'package:flutter/material.dart';
import 'package:flutter_camera/src/features/onboarding/presentation/first_post_guide_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S-04用コーチマーク(design.md 第9章「S-04 初回投稿ガイド(コーチマーク)」参照)。
///
/// camera feature は本ウィジェットを画面の `Stack` 末尾(最前面)に配置する
/// (`Positioned` を内包するため、親は `Stack` である必要がある)。
/// 進捗更新はスクリーンリーダーへ自動通知する(design.md UIフロー章
/// 「アクセシビリティ配慮」: 「投稿処理モーダルの進捗更新は
/// `Semantics(liveRegion: true)` で自動通知」と同一方針)。
class FirstPostGuideOverlay extends ConsumerWidget {
  const FirstPostGuideOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(firstPostGuideProvider);
    if (step == null) return const SizedBox.shrink();

    final message = switch (step) {
      FirstPostGuideStep.selectPattern => 'プリセットを選んでみましょう',
      FirstPostGuideStep.shutter => 'シャッターで撮影',
    };

    return Positioned(
      left: 16,
      right: 16,
      bottom: 96,
      child: Semantics(
        liveRegion: true,
        child: Material(
          color: Theme.of(context).colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () =>
                      ref.read(firstPostGuideProvider.notifier).skip(),
                  child: Text(
                    'スキップ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// カルーセルのプリセットタイル・シャッターボタンをラップし、対応する
/// [FirstPostGuideStep] がアクティブな間だけ強調枠を表示する
/// (design.md「①プリセットタイルをハイライト」「②シャッターボタンをハイライト」の
/// 実装手段)。camera feature が各対象ウィジェットをこれでラップして使用する。
class FirstPostGuideHighlight extends ConsumerWidget {
  const FirstPostGuideHighlight({
    super.key,
    required this.step,
    required this.child,
  });

  /// このラップ対象がハイライト対象となる [FirstPostGuideStep]。
  final FirstPostGuideStep step;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeStep = ref.watch(firstPostGuideProvider);
    final isActive = activeStep == step;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: isActive ? 3 : 0,
        ),
      ),
      child: child,
    );
  }
}
