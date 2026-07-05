/// RevenueCatのカスタムPackage識別子・ストアプロダクトID
/// (design.md 課金(IAP)・ペイウォール設計章「RevenueCat 構成」節準拠)。
///
/// 月額ティアが2つ並ぶため標準識別子(`$rc_monthly` 等)は使わず、
/// 全パッケージをカスタム識別子で統一する。値そのものはRevenueCatダッシュボード側の
/// カタログ設定(命名規約)であり、価格・枠数のような「サーバー側設定値」ではないため
/// クライアント定数として保持してよい(design.md 同章「命名規約」準拠)。
abstract final class BillingPackageIds {
  /// Offering内のPackage識別子(`Offering.getPackage` に渡す値)。
  static const String lightMonthly = 'light_monthly';
  static const String proMonthly = 'pro_monthly';
  static const String credits10Pack = 'credits_10pack';

  /// ストア側プロダクトID(App Store / Play 共通表記)。
  static const String lightMonthlyProductId = 'fcam_light_1m';
  static const String proMonthlyProductId = 'fcam_pro_1m';
  static const String credits10PackProductId = 'fcam_credits_x10';
}
