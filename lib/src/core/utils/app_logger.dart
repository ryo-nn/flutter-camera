import 'dart:developer' as developer;

/// プログラミングバグ(`Error` 系)を含む全ログの集約先。
/// (design.md「エラーハンドリング方針」: `FlutterError.onError` /
/// `PlatformDispatcher.instance.onError` で本クラスに集約する)
abstract final class AppLogger {
  static const _name = 'flutter_camera';

  static void info(String message) {
    developer.log(message, name: _name, level: 800);
  }

  static void warning(String message, {Object? error}) {
    developer.log(message, name: _name, level: 900, error: error);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: _name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
