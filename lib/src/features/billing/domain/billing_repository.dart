import 'package:flutter_camera/src/core/models/plan.dart';
import 'package:flutter_camera/src/features/billing/domain/billing_state.dart';

/// `users/{uid}/billing/state` の購読と `rcRefreshCustomer` 呼び出しを担う
/// リポジトリの抽象インターフェース(design.md アプリアーキテクチャ設計
/// 「レイヤー責務と依存方向」準拠。presentationはこの型のみに依存し、
/// data層の実装クラスを直接importしない)。
abstract interface class BillingRepository {
  /// `users/{uid}/billing/state` の購読(design.md 課金章「プラン状態の同期設計」
  /// 準拠)。ドキュメント不存在時は [BillingState.initial] を発行する。
  Stream<BillingState> watchBillingState();

  /// `rcRefreshCustomer` onCall の呼び出し(design.md 課金章「即時同期
  /// (rcRefreshCustomer onCall)」節準拠)。購入・リストア成功直後にwebhook到達を
  /// 待たず呼ぶことで、`billing/state` への反映ラグを縮める。
  Future<BillingRefreshResult> refreshCustomer();
}

/// `rcRefreshCustomer` の onCall レスポンス要約
/// (design.md 課金章 `{ plan, isTrial, postCredits }` 準拠)。
class BillingRefreshResult {
  const BillingRefreshResult({
    required this.plan,
    required this.isTrial,
    required this.postCredits,
  });

  final Plan plan;
  final bool isTrial;
  final int postCredits;
}
