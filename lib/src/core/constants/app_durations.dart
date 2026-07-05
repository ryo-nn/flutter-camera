/// アプリ全体で共有する期間・タイムアウト定数。
abstract final class AppDurations {
  /// Dio のタイムアウト(design.md architectureセクション dioProvider 定義準拠)。
  static const Duration networkTimeout = Duration(seconds: 10);

  /// 起動処理でスピナーを出し始めるまでの猶予(S-01 スプラッシュ)。
  static const Duration splashSpinnerDelay = Duration(seconds: 1);

  /// ロード状態表示のちらつき防止しきい値(共通UI状態の設計方針)。
  static const Duration loadingFlickerGuard = Duration(milliseconds: 300);

  /// 公式配信プリセットに「NEW」バッジを表示する期間(仮置き14日。
  /// design.md リテンション章「配信フロー」参照。事業側確定待ち)。
  static const Duration newPatternBadgeThreshold = Duration(days: 14);
}
