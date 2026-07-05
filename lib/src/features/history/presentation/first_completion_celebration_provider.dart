import 'package:flutter_camera/src/core/firebase/firebase_providers.dart';
import 'package:flutter_camera/src/features/history/data/firestore_post_history_repository.dart';
import 'package:flutter_camera/src/features/history/domain/first_successful_post.dart';
import 'package:flutter_camera/src/features/onboarding/data/onboarding_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'first_completion_celebration_provider.g.dart';

/// S-08 初回投稿完了直後の演出フロー(design.md 第9章「3日トライアル導線の接続」節:
/// 「はじめての投稿が完了しました」完了カード → 通知プレ許可ダイアログ →
/// 「Proを3日間無料で試す」バナー。初回のみ表示)のステップ。
enum FirstCompletionCelebrationStep {
  /// 「はじめての投稿が完了しました」完了カード。
  completionCard,

  /// 通知プレ許可ダイアログ。
  notificationPermission,

  /// 「Proを3日間無料で試す」トライアルバナー。
  trialBanner,
}

/// 初回投稿完了演出の表示制御(`onboarding/presentation/first_post_guide_provider.dart`
/// の `FirstPostGuide` と同型のパターン: `build()` は復元前の安全な既定値 `null`
/// (非表示)を返しつつ、非同期で表示要否を判定する)。
///
/// 表示条件: 表示済みフラグ(`onboardingRepository.isFirstCompletionCelebrationShown`)が
/// 立っておらず、かつ `posts`(全期間)で成功と判定できる投稿がちょうど1件
/// (=初回投稿が今回成功した。判定ロジックは `isFirstSuccessfulPost` に委譲)。
///
/// `history/presentation/post_history_screen.dart`(S-08)が本プロバイダーをwatchし、
/// ステップに応じて完了カード・通知プレ許可ダイアログ・トライアルバナーを出し分ける。
@riverpod
class FirstCompletionCelebration extends _$FirstCompletionCelebration {
  @override
  FirstCompletionCelebrationStep? build() {
    _evaluate();
    return null;
  }

  Future<void> _evaluate() async {
    final onboardingRepository = ref.read(onboardingRepositoryProvider);
    if (await onboardingRepository.isFirstCompletionCelebrationShown()) {
      return;
    }

    // `postHistoryProvider`(autoDispose)を経由せず、
    // `onboarding/presentation/first_post_guide_provider.dart` の
    // `FirstPostGuide._evaluate()` と同様にリポジトリを直接読む(本provider自身も
    // autoDisposeのため、他providerの `.future` を `ref.read` するとキャッシュされずに
    // 破棄される可能性がある。購読は初回の1件取得後に自動的に閉じる)。
    final posts = await ref
        .read(postHistoryRepositoryProvider)
        .watchPostHistory()
        .first;
    if (!isFirstSuccessfulPost(posts)) return;

    state = FirstCompletionCelebrationStep.completionCard;
  }

  /// 完了カードの「つぎへ」操作。通知プレ許可ダイアログへ進む。
  void advanceToNotificationPermission() {
    if (state == FirstCompletionCelebrationStep.completionCard) {
      state = FirstCompletionCelebrationStep.notificationPermission;
    }
  }

  /// 通知プレ許可ダイアログの「許可する」操作。OSの通知許可を要求してから
  /// トライアルバナーへ進む。
  Future<void> requestNotificationPermission() async {
    if (state != FirstCompletionCelebrationStep.notificationPermission) return;
    await ref.read(firebaseMessagingProvider).requestPermission();
    await _advanceToTrialBanner();
  }

  /// 通知プレ許可ダイアログの「あとで」操作(OSの許可要求は行わない)。
  Future<void> skipNotificationPermission() async {
    if (state != FirstCompletionCelebrationStep.notificationPermission) return;
    await _advanceToTrialBanner();
  }

  /// トライアルバナー表示時点で表示済みフラグを記録する(design.md 第9章
  /// 「billing節との初回表示タイミングの整合」: 「`paywallShownV1` 相当の
  /// 表示済みフラグの記録タイミングを『S-08初回完了カード後のバナー表示時』に
  /// 移す」準拠。バナーのタップ・破棄操作を待たずにここで確定させる)。
  Future<void> _advanceToTrialBanner() async {
    state = FirstCompletionCelebrationStep.trialBanner;
    await ref
        .read(onboardingRepositoryProvider)
        .markFirstCompletionCelebrationShown();
  }

  /// トライアルバナーの「閉じる」操作。表示済みフラグは既に記録済みのため、
  /// 本provider再構築後も再表示されない。
  void dismissTrialBanner() {
    state = null;
  }
}
