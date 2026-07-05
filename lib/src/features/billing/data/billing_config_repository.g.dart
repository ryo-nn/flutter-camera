// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_config_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// S-10法定表記リンクの取得(design.md UIフロー章「日本語UI文言の方針」
/// 「法定表記リンク行」準拠)。未設定時は当該リンクを非表示にする(呼び出し側判断)。

@ProviderFor(billingLegalLinks)
final billingLegalLinksProvider = BillingLegalLinksProvider._();

/// S-10法定表記リンクの取得(design.md UIフロー章「日本語UI文言の方針」
/// 「法定表記リンク行」準拠)。未設定時は当該リンクを非表示にする(呼び出し側判断)。

final class BillingLegalLinksProvider
    extends
        $FunctionalProvider<
          AsyncValue<BillingLegalLinks>,
          BillingLegalLinks,
          FutureOr<BillingLegalLinks>
        >
    with
        $FutureModifier<BillingLegalLinks>,
        $FutureProvider<BillingLegalLinks> {
  /// S-10法定表記リンクの取得(design.md UIフロー章「日本語UI文言の方針」
  /// 「法定表記リンク行」準拠)。未設定時は当該リンクを非表示にする(呼び出し側判断)。
  BillingLegalLinksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'billingLegalLinksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$billingLegalLinksHash();

  @$internal
  @override
  $FutureProviderElement<BillingLegalLinks> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BillingLegalLinks> create(Ref ref) {
    return billingLegalLinks(ref);
  }
}

String _$billingLegalLinksHash() => r'2cda48f8362ec7dc26f21a020235056f32c9efbe';

/// S-10プランカードの特典説明(「X投稿 月◯回」)用。`appConfig/limits` の
/// プラン別設定値を読む(design.md 課金章 S-10節:
/// 「プラン特典のX枠回数(30/150回)の表示値は appConfig/limits のプラン別設定値
/// (quota担当が拡張)から取得し、クライアントにハードコードしない」準拠)。

@ProviderFor(planMonthlyPostLimits)
final planMonthlyPostLimitsProvider = PlanMonthlyPostLimitsProvider._();

/// S-10プランカードの特典説明(「X投稿 月◯回」)用。`appConfig/limits` の
/// プラン別設定値を読む(design.md 課金章 S-10節:
/// 「プラン特典のX枠回数(30/150回)の表示値は appConfig/limits のプラン別設定値
/// (quota担当が拡張)から取得し、クライアントにハードコードしない」準拠)。

final class PlanMonthlyPostLimitsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<Plan, int>>,
          Map<Plan, int>,
          FutureOr<Map<Plan, int>>
        >
    with $FutureModifier<Map<Plan, int>>, $FutureProvider<Map<Plan, int>> {
  /// S-10プランカードの特典説明(「X投稿 月◯回」)用。`appConfig/limits` の
  /// プラン別設定値を読む(design.md 課金章 S-10節:
  /// 「プラン特典のX枠回数(30/150回)の表示値は appConfig/limits のプラン別設定値
  /// (quota担当が拡張)から取得し、クライアントにハードコードしない」準拠)。
  PlanMonthlyPostLimitsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'planMonthlyPostLimitsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$planMonthlyPostLimitsHash();

  @$internal
  @override
  $FutureProviderElement<Map<Plan, int>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<Plan, int>> create(Ref ref) {
    return planMonthlyPostLimits(ref);
  }
}

String _$planMonthlyPostLimitsHash() =>
    r'6cacfef91b4c47aeb185a25d5c2a5e8c4633aad3';
