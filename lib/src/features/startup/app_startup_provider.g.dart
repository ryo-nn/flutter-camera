// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_startup_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// アプリ起動処理(design.md アプリアーキテクチャ設計「アーキテクチャ全体像」
/// 「Riverpod 3.0 プロバイダー設計」準拠)。
///
/// `main.dart` は `Firebase.initializeApp` 前の最小処理のみを行い、
/// Firebase初期化・オンボーディングフラグ復元は本プロバイダーに集約する。
/// 完了(`AsyncData`)まで S-01 スプラッシュが表示され続け、`app_router.dart` の
/// redirect が `startup.isLoading || startup.hasError` を判定して遷移を止める。
///
/// 小規模のため domain/data 層を設けない(startup feature の設計方針)。

@ProviderFor(appStartup)
final appStartupProvider = AppStartupProvider._();

/// アプリ起動処理(design.md アプリアーキテクチャ設計「アーキテクチャ全体像」
/// 「Riverpod 3.0 プロバイダー設計」準拠)。
///
/// `main.dart` は `Firebase.initializeApp` 前の最小処理のみを行い、
/// Firebase初期化・オンボーディングフラグ復元は本プロバイダーに集約する。
/// 完了(`AsyncData`)まで S-01 スプラッシュが表示され続け、`app_router.dart` の
/// redirect が `startup.isLoading || startup.hasError` を判定して遷移を止める。
///
/// 小規模のため domain/data 層を設けない(startup feature の設計方針)。

final class AppStartupProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// アプリ起動処理(design.md アプリアーキテクチャ設計「アーキテクチャ全体像」
  /// 「Riverpod 3.0 プロバイダー設計」準拠)。
  ///
  /// `main.dart` は `Firebase.initializeApp` 前の最小処理のみを行い、
  /// Firebase初期化・オンボーディングフラグ復元は本プロバイダーに集約する。
  /// 完了(`AsyncData`)まで S-01 スプラッシュが表示され続け、`app_router.dart` の
  /// redirect が `startup.isLoading || startup.hasError` を判定して遷移を止める。
  ///
  /// 小規模のため domain/data 層を設けない(startup feature の設計方針)。
  AppStartupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appStartupProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appStartupHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return appStartup(ref);
  }
}

String _$appStartupHash() => r'8d8a16e6b30b23539d0da5ed3cfd800beebedd58';
