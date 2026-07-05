import 'dart:isolate';

import 'package:flutter_camera/src/core/utils/tune_color_matrix.dart';
import 'package:flutter_camera/src/features/patterns/domain/pattern.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// Pattern → pro_image_editor `ImportStateHistory` 用マップの生成(design.md
/// 「カメラ・自動加工パイプライン設計」§3.2/§3.4準拠)。
///
/// マップスキーマは pro_image_editor 13.0.0 の実装(`ImportStateHistory.fromMap`
/// / `WidgetLayer.fromMap` / `LayerInteraction.fromMap` / `TuneAdjustmentMatrix.fromMap`)
/// から確認済みのバージョン `6.5.0`(`ExportImportVersion.version_6_5_0`)形式。
///
/// 純Dart処理(`jsonEncode`/`jsonDecode`は行わないが行列生成自体が対象)のため、
/// パターン一覧同期時のジャンク防止に `Isolate.run` から呼び出すことを想定し、
/// クロージャに非Sendableな状態を持たせないトップレベル関数として定義する(§3.4)。
///
/// [pattern] が `null` の場合は「加工なし」(S-04カルーセル先頭タイル)を表し、
/// フィルター・レイヤーとも無しの初期状態マップを返す。
Map<String, dynamic> buildPatternImportMap({
  required Pattern? pattern,
  required double imgW,
  required double imgH,
}) {
  if (pattern == null) {
    return {
      'version': '6.5.0',
      // position は「history配列内の0始まりインデックス」。pro_image_editor 12.4.7 の
      // import(replace + enableInitialEmptyState=true 既定)は先頭に空ステートを
      // 追加したうえで historyPointer = position + 1 を設定するため、1 を渡すと
      // ポインタが範囲外(履歴長2に対し2)となり import が RangeError で失敗し、
      // ローディングダイアログが閉じなくなる(同パッケージの export 実装も
      // ExportHistorySpan.current では position: 0 を書き出す)。
      'position': 0,
      'imgSize': {'width': imgW, 'height': imgH},
      'history': [
        {
          'layers': <Map<String, dynamic>>[],
          'tune': <Map<String, dynamic>>[],
          'filters': <Map<String, dynamic>>[],
        },
      ],
      'references': <String, dynamic>{},
    };
  }

  final p = pattern.filterParams;
  final tune = <Map<String, dynamic>>[
    {
      'id': 'brightness',
      'value': p.brightness,
      'matrix': ColorFilterAddons.brightness(p.brightness),
    },
    {
      'id': 'contrast',
      'value': p.contrast,
      'matrix': ColorFilterAddons.contrast(p.contrast),
    },
    {
      'id': 'saturation',
      'value': p.saturation,
      'matrix': ColorFilterAddons.saturation(p.saturation),
    },
    {
      'id': 'exposure',
      'value': p.exposure,
      'matrix': ColorFilterAddons.exposure(p.exposure),
    },
    {'id': 'hue', 'value': p.hue, 'matrix': ColorFilterAddons.hue(p.hue)},
    {
      'id': 'temperature',
      'value': p.temperature,
      'matrix': ColorFilterAddons.temperature(p.temperature),
    },
    {'id': 'tint', 'value': p.tint, 'matrix': tintColorMatrix(p.tint)},
    {'id': 'fade', 'value': p.fade, 'matrix': ColorFilterAddons.fade(p.fade)},
  ];

  final references = <String, dynamic>{};
  final layerRefs = <Map<String, dynamic>>[];
  var i = 0;

  // レイヤー順序: [0]=フレーム(最下層・操作不可) → [1..]=スタンプ(上層・操作可)。§4.1。
  // id には Storageフルパスではなく `Pattern.frameAssetId` / `StampLayer.assetId`
  // (`assets/{assetId}` ドキュメントID)を用いる(patterns フィーチャー実装済みスキーマに
  // 合わせた調整。coreChangeRequests参照)。
  if (pattern.frameAssetId != null) {
    references['L$i'] = {
      'x': 0.0,
      'y': 0.0,
      'rotation': 0.0,
      'scale': 1.0,
      'flipX': false,
      'flipY': false,
      'interaction': {
        'enableMove': false,
        'enableScale': false,
        'enableRotate': false,
        'enableSelection': false,
      },
      'type': 'widget',
      'exportConfigs': {'id': 'frame:${pattern.frameAssetId}'},
    };
    layerRefs.add({'id': 'L$i'});
    i++;
  }
  for (final s in pattern.stampLayers) {
    references['L$i'] = {
      'x': (s.cx - 0.5) * imgW, // 相対→中心原点px(§4.2)
      'y': (s.cy - 0.5) * imgH,
      'rotation': s.rotation,
      'scale': 1.0, // 実寸はwidgetLoader側でwidthRatioから確定(§4.2)
      'flipX': s.flipX,
      'flipY': s.flipY,
      'interaction': {
        'enableMove': true,
        'enableScale': true,
        'enableRotate': true,
        'enableSelection': true,
      },
      'type': 'widget',
      'exportConfigs': {
        'id': 'stamp:${s.assetId}',
        'meta': {'widthRatio': s.widthRatio},
      },
    };
    layerRefs.add({'id': 'L$i'});
    i++;
  }

  return {
    'version': '6.5.0',
    'position': 1,
    'imgSize': {'width': imgW, 'height': imgH},
    'history': [
      {
        'layers': layerRefs,
        'tune': tune,
        'filters': <Map<String, dynamic>>[], // FilterModelプリセット未使用(tuneで表現)
        if (p.smoothing > 0) 'blur': p.smoothing * 2.0,
      },
    ],
    'references': references,
  };
}

/// [buildPatternImportMap] を `Isolate.run` 経由で実行するラッパー(design.md §3.4)。
/// UIスレッドのジャンクを防ぐため、パターン適用・再適用のたびにこちらを使用する。
Future<Map<String, dynamic>> buildPatternImportMapInBackground({
  required Pattern? pattern,
  required double imgW,
  required double imgH,
}) {
  return Isolate.run(
    () => buildPatternImportMap(pattern: pattern, imgW: imgW, imgH: imgH),
  );
}
