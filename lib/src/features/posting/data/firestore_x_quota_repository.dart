import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_camera/src/core/firebase/firebase_providers.dart';
import 'package:flutter_camera/src/core/models/plan.dart';
// auth featureは未実装だが、design.mdの命名規約(authStateChangesProviderは
// auth/data/firebase_auth_repository.dartに定義)に従って参照する。実際に
// routing/app_router.dartが同一パスをimportしており、この配置は既存実装で
// 確認済み(notes参照)。
import 'package:flutter_camera/src/features/auth/data/firebase_auth_repository.dart';
import 'package:flutter_camera/src/features/posting/domain/x_quota.dart';
import 'package:flutter_camera/src/features/posting/domain/x_quota_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firestore_x_quota_repository.g.dart';

const _jstOffset = Duration(hours: 9);

/// `postUsage/{uid}_x_{periodKey}` の日次periodKey(JST基準。`d{YYYYMMDD}`)。
/// `functions/src/lib/period.ts` の `dailyPeriodKey` と同一仕様。
String _dailyPeriodKey(DateTime now) {
  final jst = now.toUtc().add(_jstOffset);
  return 'd${jst.year.toString().padLeft(4, '0')}'
      '${jst.month.toString().padLeft(2, '0')}'
      '${jst.day.toString().padLeft(2, '0')}';
}

/// 月次periodKey(JST基準。`m{YYYYMM}`)。`monthlyPeriodKey` と同一仕様。
String _monthlyPeriodKey(DateTime now) {
  final jst = now.toUtc().add(_jstOffset);
  return 'm${jst.year.toString().padLeft(4, '0')}${jst.month.toString().padLeft(2, '0')}';
}

/// [XQuotaRepository] のFirestore実装(quota章「X残回数表示」節:
/// `appConfig/limits` / `users/{uid}/billing/state` /
/// `postUsage/{uid}_x_{daily,monthly}` の4ソースをリアルタイム合成する)。
///
/// design.mdはプラン・クレジット購読をbilling担当の `billingStateProvider` に
/// 一本化し二重購読を避けることを求めているが、billing featureの実際の
/// provider配置(並列実装中のため未確定)への依存を避けるため、本実装は
/// `users/{uid}/billing/state` を自前で購読する(同一ドキュメントを読むだけで
/// 追加のFunctions呼び出し等のコストは発生しないため実質的な二重購読の弊害はない)。
/// 統合フェーズで `billingStateProvider` に一本化できるか確認すること
/// (coreChangeRequests/notes参照)。
class FirestoreXQuotaRepository implements XQuotaRepository {
  FirestoreXQuotaRepository(this._firestore, this._uid);

  final FirebaseFirestore _firestore;
  final String _uid;

  @override
  Stream<XQuota> watchXQuota() {
    // periodKeyは購読開始時にJSTで算出する(quota章「X残回数表示」節:
    // 「月跨ぎ・日跨ぎのセッション中の厳密追従は要求しない」との記載に対応)。
    final now = DateTime.now();
    final dailyKey = _dailyPeriodKey(now);
    final monthlyKey = _monthlyPeriodKey(now);

    final limitsRef = _firestore.doc('appConfig/limits');
    final billingRef = _firestore.doc('users/$_uid/billing/state');
    final dailyRef = _firestore.doc('postUsage/${_uid}_x_$dailyKey');
    final monthlyRef = _firestore.doc('postUsage/${_uid}_x_$monthlyKey');

    return _combineLatest4(
      limitsRef.snapshots(),
      billingRef.snapshots(),
      dailyRef.snapshots(),
      monthlyRef.snapshots(),
      _combine,
    );
  }

