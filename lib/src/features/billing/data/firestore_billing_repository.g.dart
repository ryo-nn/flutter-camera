// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firestore_billing_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// `billing/state` 購読と `rcRefreshCustomer` 呼び出しのDI
/// (design.md「billingRepositoryProvider」準拠)。

@ProviderFor(billingRepository)
final billingRepositoryProvider = BillingRepositoryProvider._();

/// `billing/state` 購読と `rcRefreshCustomer` 呼び出しのDI
/// (design.md「billingRepositoryProvider」準拠)。

final class BillingRepositoryProvider
    extends
        $FunctionalProvider<
          BillingRepository,
          BillingRepository,
          BillingRepository
        >
    with $Provider<BillingRepository> {
  /// `billing/state` 購読と `rcRefreshCustomer` 呼び出しのDI
  /// (design.md「billingRepositoryProvider」準拠)。
  BillingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'billingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$billingRepositoryHash();

  @$internal
  @override
  $ProviderElement<BillingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BillingRepository create(Ref ref) {
    return billingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BillingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BillingRepository>(value),
    );
  }
}

String _$billingRepositoryHash() => r'de85b4ec441605eae6248a0328cdeee5f2319860';

/// `users/{uid}/billing/state` の購読(サーバー正。design.md「billingStateProvider」
/// 準拠。不存在時は [BillingState.initial] を返す)。

@ProviderFor(billingState)
final billingStateProvider = BillingStateProvider._();

/// `users/{uid}/billing/state` の購読(サーバー正。design.md「billingStateProvider」
/// 準拠。不存在時は [BillingState.initial] を返す)。

final class BillingStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<BillingState>,
          BillingState,
          Stream<BillingState>
        >
    with $FutureModifier<BillingState>, $StreamProvider<BillingState> {
  /// `users/{uid}/billing/state` の購読(サーバー正。design.md「billingStateProvider」
  /// 準拠。不存在時は [BillingState.initial] を返す)。
  BillingStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'billingStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$billingStateHash();

  @$internal
  @override
  $StreamProviderElement<BillingState> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<BillingState> create(Ref ref) {
    return billingState(ref);
  }
}

String _$billingStateHash() => r'58e3d2a582f999346abe64703f326864eb4e363b';

/// S-07残枠表示・パターンgating等の参照点(design.md「currentPlanProvider」準拠。
/// プラン解決規則2(読み取り時失効ガード込み)で `Plan` を導出する)。
///
/// NOTE(coreChangeRequests参照): `patterns/presentation/pattern_list_screen.dart`
/// は本プロバイダーを `billing/domain/billing_state.dart` から import する想定で
/// 実装されている(想定パスとして自己申告済み)が、domain層はdata層に依存できない
/// 規約(design.md「レイヤー責務と依存方向」)のため、本プロバイダーの実体は
/// data層(本ファイル)に置く。統合フェーズでimport元の修正が必要。

@ProviderFor(currentPlan)
final currentPlanProvider = CurrentPlanProvider._();

/// S-07残枠表示・パターンgating等の参照点(design.md「currentPlanProvider」準拠。
/// プラン解決規則2(読み取り時失効ガード込み)で `Plan` を導出する)。
///
/// NOTE(coreChangeRequests参照): `patterns/presentation/pattern_list_screen.dart`
/// は本プロバイダーを `billing/domain/billing_state.dart` から import する想定で
/// 実装されている(想定パスとして自己申告済み)が、domain層はdata層に依存できない
/// 規約(design.md「レイヤー責務と依存方向」)のため、本プロバイダーの実体は
/// data層(本ファイル)に置く。統合フェーズでimport元の修正が必要。

final class CurrentPlanProvider extends $FunctionalProvider<Plan, Plan, Plan>
    with $Provider<Plan> {
  /// S-07残枠表示・パターンgating等の参照点(design.md「currentPlanProvider」準拠。
  /// プラン解決規則2(読み取り時失効ガード込み)で `Plan` を導出する)。
  ///
  /// NOTE(coreChangeRequests参照): `patterns/presentation/pattern_list_screen.dart`
  /// は本プロバイダーを `billing/domain/billing_state.dart` から import する想定で
  /// 実装されている(想定パスとして自己申告済み)が、domain層はdata層に依存できない
  /// 規約(design.md「レイヤー責務と依存方向」)のため、本プロバイダーの実体は
  /// data層(本ファイル)に置く。統合フェーズでimport元の修正が必要。
  CurrentPlanProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentPlanProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentPlanHash();

  @$internal
  @override
  $ProviderElement<Plan> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Plan create(Ref ref) {
    return currentPlan(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Plan value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Plan>(value),
    );
  }
}

String _$currentPlanHash() => r'ecc8f6144816e4694702428bcaafae64d4eb380a';
