import 'package:flutter_camera/src/core/models/plan.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'x_quota.freezed.dart';

/// X投稿の残枠を表す導出モデル(Firestoreに永続化しない。design.md
/// 「X投稿枠・クレジット制御設計」章「Freezedモデル追加」節のコード例に準拠)。
@freezed
sealed class XQuota with _$XQuota {
  const XQuota._();

  const factory XQuota({
    required Plan plan,
    required int monthlyLimit,
    required int monthlyUsed,
    required int dailyLimit,
    required int dailyUsed,
    required int creditBalance, // users/{uid}/billing/state.postCredits 由来
  }) = _XQuota;

  int get monthlyRemaining =>
      (monthlyLimit - monthlyUsed).clamp(0, monthlyLimit);
  int get dailyRemaining => (dailyLimit - dailyUsed).clamp(0, dailyLimit);

  /// 「今月あと◯回」= 月次残 + クレジット残(表示上は内訳を分けて出す)。
  int get totalRemaining => monthlyRemaining + creditBalance;

  bool get isExhausted => totalRemaining == 0 || dailyRemaining == 0;

  /// 日次ガード残数が月次残数より小さい場合、または日次到達時にのみ
  /// 「本日あと◯回」を補足表示する(quota章「表示ルールと上限到達時のペイウォール導線」節準拠)。
  bool get shouldShowDailyHint =>
      dailyRemaining == 0 || dailyRemaining < monthlyRemaining;
}
