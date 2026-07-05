import 'package:flutter/material.dart';
import 'package:flutter_camera/src/common_widgets/primary_button.dart';

/// S-10 プランカード(design.md 画面設計・UIフロー章「S-10 ペイウォール/プラン管理画面」
/// 「画面設計」節「②プランカード×2」準拠)。
///
/// 価格は必ず `StoreProduct.priceString`(呼び出し側で解決済み)を渡すこと。
/// 「¥480」等の価格文字列を本ウィジェット内でハードコードしない。
class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.planName,
    required this.priceString,
    required this.benefitDescription,
    required this.isLoading,
    required this.onPressed,
    this.isRecommended = false,
    this.isCurrentPlan = false,
    this.trialPriceString,
  });

  /// プラン表示名(「Pro」「Light」)。
  final String planName;

  /// 月額価格(`StoreProduct.priceString`)。
  final String priceString;

  /// 特典説明(例: 「X投稿 月150回 + プレミアムパターン」)。
  final String benefitDescription;

  final bool isLoading;

  /// 購入実行コールバック。`isCurrentPlan` の場合は null を渡し無効化する。
  final VoidCallback? onPressed;

  final bool isRecommended;
  final bool isCurrentPlan;

  /// トライアル適格時のみ非null(design.md: 「トライアル適格時のみProのボタン文言を
  /// 『3日間無料で試す』+『以降 ◯円/月』に切替、非適格時は『Proにアップグレード』」)。
  final String? trialPriceString;

  @override
  Widget build(BuildContext context) {
    final isTrialOffer = trialPriceString != null;
    final ctaLabel = isCurrentPlan
        ? '利用中のプラン'
        : isTrialOffer
        ? '3日間無料で試す'
        : '$planNameにアップグレード';
    final semanticsLabel = isTrialOffer
        ? '$planName、月額$priceString、3日間無料で試す'
        : '$planName、月額$priceString';

    return Card(
      shape: isRecommended
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(planName, style: Theme.of(context).textTheme.titleLarge),
                if (isRecommended) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: const Text('おすすめ'),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$priceString / 月',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(benefitDescription),
            const SizedBox(height: 16),
            Semantics(
              label: semanticsLabel,
              button: true,
              child: ExcludeSemantics(
                child: PrimaryButton(
                  label: ctaLabel,
                  isLoading: isLoading,
                  onPressed: isCurrentPlan ? null : onPressed,
                ),
              ),
            ),
            if (isTrialOffer && !isCurrentPlan) ...[
              const SizedBox(height: 4),
              Text(
                '以降 $trialPriceString/月',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
