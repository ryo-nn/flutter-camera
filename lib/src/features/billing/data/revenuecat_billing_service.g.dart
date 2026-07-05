// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revenuecat_billing_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// purchases_flutterラッパのDI
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計「billingServiceProvider」)。

@ProviderFor(billingService)
final billingServiceProvider = BillingServiceProvider._();

/// purchases_flutterラッパのDI
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計「billingServiceProvider」)。

final class BillingServiceProvider
    extends $FunctionalProvider<BillingService, BillingService, BillingService>
    with $Provider<BillingService> {
  /// purchases_flutterラッパのDI
  /// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計「billingServiceProvider」)。
  BillingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'billingServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$billingServiceHash();

  @$internal
  @override
  $ProviderElement<BillingService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BillingService create(Ref ref) {
    return billingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BillingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BillingService>(value),
    );
  }
}

String _$billingServiceHash() => r'ea82d0cb943de82c1863b63db218e720c18611b0';

/// `addCustomerInfoUpdateListener` のStream化(楽観的UI反映専用。
/// design.md 課金章「feature追加」節「customerInfoProvider」準拠。枠判定には使わない)。

@ProviderFor(customerInfo)
final customerInfoProvider = CustomerInfoProvider._();

/// `addCustomerInfoUpdateListener` のStream化(楽観的UI反映専用。
/// design.md 課金章「feature追加」節「customerInfoProvider」準拠。枠判定には使わない)。

final class CustomerInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<CustomerInfo>,
          CustomerInfo,
          Stream<CustomerInfo>
        >
    with $FutureModifier<CustomerInfo>, $StreamProvider<CustomerInfo> {
  /// `addCustomerInfoUpdateListener` のStream化(楽観的UI反映専用。
  /// design.md 課金章「feature追加」節「customerInfoProvider」準拠。枠判定には使わない)。
  CustomerInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customerInfoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customerInfoHash();

  @$internal
  @override
  $StreamProviderElement<CustomerInfo> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<CustomerInfo> create(Ref ref) {
    return customerInfo(ref);
  }
}

String _$customerInfoHash() => r'5d9a93a233fa386a029925dc1128cd8238ceec8d';

/// current offering の取得(S-10表示用。design.md「offeringsProvider」準拠)。

@ProviderFor(offerings)
final offeringsProvider = OfferingsProvider._();

/// current offering の取得(S-10表示用。design.md「offeringsProvider」準拠)。

final class OfferingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Offerings>,
          Offerings,
          FutureOr<Offerings>
        >
    with $FutureModifier<Offerings>, $FutureProvider<Offerings> {
  /// current offering の取得(S-10表示用。design.md「offeringsProvider」準拠)。
  OfferingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offeringsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offeringsHash();

  @$internal
  @override
  $FutureProviderElement<Offerings> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Offerings> create(Ref ref) {
    return offerings(ref);
  }
}

String _$offeringsHash() => r'74e7d5a53c091a4ade2f483b036c76acabab7f94';

/// Proトライアル適格判定(design.md「proTrialEligibilityProvider」準拠)。
/// current offeringに `pro_monthly` パッケージが無い場合は非適格扱いとする。

@ProviderFor(proTrialEligibility)
final proTrialEligibilityProvider = ProTrialEligibilityProvider._();

/// Proトライアル適格判定(design.md「proTrialEligibilityProvider」準拠)。
/// current offeringに `pro_monthly` パッケージが無い場合は非適格扱いとする。

final class ProTrialEligibilityProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Proトライアル適格判定(design.md「proTrialEligibilityProvider」準拠)。
  /// current offeringに `pro_monthly` パッケージが無い場合は非適格扱いとする。
  ProTrialEligibilityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proTrialEligibilityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proTrialEligibilityHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return proTrialEligibility(ref);
  }
}

String _$proTrialEligibilityHash() =>
    r'314cef97f26d88e789925313dcfd390a3d517648';
