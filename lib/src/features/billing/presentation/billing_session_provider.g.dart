// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 認証状態に追従してRevenueCat SDKの configure/logIn/logOut を実行する常駐プロバイダー
/// (design.md 課金章「クライアント統合」節: 「`billingSessionProvider`(keepAlive)が
/// `authStateChangesProvider` を `ref.listen` し、サインイン→`ensureSession(uid)`、
/// サインアウト→`clearSession()` を実行する」準拠)。
///
/// `app.dart` で `ref.watch(billingSessionProvider)` により常駐させる
/// (`goRouterProvider` と同じ常駐パターン。design.md同節末尾の記載準拠)。

@ProviderFor(billingSession)
final billingSessionProvider = BillingSessionProvider._();

/// 認証状態に追従してRevenueCat SDKの configure/logIn/logOut を実行する常駐プロバイダー
/// (design.md 課金章「クライアント統合」節: 「`billingSessionProvider`(keepAlive)が
/// `authStateChangesProvider` を `ref.listen` し、サインイン→`ensureSession(uid)`、
/// サインアウト→`clearSession()` を実行する」準拠)。
///
/// `app.dart` で `ref.watch(billingSessionProvider)` により常駐させる
/// (`goRouterProvider` と同じ常駐パターン。design.md同節末尾の記載準拠)。

final class BillingSessionProvider extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// 認証状態に追従してRevenueCat SDKの configure/logIn/logOut を実行する常駐プロバイダー
  /// (design.md 課金章「クライアント統合」節: 「`billingSessionProvider`(keepAlive)が
  /// `authStateChangesProvider` を `ref.listen` し、サインイン→`ensureSession(uid)`、
  /// サインアウト→`clearSession()` を実行する」準拠)。
  ///
  /// `app.dart` で `ref.watch(billingSessionProvider)` により常駐させる
  /// (`goRouterProvider` と同じ常駐パターン。design.md同節末尾の記載準拠)。
  BillingSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'billingSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$billingSessionHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return billingSession(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$billingSessionHash() => r'45f0a3763b69a2805ff16f710d6894a3c3e3a3c4';
