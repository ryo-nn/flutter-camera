import 'dart:async';

import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/features/billing/domain/billing_package_ids.dart';
import 'package:flutter_camera/src/features/billing/domain/billing_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'revenuecat_billing_service.g.dart';

/// RevenueCatの公開SDKキー(`appl_…` / `goog_…`)。シークレットではなく
/// クライアント埋め込み前提の公開値のため `--dart-define` で注入する
/// (design.md 課金章「Cloud Functions追加」節準拠。Secret Managerには入れない)。
abstract final class _RcPublicApiKeys {
  static const apple = String.fromEnvironment('RC_APPLE_API_KEY');
  static const google = String.fromEnvironment('RC_GOOGLE_API_KEY');
}

/// [BillingService] の purchases_flutter 実装
/// (design.md 課金章「クライアント統合(purchases_flutter)」節準拠)。
class RevenueCatBillingService implements BillingService {
  const RevenueCatBillingService();

  @override
  Future<void> ensureSession(String uid) async {
    if (!await Purchases.isConfigured) {
      final apiKey = defaultTargetPlatform == TargetPlatform.iOS
          ? _RcPublicApiKeys.apple
          : _RcPublicApiKeys.google;
      await Purchases.configure(PurchasesConfiguration(apiKey)..appUserID = uid);
      return;
    }
    if (await Purchases.appUserID != uid) {
      await Purchases.logIn(uid); // アカウント切替
    }
  }

  @override
  Future<void> clearSession() async {
    if (await Purchases.isConfigured) {
      await Purchases.logOut();
    }
  }

  @override
  Future<void> purchase(Package package) async {
    try {
      await Purchases.purchase(PurchaseParams.package(package));
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        // UIはSnackBarを出さない(design.md「購入・リストアの実行」節準拠)。
        throw const BillingException('purchase cancelled', cancelled: true);
      }
      throw BillingException('purchase failed: ${code.name}');
    }
  }

  @override
  Future<bool> restore() async {
    try {
      final info = await Purchases.restorePurchases();
      return info.activeSubscriptions.isNotEmpty ||
          info.nonSubscriptionTransactions.isNotEmpty;
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      throw BillingException('restore failed: ${code.name}');
    }
  }

  @override
  Future<Offerings> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      throw BillingException('offerings fetch failed: ${code.name}');
    }
  }

  @override
  Future<bool> checkProTrialEligibility(Package proPackage) async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // iOS専用API(design.md「3日間無料トライアル」節: Androidで呼んでも
      // 有効な判定は返らないことを公式が明記)。
      final result = await Purchases.checkTrialOrIntroductoryPriceEligibility([
        proPackage.storeProduct.identifier,
      ]);
      final eligibility = result[proPackage.storeProduct.identifier];
      return eligibility?.status ==
          IntroEligibilityStatus.introEligibilityStatusEligible;
    }
    // Android: current offeringのpro_monthlyパッケージのStoreProduct.subscriptionOptions
    // に無料フェーズ付きオファーが含まれるかで判定する。
    final options = proPackage.storeProduct.subscriptionOptions;
    return options?.any((option) => option.freePhase != null) ?? false;
  }

  @override
  Stream<CustomerInfo> watchCustomerInfo() {
    late final StreamController<CustomerInfo> controller;
    void listener(CustomerInfo info) => controller.add(info);
    controller = StreamController<CustomerInfo>.broadcast(
      onListen: () => Purchases.addCustomerInfoUpdateListener(listener),
      onCancel: () => Purchases.removeCustomerInfoUpdateListener(listener),
    );
    return controller.stream;
  }
}

/// purchases_flutterラッパのDI
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計「billingServiceProvider」)。
@Riverpod(keepAlive: true)
BillingService billingService(Ref ref) => const RevenueCatBillingService();

/// `addCustomerInfoUpdateListener` のStream化(楽観的UI反映専用。
/// design.md 課金章「feature追加」節「customerInfoProvider」準拠。枠判定には使わない)。
@Riverpod(keepAlive: true)
Stream<CustomerInfo> customerInfo(Ref ref) {
  return ref.watch(billingServiceProvider).watchCustomerInfo();
}

/// current offering の取得(S-10表示用。design.md「offeringsProvider」準拠)。
@riverpod
Future<Offerings> offerings(Ref ref) {
  return ref.watch(billingServiceProvider).getOfferings();
}

/// Proトライアル適格判定(design.md「proTrialEligibilityProvider」準拠)。
/// current offeringに `pro_monthly` パッケージが無い場合は非適格扱いとする。
@riverpod
Future<bool> proTrialEligibility(Ref ref) async {
  final currentOffering = (await ref.watch(offeringsProvider.future)).current;
  final proPackage = currentOffering?.getPackage(BillingPackageIds.proMonthly);
  if (proPackage == null) return false;
  return ref.watch(billingServiceProvider).checkProTrialEligibility(proPackage);
}
