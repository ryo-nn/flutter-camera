import 'package:flutter/material.dart';
import 'package:flutter_camera/src/common_widgets/app_error_view.dart';
import 'package:flutter_camera/src/core/error/error_listener.dart';
import 'package:flutter_camera/src/core/models/plan.dart';
import 'package:flutter_camera/src/features/billing/data/billing_config_repository.dart';
import 'package:flutter_camera/src/features/billing/data/firestore_billing_repository.dart';
import 'package:flutter_camera/src/features/billing/data/revenuecat_billing_service.dart';
import 'package:flutter_camera/src/features/billing/domain/billing_package_ids.dart';
import 'package:flutter_camera/src/features/billing/domain/billing_state.dart';
import 'package:flutter_camera/src/features/billing/presentation/purchase_controller.dart';
import 'package:flutter_camera/src/features/billing/presentation/widgets/credit_pack_tile.dart';
import 'package:flutter_camera/src/features/billing/presentation/widgets/legal_links.dart';
import 'package:flutter_camera/src/features/billing/presentation/widgets/plan_card.dart';
// `patternByIdProvider` は data 層(patterns/data/firestore_pattern_repository.dart)に
// 定義されている(design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計
// 「patternByIdProvider」。camera/presentation/widgets/pattern_carousel.dart が
// 同様にdata層から直接importする既存パターンに倣う)。
import 'package:flutter_camera/src/features/patterns/data/firestore_pattern_repository.dart'
    show patternByIdProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart' show Offering, Package;

