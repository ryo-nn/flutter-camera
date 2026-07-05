/// `FilterParams.tint`(ティント。design.md データモデル章「色相の自然な補完となる
/// 緑〜マゼンタ軸の色調整」)用の色行列生成。
///
/// 本プロジェクトが依存する `pro_image_editor` は、現行 Flutter SDK(3.41.2)との
/// 非互換(`SizeTransition.alignment` / `ReorderableListView.builder.onReorderItem`。
/// pubspec.yaml の `pro_image_editor` NOTE参照)を理由に 12.4.7 へバージョン固定して
/// おり、この `ColorFilterAddons.tint` 相当のプリセットは 13.0.0 で新規追加されたため
/// 12.4.7 には存在しない(旧 `luminance`は別軸の彩度落ちフィルターで代替不可)。
///
/// `TuneAdjustmentMatrix` は `id` を任意の表示ラベルとしてのみ扱い、実際の見た目は
/// `matrix`(標準の20要素 `ColorFilter.matrix` 形式)で決まる(pro_image_editor
/// 12.4.7 実ソース `tune_adjustment_matrix.dart` で確認済み)ため、editor/patterns の
/// 両featureのプレビュー・最終出力で見た目を完全一致させるにはこの行列生成を
/// 一箇所に集約する必要がある(`core/utils/` に配置)。
///
/// 行列自体は pro_image_editor 13.0.0 `ColorFilterAddons.tint` と同一の実装
/// (緑〜マゼンタ軸への線形オフセット)を採用する(pub-cacheの当該バージョン
/// ソースで確認済み。ライセンス上問題のない単純な線形色行列の再実装)。
List<double> tintColorMatrix(double value) {
  if (value == 0) {
    return [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
  }

  // マゼンタは赤/青を強め緑を弱める。緑方向はその逆。
  final offset = value * 100;

  return [
    1, 0, 0, 0, offset, // 赤チャンネル
    0, 1, 0, 0, -offset, // 緑チャンネル
    0, 0, 1, 0, offset, // 青チャンネル
    0, 0, 0, 1, 0, // アルファチャンネル(不変)
  ];
}
