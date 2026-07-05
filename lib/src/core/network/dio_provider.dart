import 'package:dio/dio.dart';
import 'package:flutter_camera/src/core/constants/app_durations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_provider.g.dart';

/// design.md アプリアーキテクチャ設計「Riverpod 3.0 プロバイダー設計」準拠
/// (タイムアウト10秒・LogInterceptor付きのDio生成)。
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: AppDurations.networkTimeout,
      receiveTimeout: AppDurations.networkTimeout,
    ),
  );
  dio.interceptors.add(LogInterceptor());
  return dio;
}
