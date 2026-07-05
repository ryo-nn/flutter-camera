// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_pattern_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 撮影フローで選択中のパターン(撮影→加工画面間で共有)。
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計
/// 「selectedPatternProvider」)
///
/// `null` = 「加工なし」。S-04(カメラ)・S-05(加工プレビュー)の
/// パターンカルーセルが共通で読み書きする(design.md 画面設計・UIフロー章 S-04/S-05準拠。
/// `camera/presentation/widgets/pattern_carousel.dart` が実際に
/// `ref.read(selectedPatternProvider.notifier).select(pattern)` の形で利用している)。

@ProviderFor(SelectedPattern)
final selectedPatternProvider = SelectedPatternProvider._();

/// 撮影フローで選択中のパターン(撮影→加工画面間で共有)。
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計
/// 「selectedPatternProvider」)
///
/// `null` = 「加工なし」。S-04(カメラ)・S-05(加工プレビュー)の
/// パターンカルーセルが共通で読み書きする(design.md 画面設計・UIフロー章 S-04/S-05準拠。
/// `camera/presentation/widgets/pattern_carousel.dart` が実際に
/// `ref.read(selectedPatternProvider.notifier).select(pattern)` の形で利用している)。
final class SelectedPatternProvider
    extends $NotifierProvider<SelectedPattern, Pattern?> {
  /// 撮影フローで選択中のパターン(撮影→加工画面間で共有)。
  /// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計
  /// 「selectedPatternProvider」)
  ///
  /// `null` = 「加工なし」。S-04(カメラ)・S-05(加工プレビュー)の
  /// パターンカルーセルが共通で読み書きする(design.md 画面設計・UIフロー章 S-04/S-05準拠。
  /// `camera/presentation/widgets/pattern_carousel.dart` が実際に
  /// `ref.read(selectedPatternProvider.notifier).select(pattern)` の形で利用している)。
  SelectedPatternProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedPatternProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedPatternHash();

  @$internal
  @override
  SelectedPattern create() => SelectedPattern();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Pattern? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Pattern?>(value),
    );
  }
}

String _$selectedPatternHash() => r'9504e81e986ef93d2719e325de4cc72c902f3141';

/// 撮影フローで選択中のパターン(撮影→加工画面間で共有)。
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計
/// 「selectedPatternProvider」)
///
/// `null` = 「加工なし」。S-04(カメラ)・S-05(加工プレビュー)の
/// パターンカルーセルが共通で読み書きする(design.md 画面設計・UIフロー章 S-04/S-05準拠。
/// `camera/presentation/widgets/pattern_carousel.dart` が実際に
/// `ref.read(selectedPatternProvider.notifier).select(pattern)` の形で利用している)。

abstract class _$SelectedPattern extends $Notifier<Pattern?> {
  Pattern? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Pattern?, Pattern?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Pattern?, Pattern?>,
              Pattern?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
