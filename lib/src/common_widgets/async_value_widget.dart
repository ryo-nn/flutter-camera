import 'package:flutter/material.dart';
import 'package:flutter_camera/src/common_widgets/app_error_view.dart';
import 'package:flutter_camera/src/core/error/error_mapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// `ProviderOrFamily` は flutter_riverpod.dart のバレルからは公開されておらず、
// misc.dart から個別にエクスポートされている(riverpod 3.x の公開API仕様。実機で確認済み)。
import 'package:flutter_riverpod/misc.dart' show ProviderOrFamily;

/// `AsyncValue` の共通描画(data/loading/error)。
/// (design.md アプリアーキテクチャ設計 ディレクトリ構造 参照)
///
/// error時は [AppErrorView] を表示し、再試行は `ref.invalidate(retryable)` で行う。
class AsyncValueWidget<T> extends ConsumerWidget {
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    required this.retryable,
    this.loadingBuilder,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;

  /// 再試行時に `ref.invalidate` する対象。
  final ProviderOrFamily retryable;

  final WidgetBuilder? loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return value.when(
      data: data,
      loading: () =>
          loadingBuilder?.call(context) ??
          const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => AppErrorView(
        message: ErrorMapper.toUserMessage(error) ?? '読み込みに失敗しました。',
        onRetry: () => ref.invalidate(retryable),
      ),
    );
  }
}
