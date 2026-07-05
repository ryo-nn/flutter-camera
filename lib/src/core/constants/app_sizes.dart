/// アプリ全体で共有する寸法定数(design.md UIフロー章「アクセシビリティ配慮」準拠)。
abstract final class AppSizes {
  /// すべての操作要素が満たすべき最小タップ領域(Materialガイドライン)。
  static const double minTapTarget = 48;

  /// S-04 シャッターボタンの直径。
  static const double shutterButtonSize = 72;

  /// パターンカルーセルのタイル間隔(誤タップ防止のための最小間隔)。
  static const double carouselTileSpacing = 8;
}
