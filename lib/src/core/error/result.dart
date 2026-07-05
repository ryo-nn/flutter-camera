import 'package:flutter_camera/src/core/error/app_exception.dart';

/// 値として分岐が必要な同期処理向けの結果型。
/// (design.md アプリアーキテクチャ設計「エラーハンドリング方針」準拠。
/// I/O失敗は基本的に throw で `AsyncValue.error` に載せ、本型は
/// 入力バリデーション等 呼び出し側で switch 網羅処理したい箇所にのみ用いる)
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.exception);
  final AppException exception;
}
