// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'first_completion_celebration_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(FirstCompletionCelebration)
final firstCompletionCelebrationProvider =
    FirstCompletionCelebrationProvider._();

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
final class FirstCompletionCelebrationProvider
    extends
        $NotifierProvider<
          FirstCompletionCelebration,
          FirstCompletionCelebrationStep?
        > {
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
  FirstCompletionCelebrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firstCompletionCelebrationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firstCompletionCelebrationHash();

  @$internal
  @override
  FirstCompletionCelebration create() => FirstCompletionCelebration();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirstCompletionCelebrationStep? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirstCompletionCelebrationStep?>(
        value,
      ),
    );
  }
}

String _$firstCompletionCelebrationHash() =>
    r'15b8abbf60ecd10d8612ba39ef0bbd185930d670';

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

abstract class _$FirstCompletionCelebration
    extends $Notifier<FirstCompletionCelebrationStep?> {
  FirstCompletionCelebrationStep? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              FirstCompletionCelebrationStep?,
              FirstCompletionCelebrationStep?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                FirstCompletionCelebrationStep?,
                FirstCompletionCelebrationStep?
              >,
              FirstCompletionCelebrationStep?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
