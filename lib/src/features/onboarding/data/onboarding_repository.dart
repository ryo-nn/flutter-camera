import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'onboarding_repository.g.dart';

/// オンボーディング完了フラグ・初回投稿ガイド(コーチマーク)のスキップフラグ・
/// 初回投稿完了演出(S-08)の表示済みフラグを shared_preferences で読み書きする
/// (design.md アプリアーキテクチャ設計 ディレクトリ構造
/// 「onboarding_repository.dart # shared_preferences で完了フラグ永続化」
/// + 第9章「S-04 初回投稿ガイド(コーチマーク)」: 「shared_preferencesに保存=既存
/// onboarding_repository.dart の管轄に追加」+ 第9章「3日トライアル導線の接続」節:
/// 「`paywallShownV1` 相当の表示済みフラグの記録タイミングを『S-08初回完了カード後の
/// バナー表示時』に一本化」準拠)。
///
/// 小規模のため domain 層のインターフェースは設けない(startup/onboardingの
/// 既存設計方針: 「小規模のため層省略」に準ずる)。
class OnboardingRepository {
  static const _completedKey = 'onboarding_completed';
  static const _firstPostGuideSkippedKey = 'first_post_guide_skipped';
  static const _firstCompletionCelebrationShownKey =
      'first_completion_celebration_shown';

  /// S-02「はじめる」「スキップ」で永続化されるオンボーディング完了フラグ。
  Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_completedKey) ?? false;
  }

  Future<void> setCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_completedKey, true);
  }

  /// S-04 初回投稿ガイド(コーチマーク)の「スキップ」状態(以後非表示)。
  Future<bool> isFirstPostGuideSkipped() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstPostGuideSkippedKey) ?? false;
  }

  Future<void> skipFirstPostGuide() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstPostGuideSkippedKey, true);
  }

  /// S-08 初回投稿完了演出(完了カード → 通知プレ許可ダイアログ →
  /// 「Proを3日間無料で試す」バナー)の表示済み状態。
  ///
  /// design.md 第9章「3日トライアル導線の接続」節準拠: トライアルバナーの
  /// **表示時点**でこのフラグを記録する(billing節が旧設計で持っていた
  /// `paywallShownV1` 相当のフラグを本フラグに一本化する)。
  Future<bool> isFirstCompletionCelebrationShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstCompletionCelebrationShownKey) ?? false;
  }

  Future<void> markFirstCompletionCelebrationShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstCompletionCelebrationShownKey, true);
  }
}

@Riverpod(keepAlive: true)
OnboardingRepository onboardingRepository(Ref ref) => OnboardingRepository();
