import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_camera/src/app.dart';
import 'package:flutter_camera/src/core/utils/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// エントリポイント。`Firebase.initializeApp` 前の最小処理 + `ProviderScope` + `runApp` のみを
/// 行う。起動処理本体(Firebase初期化・オンボーディングフラグ復元等)は
/// `appStartupProvider` に集約し、完了までスプラッシュを表示する
/// (design.md アプリアーキテクチャ設計「アーキテクチャ全体像」準拠)。
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // プログラミングバグ(`Error` 系)を握りつぶさず `AppLogger` に集約する
  // (design.md「エラーハンドリング方針」準拠)。
  FlutterError.onError = (details) {
    AppLogger.error(
      details.exceptionAsString(),
      error: details.exception,
      stackTrace: details.stack,
    );
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    AppLogger.error(error.toString(), error: error, stackTrace: stackTrace);
    return true;
  };

  runApp(const ProviderScope(child: App()));
}
