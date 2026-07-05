import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_camera/src/core/models/converters.dart';
import 'package:flutter_camera/src/core/models/plan.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'billing_state.freezed.dart';
part 'billing_state.g.dart';

/// `users/{uid}/billing/state`(単一ドキュメント)の読み取り専用ドメインモデル
/// (design.md 課金(IAP)・ペイウォール設計章「Firestoreスキーマ追加」節
/// 「スキーマ一本化」準拠。プラン状態・購入クレジット残高の唯一の正)。
///
/// 書き込みは `rcWebhook` / snsPublishPost(クレジット消費・返還)等の
/// Cloud Functionsのみが行う。クライアント(本モデル)は読み取り専用のミラー
/// (design.md 「Firestore Security Rules差分」: `allow write: if false`)。
///
/// `@NullableTimestampConverter()` は `auth/domain/app_user.dart` 等と同じ
/// `core/models/converters.dart` を参照する(coreChangeRequests参照)。
@freezed
sealed class BillingState with _$BillingState {
  const BillingState._();

  const factory BillingState({
    @Default(Plan.free) Plan plan,
    @Default(false) bool isTrial,
    String? planProductId,

    /// 現エンタイトルメントの失効日時(RC `expires_date`。グレースピリオド中は
    /// `grace_period_expires_date`)。プラン解決規則2(読み取り時失効ガード)の
    /// 判定に使用する([resolvedPlan] 参照)。
    @NullableTimestampConverter() DateTime? planExpiresAt,

    /// 購入クレジット残高(無期限。加算=rcWebhook、減算=quota消費トランザクション
    /// と返金処理のみ)。
    @Default(0) int postCredits,
    @NullableTimestampConverter() DateTime? updatedAt,
  }) = _BillingState;

  /// ドキュメント不存在時の既定値
  /// (design.md 課金章「Firestoreスキーマ追加」節: 「ドキュメント不存在=plan: 'free'・
  /// postCredits: 0」として扱う準拠)。
  factory BillingState.initial() => const BillingState();

  factory BillingState.fromJson(Map<String, Object?> json) =>
      _$BillingStateFromJson(json);

  /// 共通プラン解決規則2(読み取り時失効ガード。design.md 課金章
  /// 「プラン解決規則」節準拠。quota担当のenforcementトランザクションと
  /// クライアント表示([currentPlanProvider])が共有する規則)。
  ///
  /// `plan == free` は常に free。それ以外は `planExpiresAt` が設定されており
  /// 既に現在時刻を過ぎている場合のみ安全側で free として扱う
  /// (webhookの取りこぼし・遅延時にも失効後のプラン枠利用を防ぐ)。
  Plan resolvedPlan([DateTime? now]) {
    if (plan == Plan.free) return Plan.free;
    final expiresAt = planExpiresAt;
    if (expiresAt != null && !expiresAt.isAfter(now ?? DateTime.now())) {
      return Plan.free;
    }
    return plan;
  }
}
