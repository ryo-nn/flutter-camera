// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_grant_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(onboardingGrantRepository)
final onboardingGrantRepositoryProvider = OnboardingGrantRepositoryProvider._();

final class OnboardingGrantRepositoryProvider
    extends
        $FunctionalProvider<
          OnboardingGrantRepository,
          OnboardingGrantRepository,
          OnboardingGrantRepository
        >
    with $Provider<OnboardingGrantRepository> {
  OnboardingGrantRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingGrantRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingGrantRepositoryHash();

  @$internal
  @override
  $ProviderElement<OnboardingGrantRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OnboardingGrantRepository create(Ref ref) {
    return onboardingGrantRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingGrantRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingGrantRepository>(value),
    );
  }
}

String _$onboardingGrantRepositoryHash() =>
    r'b07ae686aa3ff63b11ca0db96b90aeecebf4edb9';

/// `onboardingGrants/{uid}` 購読(design.md 第9章「プロバイダー追加」表 準拠。
/// `null` = 保証未消費)。S-07(posting feature)がX残回数表示の代わりに
/// 「初回無料」バッジを出す判定に用いる。
///
/// 未ログイン時は常に `null` を返す(グラント判定はログイン後のみ意味を持つ)。

@ProviderFor(onboardingGrant)
final onboardingGrantProvider = OnboardingGrantProvider._();

/// `onboardingGrants/{uid}` 購読(design.md 第9章「プロバイダー追加」表 準拠。
/// `null` = 保証未消費)。S-07(posting feature)がX残回数表示の代わりに
/// 「初回無料」バッジを出す判定に用いる。
///
/// 未ログイン時は常に `null` を返す(グラント判定はログイン後のみ意味を持つ)。

final class OnboardingGrantProvider
    extends
        $FunctionalProvider<
          AsyncValue<OnboardingGrant?>,
          OnboardingGrant?,
          Stream<OnboardingGrant?>
        >
    with $FutureModifier<OnboardingGrant?>, $StreamProvider<OnboardingGrant?> {
  /// `onboardingGrants/{uid}` 購読(design.md 第9章「プロバイダー追加」表 準拠。
  /// `null` = 保証未消費)。S-07(posting feature)がX残回数表示の代わりに
  /// 「初回無料」バッジを出す判定に用いる。
  ///
  /// 未ログイン時は常に `null` を返す(グラント判定はログイン後のみ意味を持つ)。
  OnboardingGrantProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingGrantProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingGrantHash();

  @$internal
  @override
  $StreamProviderElement<OnboardingGrant?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<OnboardingGrant?> create(Ref ref) {
    return onboardingGrant(ref);
  }
}

String _$onboardingGrantHash() => r'7370ce750db995141bd4197a492eca6665a8fbd3';
