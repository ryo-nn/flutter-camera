// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// GoRouter 生成(redirect / refreshListenable 配線)。
/// (design.md アプリアーキテクチャ設計「GoRouterルーティング設計」
/// + 第9章「リテンション機能設計 による変更」の redirect 改訂を反映した最終形)

@ProviderFor(goRouter)
final goRouterProvider = GoRouterProvider._();

/// GoRouter 生成(redirect / refreshListenable 配線)。
/// (design.md アプリアーキテクチャ設計「GoRouterルーティング設計」
/// + 第9章「リテンション機能設計 による変更」の redirect 改訂を反映した最終形)

final class GoRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// GoRouter 生成(redirect / refreshListenable 配線)。
  /// (design.md アプリアーキテクチャ設計「GoRouterルーティング設計」
  /// + 第9章「リテンション機能設計 による変更」の redirect 改訂を反映した最終形)
  GoRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return goRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$goRouterHash() => r'9ffc3a899aeb95a6aeec3e95b98d8e7a6ed23d62';
