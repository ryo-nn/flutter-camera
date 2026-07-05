// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firestore_x_quota_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(xQuotaRepository)
final xQuotaRepositoryProvider = XQuotaRepositoryProvider._();

final class XQuotaRepositoryProvider
    extends
        $FunctionalProvider<
          XQuotaRepository,
          XQuotaRepository,
          XQuotaRepository
        >
    with $Provider<XQuotaRepository> {
  XQuotaRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'xQuotaRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$xQuotaRepositoryHash();

  @$internal
  @override
  $ProviderElement<XQuotaRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  XQuotaRepository create(Ref ref) {
    return xQuotaRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(XQuotaRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<XQuotaRepository>(value),
    );
  }
}

String _$xQuotaRepositoryHash() => r'0fb30244b614f464120c9b008acf551f26581183';

/// S-07/S-09/ペイウォールの残数表示の単一情報源(quota章「プロバイダー設計」節準拠)。

@ProviderFor(xQuota)
final xQuotaProvider = XQuotaProvider._();

/// S-07/S-09/ペイウォールの残数表示の単一情報源(quota章「プロバイダー設計」節準拠)。

final class XQuotaProvider
    extends $FunctionalProvider<AsyncValue<XQuota>, XQuota, Stream<XQuota>>
    with $FutureModifier<XQuota>, $StreamProvider<XQuota> {
  /// S-07/S-09/ペイウォールの残数表示の単一情報源(quota章「プロバイダー設計」節準拠)。
  XQuotaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'xQuotaProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$xQuotaHash();

  @$internal
  @override
  $StreamProviderElement<XQuota> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<XQuota> create(Ref ref) {
    return xQuota(ref);
  }
}

String _$xQuotaHash() => r'0b405cfbc14e84e768bbf490262f596abd750755';
