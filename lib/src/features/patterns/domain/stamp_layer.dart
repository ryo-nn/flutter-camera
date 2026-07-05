import 'package:freezed_annotation/freezed_annotation.dart';

part 'stamp_layer.freezed.dart';
part 'stamp_layer.g.dart';

/// `patterns/{patternId}.stampLayers[]`
///
/// 配列順 = 重ね順(下→上)。座標系は基準画像に対する正規化座標
/// (design.md データモデル章 + カメラ・自動加工パイプライン設計章 §4.2 準拠)。
@freezed
sealed class StampLayer with _$StampLayer {
  const factory StampLayer({
    /// スタンプ素材のアセットID(`assets/{assetId}` のドキュメントID。
    /// 実際に運用中の `firestore.rules` `isValidPattern` が参照するフィールド名に
    /// 合わせる。coreChangeRequests参照)。
    required String assetId,

    /// スタンプ中心のX座標(基準画像に対する正規化座標 0.0〜1.0)
    required double cx,

    /// スタンプ中心のY座標(正規化座標 0.0〜1.0)
    required double cy,

    /// 基準画像幅に対するスタンプ幅の比(0.05〜1.0。カメラ・自動加工パイプライン
    /// 設計章 §2.2 準拠。下限0.05は視認不能なほど小さいスタンプを防ぐUI制約)
    required double widthRatio,

    /// 回転角(ラジアン)。既定0.0
    @Default(0.0) double rotation,

    /// 左右反転
    @Default(false) bool flipX,

    /// 上下反転
    @Default(false) bool flipY,
  }) = _StampLayer;

  factory StampLayer.fromJson(Map<String, Object?> json) =>
      _$StampLayerFromJson(json);
}

/// S-06a スタンプ編集の値域定数(design.md カメラ・自動加工パイプライン設計章 §2.2準拠)。
abstract final class StampLayerLimits {
  static const double minWidthRatio = 0.05;
  static const double maxWidthRatio = 1.0;

  /// design.md データモデル章「stampLayers(最大10件)」準拠。
  static const int maxLayers = 10;

  static double clampWidthRatio(double value) =>
      value.clamp(minWidthRatio, maxWidthRatio);

  static double clampNormalized(double value) => value.clamp(0.0, 1.0);
}
