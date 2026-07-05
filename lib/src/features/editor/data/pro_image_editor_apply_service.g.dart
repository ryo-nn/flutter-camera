// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_image_editor_apply_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// パターン適用サービスのDI(design.md アプリアーキテクチャ設計
/// プロバイダー設計「patternApplyServiceProvider」準拠)。

@ProviderFor(patternApplyService)
final patternApplyServiceProvider = PatternApplyServiceProvider._();

/// パターン適用サービスのDI(design.md アプリアーキテクチャ設計
/// プロバイダー設計「patternApplyServiceProvider」準拠)。

final class PatternApplyServiceProvider
    extends
        $FunctionalProvider<
          PatternApplyService,
          PatternApplyService,
          PatternApplyService
        >
    with $Provider<PatternApplyService> {
  /// パターン適用サービスのDI(design.md アプリアーキテクチャ設計
  /// プロバイダー設計「patternApplyServiceProvider」準拠)。
  PatternApplyServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'patternApplyServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$patternApplyServiceHash();

  @$internal
  @override
  $ProviderElement<PatternApplyService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PatternApplyService create(Ref ref) {
    return patternApplyService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PatternApplyService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PatternApplyService>(value),
    );
  }
}

String _$patternApplyServiceHash() =>
    r'7f96d5047db19ca7624362e310b495d8306478e7';
