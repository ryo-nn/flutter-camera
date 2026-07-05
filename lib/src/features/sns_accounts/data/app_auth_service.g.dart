// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_auth_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// flutter_appauthラッパのDI(design.md アーキテクチャ章 `appAuthServiceProvider`)。

@ProviderFor(appAuthService)
final appAuthServiceProvider = AppAuthServiceProvider._();

/// flutter_appauthラッパのDI(design.md アーキテクチャ章 `appAuthServiceProvider`)。

final class AppAuthServiceProvider
    extends $FunctionalProvider<AppAuthService, AppAuthService, AppAuthService>
    with $Provider<AppAuthService> {
  /// flutter_appauthラッパのDI(design.md アーキテクチャ章 `appAuthServiceProvider`)。
  AppAuthServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appAuthServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appAuthServiceHash();

  @$internal
  @override
  $ProviderElement<AppAuthService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppAuthService create(Ref ref) {
    return appAuthService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppAuthService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppAuthService>(value),
    );
  }
}

String _$appAuthServiceHash() => r'28cab2e6a53509f6d367ab536bddeff5278956fe';
