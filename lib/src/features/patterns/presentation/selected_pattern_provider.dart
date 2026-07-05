import 'package:flutter_camera/src/features/patterns/domain/pattern.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_pattern_provider.g.dart';

/// 撮影フローで選択中のパターン(撮影→加工画面間で共有)。
/// (design.md アプリアーキテクチャ設計 Riverpod 3.0 プロバイダー設計
/// 「selectedPatternProvider」)
///
/// `null` = 「加工なし」。S-04(カメラ)・S-05(加工プレビュー)の
/// パターンカルーセルが共通で読み書きする(design.md 画面設計・UIフロー章 S-04/S-05準拠。
/// `camera/presentation/widgets/pattern_carousel.dart` が実際に
/// `ref.read(selectedPatternProvider.notifier).select(pattern)` の形で利用している)。
@riverpod
class SelectedPattern extends _$SelectedPattern {
  @override
  Pattern? build() => null;

  void select(Pattern? pattern) => state = pattern;
}
