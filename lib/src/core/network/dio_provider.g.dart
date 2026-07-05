// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dio_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// design.md アプリアーキテクチャ設計「Riverpod 3.0 プロバイダー設計」準拠
/// (タイムアウト10秒・LogInterceptor付きのDio生成)。

@ProviderFor(dio)
final dioProvider = DioProvider._();

/// design.md アプリアーキテクチャ設計「Riverpod 3.0 プロバイダー設計」準拠
/// (タイムアウト10秒・LogInterceptor付きのDio生成)。

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// design.md アプリアーキテクチャ設計「Riverpod 3.0 プロバイダー設計」準拠
  /// (タイムアウト10秒・LogInterceptor付きのDio生成)。
  DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'407ec74764a947102ece7551c6082bce52ca98bf';