/// 画面10 ペイウォール/プラン管理画面(design.md 課金(IAP)・ペイウォール設計章
/// 「S-10 ペイウォール/プラン管理画面」節 準拠)。
///
/// 常に `root push(fullscreenDialog: true)` で表示される(`routing/app_router.dart`
/// の `AppRoute.plan` ルート定義準拠。既存実装で確認済み)。
///
/// [patternId] は第9章 追補「プレミアムパターンのロックタイルタップ(S-04/S-06)」
/// 節準拠で `state.extra` として渡される(`routing/app_router.dart` の
/// `AppRoute.plan` ルート定義参照)。ロックタイルタップ以外の遷移元(S-07上限到達等)
/// では `null` のままとなり、その場合は訴求行を表示しない(既存表示のまま)。
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key, this.patternId});

  final String? patternId;

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  /// 購入中(反映待ちを含む)のPackage識別子。対象ボタンのみスピナー表示し、
  /// 完了までは全操作を無効化する
  /// (design.md「画面設計」節「purchasing: 対象ボタン内スピナー+全操作無効化」/
  /// 「反映中: 『購入を反映しています…』」準拠)。
  String? _pendingPackageIdentifier;

  bool get _isBusy => _pendingPackageIdentifier != null;

  @override
  Widget build(BuildContext context) {
    ref.listenAppError(purchaseControllerProvider, context);

    final offeringsAsync = ref.watch(offeringsProvider);
    final billingStateAsync = ref.watch(billingStateProvider);
    final trialEligibleAsync = ref.watch(proTrialEligibilityProvider);
    final limitsAsync = ref.watch(planMonthlyPostLimitsProvider);
    final legalLinksAsync = ref.watch(billingLegalLinksProvider);

    // 第9章 追補「プレミアムパターンのロックタイルタップ(S-04/S-06)」節準拠:
    // `patternId` が解決できた場合のみ訴求行を表示する。未指定・解決失敗・
    // 読み込み中はいずれも従来表示のまま(訴求行を出さない)。
    final patternId = widget.patternId;
    final lockedPatternName = patternId == null
        ? null
        : ref
              .watch(patternByIdProvider(patternId))
              .maybeWhen(data: (pattern) => pattern.name, orElse: () => null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('プランとお支払い'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      body: offeringsAsync.when(
        data: (offerings) => _buildBody(
          context: context,
          currentOffering: offerings.current,
          // `AsyncValue.valueOrNull` は本プロジェクトのriverpodバージョンに存在しないため
          // `.value`(nullable getter)を使う(editor/presentation/edit_preview_screen.dart
          // で確認済み)。
          billingState: billingStateAsync.value ?? BillingState.initial(),
          isTrialEligible: trialEligibleAsync.value ?? false,
          monthlyLimits: limitsAsync.value ?? const {},
          legalLinks: legalLinksAsync.value ?? const BillingLegalLinks(),
          lockedPatternName: lockedPatternName,
        ),
        loading: () => const _PaywallSkeleton(),
        error: (error, stackTrace) => AppErrorView(
          message: '価格情報を取得できませんでした。',
          onRetry: () => ref.invalidate(offeringsProvider),
        ),
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required Offering? currentOffering,
    required BillingState billingState,
    required bool isTrialEligible,
    required Map<Plan, int> monthlyLimits,
    required BillingLegalLinks legalLinks,
    String? lockedPatternName,
  }) {
    final proPackage = currentOffering?.getPackage(BillingPackageIds.proMonthly);
    final lightPackage = currentOffering?.getPackage(BillingPackageIds.lightMonthly);
    final creditsPackage = currentOffering?.getPackage(BillingPackageIds.credits10Pack);
    final resolvedPlan = billingState.resolvedPlan();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (lockedPatternName != null) ...[
          Card(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '『$lockedPatternName』はProプラン限定パターンです',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        _CurrentStatusCard(billingState: billingState, resolvedPlan: resolvedPlan),
        const SizedBox(height: 24),
        if (proPackage != null)
          PlanCard(
            planName: 'Pro',
            priceString: proPackage.storeProduct.priceString,
            benefitDescription:
                'X投稿 月${monthlyLimits[Plan.pro] ?? 0}回 + プレミアムパターン',
            isRecommended: true,
            isCurrentPlan: resolvedPlan == Plan.pro,
            trialPriceString: isTrialEligible ? proPackage.storeProduct.priceString : null,
            isLoading: _pendingPackageIdentifier == proPackage.identifier,
            onPressed: _isBusy ? null : () => _handlePurchase(proPackage),
          ),
        const SizedBox(height: 12),
        if (lightPackage != null)
          PlanCard(
            planName: 'Light',
            priceString: lightPackage.storeProduct.priceString,
            benefitDescription: 'X投稿 月${monthlyLimits[Plan.light] ?? 0}回',
            isCurrentPlan: resolvedPlan == Plan.light,
            isLoading: _pendingPackageIdentifier == lightPackage.identifier,
            onPressed: _isBusy ? null : () => _handlePurchase(lightPackage),
          ),
        const SizedBox(height: 24),
        if (creditsPackage != null)
          CreditPackTile(
            priceString: creditsPackage.storeProduct.priceString,
            isLoading: _pendingPackageIdentifier == creditsPackage.identifier,
            onPressed: _isBusy ? null : () => _handlePurchase(creditsPackage),
          ),
        const SizedBox(height: 16),
        if (_isBusy)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(child: Text('購入を反映しています…')),
          ),
        Center(
          child: TextButton(
            onPressed: _isBusy ? null : _handleRestore,
            child: _pendingPackageIdentifier == _restoreBusyMarker
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('購入を復元する'),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'プランは自動更新のサブスクリプションです。購読期間終了時に表示された価格で自動的に更新されます。'
          '解約はOSのサブスクリプション設定から行えます。',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        LegalLinks(links: legalLinks),
      ],
    );
  }

  Future<void> _handlePurchase(Package package) async {
    setState(() => _pendingPackageIdentifier = package.identifier);
    await ref.read(purchaseControllerProvider.notifier).purchase(package);
    if (mounted) setState(() => _pendingPackageIdentifier = null);
  }

  Future<void> _handleRestore() async {
    setState(() => _pendingPackageIdentifier = _restoreBusyMarker);
    final restored = await ref.read(purchaseControllerProvider.notifier).restore();
    if (!mounted) return;
    setState(() => _pendingPackageIdentifier = null);
    final state = ref.read(purchaseControllerProvider);
    if (state.hasError) return; // エラーはerror_listenerがSnackBarで表示済み
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(restored ? '購入を復元しました' : '復元できる購入がありませんでした'),
      ),
    );
  }
}

/// リストア中であることを示す内部マーカー(Packageの識別子と衝突しない値)。
const _restoreBusyMarker = '__restore__';

class _CurrentStatusCard extends StatelessWidget {
  const _CurrentStatusCard({required this.billingState, required this.resolvedPlan});

  final BillingState billingState;
  final Plan resolvedPlan;

  @override
  Widget build(BuildContext context) {
    final expiresAt = billingState.planExpiresAt;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(label: Text(_planLabel(resolvedPlan))),
                if (billingState.isTrial && expiresAt != null) ...[
                  const SizedBox(width: 8),
                  Text('無料トライアル中(${expiresAt.month}月${expiresAt.day}日まで)'),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text('購入分あと${billingState.postCredits}回'),
          ],
        ),
      ),
    );
  }

  String _planLabel(Plan plan) => switch (plan) {
    Plan.free => 'Free',
    Plan.light => 'Light',
    Plan.pro => 'Pro',
  };
}

class _PaywallSkeleton extends StatelessWidget {
  const _PaywallSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(
        4,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: index == 0 ? 72 : 140,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