  XQuota _combine(
    DocumentSnapshot<Map<String, dynamic>> limitsSnap,
    DocumentSnapshot<Map<String, dynamic>> billingSnap,
    DocumentSnapshot<Map<String, dynamic>> dailySnap,
    DocumentSnapshot<Map<String, dynamic>> monthlySnap,
  ) {
    final billingData = billingSnap.data();
    final plan = _resolvePlan(
      planRaw: billingData?['plan'] as String?,
      planExpiresAt: (billingData?['planExpiresAt'] as Timestamp?)?.toDate(),
      now: DateTime.now(),
    );
    final planKey = switch (plan) {
      Plan.free => 'free',
      Plan.light => 'light',
      Plan.pro => 'pro',
    };
    final limitsData = limitsSnap.data();
    final monthlyLimit =
        (limitsData?['xMonthlyPostLimitByPlan'] as Map?)?[planKey] as int? ?? 0;
    final dailyLimit =
        (limitsData?['xDailyPostLimitByPlan'] as Map?)?[planKey] as int? ?? 0;
    final monthlyUsed = (monthlySnap.data()?['count'] as int?) ?? 0;
    final dailyUsed = (dailySnap.data()?['count'] as int?) ?? 0;
    final creditBalance = (billingData?['postCredits'] as int?) ?? 0;

    return XQuota(
      plan: plan,
      monthlyLimit: monthlyLimit,
      monthlyUsed: monthlyUsed,
      dailyLimit: dailyLimit,
      dailyUsed: dailyUsed,
      creditBalance: creditBalance,
    );
  }

  /// `functions/src/lib/plan.ts` の `resolvePlan` と同一の読み取り時失効ガード
  /// (quota/retention章「共通プラン有効判定」節準拠)。
  Plan _resolvePlan({
    required String? planRaw,
    required DateTime? planExpiresAt,
    required DateTime now,
  }) {
    if (planRaw == null || planRaw == 'free') return Plan.free;
    if (planExpiresAt != null && !planExpiresAt.isAfter(now)) return Plan.free;
    return switch (planRaw) {
      'light' => Plan.light,
      'pro' => Plan.pro,
      _ => Plan.free,
    };
  }
}

/// 4つのFirestoreドキュメントストリームを合成する(rxdart等の追加パッケージを
/// 導入せず、素のDartのみで実装するcombineLatest相当)。全ソースが最低1回ずつ
/// 値を発行した後、いずれかの更新のたびに再計算して発行する。
Stream<R> _combineLatest4<A, B, C, D, R>(
  Stream<A> streamA,
  Stream<B> streamB,
  Stream<C> streamC,
  Stream<D> streamD,
  R Function(A, B, C, D) combine,
) {
  late final StreamController<R> controller;
  A? a;
  B? b;
  C? c;
  D? d;
  var hasA = false, hasB = false, hasC = false, hasD = false;
  final subscriptions = <StreamSubscription<void>>[];

  void emit() {
    if (!(hasA && hasB && hasC && hasD)) return;
    controller.add(combine(a as A, b as B, c as C, d as D));
  }

  controller = StreamController<R>.broadcast(
    onListen: () {
      subscriptions.addAll([
        streamA.listen((v) {
          a = v;
          hasA = true;
          emit();
        }, onError: controller.addError),
        streamB.listen((v) {
          b = v;
          hasB = true;
          emit();
        }, onError: controller.addError),
        streamC.listen((v) {
          c = v;
          hasC = true;
          emit();
        }, onError: controller.addError),
        streamD.listen((v) {
          d = v;
          hasD = true;
          emit();
        }, onError: controller.addError),
      ]);
    },
    onCancel: () async {
      for (final s in subscriptions) {
        await s.cancel();
      }
      subscriptions.clear();
    },
  );
  return controller.stream;
}

@Riverpod(keepAlive: true)
XQuotaRepository xQuotaRepository(Ref ref) {
  final uid = ref.watch(authStateChangesProvider).value?.uid;
  if (uid == null) {
    throw StateError('xQuotaRepository はログイン済みユーザーでのみ利用できます');
  }
  return FirestoreXQuotaRepository(ref.watch(firestoreProvider), uid);
}

/// S-07/S-09/ペイウォールの残数表示の単一情報源(quota章「プロバイダー設計」節準拠)。
@riverpod
Stream<XQuota> xQuota(Ref ref) {
  return ref.watch(xQuotaRepositoryProvider).watchXQuota();
}
