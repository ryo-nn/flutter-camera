import 'package:purchases_flutter/purchases_flutter.dart'
    show CustomerInfo, Offerings, Package;

/// purchases_flutter(RevenueCat)ラッパの抽象インターフェース
/// (design.md 課金(IAP)・ペイウォール設計章「feature追加」節: `domain/billing_service.dart`
/// = abstract(ensureSession/purchase/restore/getOfferings/eligibility) 準拠)。
///
/// domain 層は本来 Flutter/Firebase SDK に依存しない純Dartとする方針
/// (design.md アプリアーキテクチャ設計「レイヤー責務と依存方向」)だが、
/// `editor/domain/pattern_apply_service.dart` と同様の理由により、本ファイルのみ
/// purchases_flutter の公開型(`Package` / `Offerings` / `CustomerInfo`)を例外的に
/// 露出する。禁止対象の「SDK型の露出」はFirestore `DocumentSnapshot` 等のI/O由来型を
/// 主眼とした規約と解釈し、RevenueCat SDK自体が課金ドメインの語彙(オファリング・
/// パッケージ・価格表示)を提供する本featureに限り許容する(統合フェーズの申し送り事項)。
abstract interface class BillingService {
  /// サインイン完了後にのみ呼ぶ(design.md「クライアント統合」節: App User ID =
  /// Firebase Auth UID に固定)。未configure時は `Purchases.configure`、
  /// 設定済みでUIDが異なる場合は `Purchases.logIn` を行う。
  Future<void> ensureSession(String uid);

  /// サインアウト時に呼ぶ。以後の購入イベントを直前のUIDに誤紐付けしない。
  Future<void> clearSession();

  /// パッケージの購入を実行する。キャンセル時は
  /// `BillingException(cancelled: true)` を throw する
  /// (design.md「購入・リストアの実行」節準拠)。
  Future<void> purchase(Package package);

  /// 購入の復元(Apple審査必須のリストアボタン)。
  ///
  /// 戻り値は「復元できる購入が実際にあったか」(design.md「画面設計」節
  /// 「restore結果: SnackBar『購入を復元しました』または
  /// 『復元できる購入がありませんでした』」の分岐に使用)。
  /// `Purchases.restorePurchases()` 自体は購入の有無に関わらず正常応答するため、
  /// 復元後の `CustomerInfo`(有効なサブスク・非サブスク購入履歴)の有無で判定する。
  Future<bool> restore();

  /// current offering の取得(S-10表示用)。
  Future<Offerings> getOfferings();

  /// Proトライアルの適格判定(design.md「3日間無料トライアル」節準拠)。
  /// iOS: `checkTrialOrIntroductoryPriceEligibility`(iOS専用API)。
  /// Android: `proPackage.storeProduct.subscriptionOptions` に無料フェーズ付き
  /// オファーが含まれるかで判定する。
  Future<bool> checkProTrialEligibility(Package proPackage);

  /// `CustomerInfo` 更新のStream化(楽観的UI反映専用。枠判定には使わない)。
  Stream<CustomerInfo> watchCustomerInfo();
}
