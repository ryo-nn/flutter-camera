import 'package:flutter_camera/src/core/firebase/firebase_providers.dart';
import 'package:flutter_camera/src/core/models/plan.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'billing_config_repository.g.dart';

/// S-10 法定表記リンク(利用規約・プライバシーポリシー・特定商取引法に基づく表記)の
/// リンク先URL。design.mdにURL自体の記載は無く、価格・枠数と同様
/// 「クライアントにハードコードしない」方針(design.md 課金章 S-10節)に倣い、
/// `appConfig/billing` ドキュメント(既存 `creditProducts` と同居)にオペレーション設定
/// として持たせる。`appConfig/{docId}` は既存Security Rulesで認証済み全員が読み取り可能
/// (ルール変更不要)。
///
/// NOTE(coreChangeRequests参照): `termsUrl` / `privacyUrl` / `tokushoUrl`
/// フィールドは design.md の `appConfig/billing` スキーマ表に明記が無いため、
/// data担当への追加依頼(フィールド追加+運用値の投入)が必要。
class BillingLegalLinks {
  const BillingLegalLinks({this.termsUrl, this.privacyUrl, this.tokushoUrl});

  final String? termsUrl;
  final String? privacyUrl;
  final String? tokushoUrl;
}

/// S-10法定表記リンクの取得(design.md UIフロー章「日本語UI文言の方針」
/// 「法定表記リンク行」準拠)。未設定時は当該リンクを非表示にする(呼び出し側判断)。
@riverpod
Future<BillingLegalLinks> billingLegalLinks(Ref ref) async {
  final snap = await ref.watch(firestoreProvider).doc('appConfig/billing').get();
  final data = snap.data();
  return BillingLegalLinks(
    termsUrl: data?['termsUrl'] as String?,
    privacyUrl: data?['privacyUrl'] as String?,
    tokushoUrl: data?['tokushoUrl'] as String?,
  );
}

/// S-10プランカードの特典説明(「X投稿 月◯回」)用。`appConfig/limits` の
/// プラン別設定値を読む(design.md 課金章 S-10節:
/// 「プラン特典のX枠回数(30/150回)の表示値は appConfig/limits のプラン別設定値
/// (quota担当が拡張)から取得し、クライアントにハードコードしない」準拠)。
@riverpod
Future<Map<Plan, int>> planMonthlyPostLimits(Ref ref) async {
  final snap = await ref.watch(firestoreProvider).doc('appConfig/limits').get();
  final byPlan = snap.data()?['xMonthlyPostLimitByPlan'] as Map<String, dynamic>? ?? const {};
  return {
    for (final plan in Plan.values) plan: (byPlan[_planKey(plan)] as num?)?.toInt() ?? 0,
  };
}

String _planKey(Plan plan) => switch (plan) {
  Plan.free => 'free',
  Plan.light => 'light',
  Plan.pro => 'pro',
};
