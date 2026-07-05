// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'functions_sns_account_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 連携リポジトリ実装のDI(design.md アーキテクチャ章 `snsAccountRepositoryProvider`)。

@ProviderFor(snsAccountRepository)
final snsAccountRepositoryProvider = SnsAccountRepositoryProvider._();

/// 連携リポジトリ実装のDI(design.md アーキテクチャ章 `snsAccountRepositoryProvider`)。

final class SnsAccountRepositoryProvider
    extends
        $FunctionalProvider<
          SnsAccountRepository,
          SnsAccountRepository,
          SnsAccountRepository
        >
    with $Provider<SnsAccountRepository> {
  /// 連携リポジトリ実装のDI(design.md アーキテクチャ章 `snsAccountRepositoryProvider`)。
  SnsAccountRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'snsAccountRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$snsAccountRepositoryHash();

  @$internal
  @override
  $ProviderElement<SnsAccountRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SnsAccountRepository create(Ref ref) {
    return snsAccountRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SnsAccountRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SnsAccountRepository>(value),
    );
  }
}

String _$snsAccountRepositoryHash() =>
    r'78ee77f3148bcc6c86ed631771fbb7aa0bac6a6b';

/// Instagram / X の連携状態購読(design.md アーキテクチャ章 `snsConnectionsProvider`。
/// posting機能(`post_compose_screen.dart`)からも同一パスで参照される)。

@ProviderFor(snsConnections)
final snsConnectionsProvider = SnsConnectionsProvider._();

/// Instagram / X の連携状態購読(design.md アーキテクチャ章 `snsConnectionsProvider`。
/// posting機能(`post_compose_screen.dart`)からも同一パスで参照される)。

final class SnsConnectionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnsConnection>>,
          List<SnsConnection>,
          Stream<List<SnsConnection>>
        >
    with
        $FutureModifier<List<SnsConnection>>,
        $StreamProvider<List<SnsConnection>> {
  /// Instagram / X の連携状態購読(design.md アーキテクチャ章 `snsConnectionsProvider`。
  /// posting機能(`post_compose_screen.dart`)からも同一パスで参照される)。
  SnsConnectionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'snsConnectionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$snsConnectionsHash();

  @$internal
  @override
  $StreamProviderElement<List<SnsConnection>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SnsConnection>> create(Ref ref) {
    return snsConnections(ref);
  }
}

String _$snsConnectionsHash() => r'24afbcf99069745700aa6a5babcc9c9caffa40cb';
