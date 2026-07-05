// NOTE(統合フェーズ申し送り): riverpod_generator/freezed のコード生成
// (pattern.freezed.dart 等)は統合フェーズで一括実行する方針のため、現時点では未生成
// (`build_runner build` 実行後に実行可能になる)。フィールド定義は実装済みの
// patterns フィーチャー(lib/src/features/patterns/domain/)に合わせている。
import 'package:flutter_camera/src/features/editor/data/pattern_import_map_builder.dart';
import 'package:flutter_camera/src/features/patterns/domain/filter_params.dart';
import 'package:flutter_camera/src/features/patterns/domain/pattern.dart';
import 'package:flutter_camera/src/features/patterns/domain/stamp_layer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart' show ColorFilterAddons;

void main() {
  // design.md「カメラ・自動加工パイプライン設計」§3.2
  // 「Pattern → ImportStateHistory 用マップ生成」の単体テスト。

  const imgW = 1080.0;
  const imgH = 1350.0;

  Pattern buildPattern({
    required FilterParams filterParams,
    String? frameAssetId,
    List<StampLayer> stampLayers = const [],
  }) {
    final now = DateTime(2026, 1, 1);
    return Pattern(
      id: 'p1',
      ownerType: PatternOwnerType.user,
      ownerUid: 'uid1',
      name: 'テストパターン',
      filterParams: filterParams,
      frameAssetId: frameAssetId,
      stampLayers: stampLayers,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('pattern が null の場合はフィルター・レイヤーとも無しの初期状態マップを返す', () {
    final map = buildPatternImportMap(pattern: null, imgW: imgW, imgH: imgH);

    expect(map['version'], '6.5.0');
    // 0始まりインデックス。import側(enableInitialEmptyState=true)が +1 する
    // (pattern_import_map_builder.dart の position コメント参照)。
    expect(map['position'], 0);
    expect(map['imgSize'], {'width': imgW, 'height': imgH});
    final history = (map['history'] as List).single as Map<String, dynamic>;
    expect(history['layers'], isEmpty);
    expect(history['tune'], isEmpty);
    expect(history['filters'], isEmpty);
    expect(history.containsKey('blur'), isFalse);
    expect(map['references'], isEmpty);
  });

  test('filterParamsの8項目がtuneエントリとしてColorFilterAddonsの行列と一致する', () {
    const filterParams = FilterParams(
      brightness: 0.1,
      contrast: 0.05,
      saturation: 0.08,
      exposure: 0.2,
      hue: 0.05,
      temperature: 0.05,
      tint: -0.02,
      fade: 0.1,
      smoothing: 0.0,
    );
    final pattern = buildPattern(filterParams: filterParams);

    final map = buildPatternImportMap(pattern: pattern, imgW: imgW, imgH: imgH);
    final history = (map['history'] as List).single as Map<String, dynamic>;
    final tune = (history['tune'] as List).cast<Map<String, dynamic>>();

    expect(tune.map((e) => e['id']), [
      'brightness',
      'contrast',
      'saturation',
      'exposure',
      'hue',
      'temperature',
      'tint',
      'fade',
    ]);

    final brightnessEntry = tune.firstWhere((e) => e['id'] == 'brightness');
    expect(brightnessEntry['value'], filterParams.brightness);
    expect(
      brightnessEntry['matrix'],
      ColorFilterAddons.brightness(filterParams.brightness),
    );

    // smoothing = 0 のため blur キーは含まれない。
    expect(history.containsKey('blur'), isFalse);
  });

  test('smoothingが0より大きい場合はblur = smoothing * 2.0を含む', () {
    const filterParams = FilterParams(
      brightness: 0,
      contrast: 0,
      saturation: 0,
      exposure: 0,
      hue: 0,
      temperature: 0,
      tint: 0,
      fade: 0,
      smoothing: 0.4,
    );
    final pattern = buildPattern(filterParams: filterParams);

    final map = buildPatternImportMap(pattern: pattern, imgW: imgW, imgH: imgH);
    final history = (map['history'] as List).single as Map<String, dynamic>;

    expect(history['blur'], closeTo(0.8, 1e-9));
  });

  test('フレームはL0・操作不可、スタンプはL1以降・操作可としてreferencesに積まれる', () {
    const filterParams = FilterParams(
      brightness: 0,
      contrast: 0,
      saturation: 0,
      exposure: 0,
      hue: 0,
      temperature: 0,
      tint: 0,
      fade: 0,
      smoothing: 0,
    );
    final pattern = buildPattern(
      filterParams: filterParams,
      frameAssetId: 'asset-frame-1',
      stampLayers: const [
        StampLayer(
          assetId: 'asset-stamp-1',
          cx: 0.82,
          cy: 0.12,
          widthRatio: 0.22,
          rotation: 0.26,
        ),
      ],
    );

    final map = buildPatternImportMap(pattern: pattern, imgW: imgW, imgH: imgH);
    final history = (map['history'] as List).single as Map<String, dynamic>;
    final layers = (history['layers'] as List).cast<Map<String, dynamic>>();
    final references = map['references'] as Map<String, dynamic>;

    expect(layers.map((e) => e['id']), ['L0', 'L1']);

    final frameRef = references['L0'] as Map<String, dynamic>;
    expect(frameRef['x'], 0.0);
    expect(frameRef['y'], 0.0);
    expect((frameRef['interaction'] as Map)['enableMove'], isFalse);
    expect((frameRef['exportConfigs'] as Map)['id'], 'frame:asset-frame-1');

    final stampRef = references['L1'] as Map<String, dynamic>;
    // x = (cx - 0.5) * imgW, y = (cy - 0.5) * imgH (design.md §4.2)
    expect(stampRef['x'], closeTo((0.82 - 0.5) * imgW, 1e-9));
    expect(stampRef['y'], closeTo((0.12 - 0.5) * imgH, 1e-9));
    expect(stampRef['scale'], 1.0);
    expect((stampRef['interaction'] as Map)['enableMove'], isTrue);
    expect((stampRef['exportConfigs'] as Map)['id'], 'stamp:asset-stamp-1');
    expect(
      ((stampRef['exportConfigs'] as Map)['meta'] as Map)['widthRatio'],
      0.22,
    );
  });

  test('frameAssetIdがnullの場合はフレームレイヤーを含めない', () {
    const filterParams = FilterParams(
      brightness: 0,
      contrast: 0,
      saturation: 0,
      exposure: 0,
      hue: 0,
      temperature: 0,
      tint: 0,
      fade: 0,
      smoothing: 0,
    );
    final pattern = buildPattern(filterParams: filterParams);

    final map = buildPatternImportMap(pattern: pattern, imgW: imgW, imgH: imgH);
    final history = (map['history'] as List).single as Map<String, dynamic>;
    final layers = (history['layers'] as List);

    expect(layers, isEmpty);
  });
}
