// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_preview_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 画面5(加工プレビュー)のコントローラ(design.md アプリアーキテクチャ設計
/// プロバイダー設計「editPreviewControllerProvider」準拠)。
///
/// 撮影画像へのパターン適用・微調整・JPEG確定出力を担う。軽量プレビュー自体の
/// 描画([LightweightPatternPreview])はpresentation側でselectedPatternProviderの
/// 変化を直接watchして即時再構成するため、本コントローラは
/// (1) 正規化(初回のみ)、(2) パターン切替時のアセットprecache、
/// (3) 微調整(S-05a)結果の反映、(4) 最終JPEG確定、の非同期処理のみを担当する。

@ProviderFor(EditPreviewController)
final editPreviewControllerProvider = EditPreviewControllerFamily._();

/// 画面5(加工プレビュー)のコントローラ(design.md アプリアーキテクチャ設計
/// プロバイダー設計「editPreviewControllerProvider」準拠)。
///
/// 撮影画像へのパターン適用・微調整・JPEG確定出力を担う。軽量プレビュー自体の
/// 描画([LightweightPatternPreview])はpresentation側でselectedPatternProviderの
/// 変化を直接watchして即時再構成するため、本コントローラは
/// (1) 正規化(初回のみ)、(2) パターン切替時のアセットprecache、
/// (3) 微調整(S-05a)結果の反映、(4) 最終JPEG確定、の非同期処理のみを担当する。
final class EditPreviewControllerProvider
    extends $AsyncNotifierProvider<EditPreviewController, EditedImage> {
  /// 画面5(加工プレビュー)のコントローラ(design.md アプリアーキテクチャ設計
  /// プロバイダー設計「editPreviewControllerProvider」準拠)。
  ///
  /// 撮影画像へのパターン適用・微調整・JPEG確定出力を担う。軽量プレビュー自体の
  /// 描画([LightweightPatternPreview])はpresentation側でselectedPatternProviderの
  /// 変化を直接watchして即時再構成するため、本コントローラは
  /// (1) 正規化(初回のみ)、(2) パターン切替時のアセットprecache、
  /// (3) 微調整(S-05a)結果の反映、(4) 最終JPEG確定、の非同期処理のみを担当する。
  EditPreviewControllerProvider._({
    required EditPreviewControllerFamily super.from,
    required CapturedPhoto super.argument,
  }) : super(
         retry: null,
         name: r'editPreviewControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$editPreviewControllerHash();

  @override
  String toString() {
    return r'editPreviewControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EditPreviewController create() => EditPreviewController();

  @override
  bool operator ==(Object other) {
    return other is EditPreviewControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$editPreviewControllerHash() =>
    r'af7dd524c00a4f2a39a628edd642c5ee08f9d81d';

/// 画面5(加工プレビュー)のコントローラ(design.md アプリアーキテクチャ設計
/// プロバイダー設計「editPreviewControllerProvider」準拠)。
///
/// 撮影画像へのパターン適用・微調整・JPEG確定出力を担う。軽量プレビュー自体の
/// 描画([LightweightPatternPreview])はpresentation側でselectedPatternProviderの
/// 変化を直接watchして即時再構成するため、本コントローラは
/// (1) 正規化(初回のみ)、(2) パターン切替時のアセットprecache、
/// (3) 微調整(S-05a)結果の反映、(4) 最終JPEG確定、の非同期処理のみを担当する。

final class EditPreviewControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          EditPreviewController,
          AsyncValue<EditedImage>,
          EditedImage,
          FutureOr<EditedImage>,
          CapturedPhoto
        > {
  EditPreviewControllerFamily._()
    : super(
        retry: null,
        name: r'editPreviewControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 画面5(加工プレビュー)のコントローラ(design.md アプリアーキテクチャ設計
  /// プロバイダー設計「editPreviewControllerProvider」準拠)。
  ///
  /// 撮影画像へのパターン適用・微調整・JPEG確定出力を担う。軽量プレビュー自体の
  /// 描画([LightweightPatternPreview])はpresentation側でselectedPatternProviderの
  /// 変化を直接watchして即時再構成するため、本コントローラは
  /// (1) 正規化(初回のみ)、(2) パターン切替時のアセットprecache、
  /// (3) 微調整(S-05a)結果の反映、(4) 最終JPEG確定、の非同期処理のみを担当する。

  EditPreviewControllerProvider call(CapturedPhoto capturedPhoto) =>
      EditPreviewControllerProvider._(argument: capturedPhoto, from: this);

  @override
  String toString() => r'editPreviewControllerProvider';
}

/// 画面5(加工プレビュー)のコントローラ(design.md アプリアーキテクチャ設計
/// プロバイダー設計「editPreviewControllerProvider」準拠)。
///
/// 撮影画像へのパターン適用・微調整・JPEG確定出力を担う。軽量プレビュー自体の
/// 描画([LightweightPatternPreview])はpresentation側でselectedPatternProviderの
/// 変化を直接watchして即時再構成するため、本コントローラは
/// (1) 正規化(初回のみ)、(2) パターン切替時のアセットprecache、
/// (3) 微調整(S-05a)結果の反映、(4) 最終JPEG確定、の非同期処理のみを担当する。

abstract class _$EditPreviewController extends $AsyncNotifier<EditedImage> {
  late final _$args = ref.$arg as CapturedPhoto;
  CapturedPhoto get capturedPhoto => _$args;

  FutureOr<EditedImage> build(CapturedPhoto capturedPhoto);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<EditedImage>, EditedImage>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<EditedImage>, EditedImage>,
              AsyncValue<EditedImage>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
