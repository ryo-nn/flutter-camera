import 'package:flutter/material.dart';
import 'package:flutter_camera/src/core/error/error_mapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// `ProviderListenable` は flutter_riverpod.dart のバレルからは公開されておらず、
// misc.dart から個別にエクスポートされている(riverpod 3.x の公開API仕様。実機で確認済み)。
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;

/// Controller の `AsyncValue` を監視して SnackBar を出す共通拡張。
/// 各画面はこれを1行呼ぶだけにする(design.md「エラーハンドリング方針」準拠)。
extension AsyncErrorListener on WidgetRef {
  void listenAppError(
    ProviderListenable<AsyncValue<Object?>> provider,
    BuildContext context,
  ) {
    listen(provider, (prev, next) {
      if (next case AsyncError(:final error)) {
        final message = ErrorMapper.toUserMessage(error);
        // null の場合は非エラー扱い(例: 購入キャンセル)。SnackBarを出さない。
        if (message == null) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });
  }
}
