import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_camera/src/core/models/converters.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'asset.freezed.dart';
part 'asset.g.dart';

/// `assets/{assetId}.type`(design.md データモデル・ストレージ・セキュリティルール
/// 設計章「enums.dart」の `AssetType` 準拠)。
enum AssetType {
  @JsonValue('frame')
  frame,
  @JsonValue('stamp')
  stamp,
}

/// `assets/{assetId}`(運営提供フレーム/スタンプ素材メタデータ。クライアント読み取り専用)。
///
/// design.md データモデル章の `asset.dart` 定義に、リテンション機能設計章
/// (「assets コレクションに isPremium(boolean・既定false)を追加」)の `isPremium` を
/// 追加した形(patterns/editor featureの双方から参照されるため
/// `core/models/` へ昇格配置。coreChangeRequests参照)。
@freezed
sealed class Asset with _$Asset {
  const factory Asset({
    /// ドキュメントID(Firestoreには保存しない。読み取り時に付与)
    @JsonKey(includeToJson: false) required String id,
    required AssetType type,
    /// 表示名(素材選択UI用)
    required String name,
    /// 画像本体のStorageパス(assets/frames/{assetId}.png 等)
    required String storagePath,
    /// 画像の幅(px)
    required int width,
    /// 画像の高さ(px)
    required int height,
    @Default(0) int sortOrder,
    /// Pro限定素材(リテンション機能設計章準拠)。実体はStorageの
    /// `assets/premium/` 専用プレフィックスに配置される。
    @Default(false) bool isPremium,
    @TimestampConverter() required DateTime createdAt,
    /// 画像差し替え時に更新。AssetCacheServiceのバージョン照合キー(imaging §4.3)
    @TimestampConverter() required DateTime updatedAt,
  }) = _Asset;

  factory Asset.fromJson(Map<String, Object?> json) => _$AssetFromJson(json);
}
