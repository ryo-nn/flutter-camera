import 'dart:async';

import 'package:flutter_camera/src/features/billing/data/firestore_billing_repository.dart';
import 'package:flutter_camera/src/features/billing/data/revenuecat_billing_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart' show Package;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'purchase_controller.g.dart';

/// 購入・リストアの実行と購入後の即時同期(design.md 課金章「feature追加」節
/// 「purchaseControllerProvider」+「購入・リストアの実行」節準拠)。
///
/// 購入キャンセルは `BillingService.purchase` が
/// `BillingException(cancelled: true)` を throw することで表現され、
/// `AsyncValue.guard` により本Controllerの `AsyncError` として保持される。
/// `error_mapper.dart` はキャンセル時に `null` を返すため、
/// `error_listener.dart` はSnackBarを表示しない(design.md「購入キャンセル:
/// 何も表示しない」準拠)。
@riverpod
class PurchaseController extends _$PurchaseController {
  @override
  FutureOr<void> build() {}

  /// パッケージ購入を実行し、webhook到達を待たず即時同期を要求する。
  Future<void> purchase(Package package) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(billingServiceProvider).purchase(package);
      await ref.read(billingRepositoryProvider).refreshCustomer();
    });
  }

  /// 購入の復元(Apple審査必須)。復元後も即時同期を要求する。
  ///
  /// 戻り値は「復元できる購入が実際にあったか」(S-10のSnackBar分岐に使用。
  /// design.md の骨子コードは `Future<void>` だが、画面設計表の
  /// 「restore結果」分岐を実装するため戻り値付きに拡張する)。
  /// 失敗時(`state.hasError`)は `false` を返し、呼び出し側は
  /// `error_listener.dart` 経由のSnackBar表示に委ねる。
  Future<bool> restore() async {
    state = const AsyncLoading();
    var restored = false;
    state = await AsyncValue.guard(() async {
      restored = await ref.read(billingServiceProvider).restore();
      await ref.read(billingRepositoryProvider).refreshCustomer();
    });
    return state.hasError ? false : restored;
  }
}
