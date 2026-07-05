// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 購入・リストアの実行と購入後の即時同期(design.md 課金章「feature追加」節
/// 「purchaseControllerProvider」+「購入・リストアの実行」節準拠)。
///
/// 購入キャンセルは `BillingService.purchase` が
/// `BillingException(cancelled: true)` を throw することで表現され、
/// `AsyncValue.guard` により本Controllerの `AsyncError` として保持される。
/// `error_mapper.dart` はキャンセル時に `null` を返すため、
/// `error_listener.dart` はSnackBarを表示しない(design.md「購入キャンセル:
/// 何も表示しない」準拠)。

@ProviderFor(PurchaseController)
final purchaseControllerProvider = PurchaseControllerProvider._();

/// 購入・リストアの実行と購入後の即時同期(design.md 課金章「feature追加」節
/// 「purchaseControllerProvider」+「購入・リストアの実行」節準拠)。
///
/// 購入キャンセルは `BillingService.purchase` が
/// `BillingException(cancelled: true)` を throw することで表現され、
/// `AsyncValue.guard` により本Controllerの `AsyncError` として保持される。
/// `error_mapper.dart` はキャンセル時に `null` を返すため、
/// `error_listener.dart` はSnackBarを表示しない(design.md「購入キャンセル:
/// 何も表示しない」準拠)。
final class PurchaseControllerProvider
    extends $AsyncNotifierProvider<PurchaseController, void> {
  /// 購入・リストアの実行と購入後の即時同期(design.md 課金章「feature追加」節
  /// 「purchaseControllerProvider」+「購入・リストアの実行」節準拠)。
  ///
  /// 購入キャンセルは `BillingService.purchase` が
  /// `BillingException(cancelled: true)` を throw することで表現され、
  /// `AsyncValue.guard` により本Controllerの `AsyncError` として保持される。
  /// `error_mapper.dart` はキャンセル時に `null` を返すため、
  /// `error_listener.dart` はSnackBarを表示しない(design.md「購入キャンセル:
  /// 何も表示しない」準拠)。
  PurchaseControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseControllerHash();

  @$internal
  @override
  PurchaseController create() => PurchaseController();
}

String _$purchaseControllerHash() =>
    r'5239b401eff03343674a9f89e267fedd14dd6028';

/// 購入・リストアの実行と購入後の即時同期(design.md 課金章「feature追加」節
/// 「purchaseControllerProvider」+「購入・リストアの実行」節準拠)。
///
/// 購入キャンセルは `BillingService.purchase` が
/// `BillingException(cancelled: true)` を throw することで表現され、
/// `AsyncValue.guard` により本Controllerの `AsyncError` として保持される。
/// `error_mapper.dart` はキャンセル時に `null` を返すため、
/// `error_listener.dart` はSnackBarを表示しない(design.md「購入キャンセル:
/// 何も表示しない」準拠)。

abstract class _$PurchaseController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
