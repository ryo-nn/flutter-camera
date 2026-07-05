import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/core/firebase/firebase_providers.dart';
import 'package:flutter_camera/src/core/models/plan.dart';
// auth featureは並列実装中のため、design.mdの命名規約(authStateChangesProviderは
// auth/data/firebase_auth_repository.dartに定義)に従って参照する。
// posting/data/firestore_x_quota_repository.dart が同一パスをimportしており、
// この配置は既存実装で確認済み(notes参照)。
import 'package:flutter_camera/src/features/auth/data/firebase_auth_repository.dart';
import 'package:flutter_camera/src/features/billing/domain/billing_repository.dart';
import 'package:flutter_camera/src/features/billing/domain/billing_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firestore_billing_repository.g.dart';

/// [BillingRepository] のFirestore/Cloud Functions実装
/// (design.md 課金章「プラン状態の同期設計」「即時同期(rcRefreshCustomer onCall)」
/// 節準拠)。
class FirestoreBillingRepository implements BillingRepository {
  FirestoreBillingRepository(this._firestore, this._functions, this._uid);

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final String _uid;

  @override
  Stream<BillingState> watchBillingState() {
    return _firestore.doc('users/$_uid/billing/state').snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return BillingState.initial();
      return BillingState.fromJson(data);
    });
  }

  @override
  Future<BillingRefreshResult> refreshCustomer() async {
    final callable = _functions.httpsCallable('rcRefreshCustomer');
    try {
      final response = await callable.call<Map<String, dynamic>>();
      final data = response.data;
      return BillingRefreshResult(
        plan: _planFromWire(data['plan'] as String?),
        isTrial: data['isTrial'] as bool? ?? false,
        postCredits: (data['postCredits'] as num?)?.toInt() ?? 0,
      );
    } on FirebaseFunctionsException catch (e) {
      throw BillingException(e.message ?? '購入情報の同期に失敗しました');
    }
  }
}

Plan _planFromWire(String? value) => switch (value) {
  'light' => Plan.light,
  'pro' => Plan.pro,
  _ => Plan.free,
};

/// `billing/state` 購読と `rcRefreshCustomer` 呼び出しのDI
/// (design.md「billingRepositoryProvider」準拠)。
@Riverpod(keepAlive: true)
BillingRepository billingRepository(Ref ref) {
  final uid = ref.watch(authStateChangesProvider).value?.uid;
  if (uid == null) {
    throw StateError('billingRepository はログイン済みユーザーでのみ利用できます');
  }
  return FirestoreBillingRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseFunctionsProvider),
    uid,
  );
}

/// `users/{uid}/billing/state` の購読(サーバー正。design.md「billingStateProvider」
/// 準拠。不存在時は [BillingState.initial] を返す)。
@riverpod
Stream<BillingState> billingState(Ref ref) {
  return ref.watch(billingRepositoryProvider).watchBillingState();
}

/// S-07残枠表示・パターンgating等の参照点(design.md「currentPlanProvider」準拠。
/// プラン解決規則2(読み取り時失効ガード込み)で `Plan` を導出する)。
///
/// NOTE(coreChangeRequests参照): `patterns/presentation/pattern_list_screen.dart`
/// は本プロバイダーを `billing/domain/billing_state.dart` から import する想定で
/// 実装されている(想定パスとして自己申告済み)が、domain層はdata層に依存できない
/// 規約(design.md「レイヤー責務と依存方向」)のため、本プロバイダーの実体は
/// data層(本ファイル)に置く。統合フェーズでimport元の修正が必要。
@riverpod
Plan currentPlan(Ref ref) {
  // NOTE: このriverpodバージョン(pubspec.yamlの調整コメント参照)には
  // `AsyncValue.valueOrNull` が存在しないため、nullable getterの `.value` を使う
  // (editor/presentation/edit_preview_screen.dart で確認済み)。
  final state = ref.watch(billingStateProvider).value ?? BillingState.initial();
  return state.resolvedPlan();
}
