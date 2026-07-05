// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// オンボーディング完了フラグの保持(design.md アプリアーキテクチャ設計
/// 「Riverpod 3.0 プロバイダー設計」準拠)。
///
/// `build()` は永続化復元前の安全な既定値 `false` を返す。実際の復元は
/// `appStartupProvider` が起動時に一度だけ [restore] を呼んで行う
/// (design.md「GoRouterルーティング設計」: redirect 再評価契機の一つとして
/// 本プロバイダーの変化を `ref.listen` する)。

@ProviderFor(OnboardingState)
final onboardingStateProvider = OnboardingStateProvider._();

/// オンボーディング完了フラグの保持(design.md アプリアーキテクチャ設計
/// 「Riverpod 3.0 プロバイダー設計」準拠)。
///
/// `build()` は永続化復元前の安全な既定値 `false` を返す。実際の復元は
/// `appStartupProvider` が起動時に一度だけ [restore] を呼んで行う
/// (design.md「GoRouterルーティング設計」: redirect 再評価契機の一つとして
/// 本プロバイダーの変化を `ref.listen` する)。
final class OnboardingStateProvider
    extends $NotifierProvider<OnboardingState, bool> {
  /// オンボーディング完了フラグの保持(design.md アプリアーキテクチャ設計
  /// 「Riverpod 3.0 プロバイダー設計」準拠)。
  ///
  /// `build()` は永続化復元前の安全な既定値 `false` を返す。実際の復元は
  /// `appStartupProvider` が起動時に一度だけ [restore] を呼んで行う
  /// (design.md「GoRouterルーティング設計」: redirect 再評価契機の一つとして
  /// 本プロバイダーの変化を `ref.listen` する)。
  OnboardingStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingStateHash();

  @$internal
  @override
  OnboardingState create() => OnboardingState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$onboardingStateHash() => r'3585b766ea5d6247378e3a60f151796ee3e8ee7d';

/// オンボーディング完了フラグの保持(design.md アプリアーキテクチャ設計
/// 「Riverpod 3.0 プロバイダー設計」準拠)。
///
/// `build()` は永続化復元前の安全な既定値 `false` を返す。実際の復元は
/// `appStartupProvider` が起動時に一度だけ [restore] を呼んで行う
/// (design.md「GoRouterルーティング設計」: redirect 再評価契機の一つとして
/// 本プロバイダーの変化を `ref.listen` する)。

abstract class _$OnboardingState extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
