import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_camera/src/core/models/converters.dart';
import 'package:flutter_camera/src/features/patterns/domain/filter_params.dart';
import 'package:flutter_camera/src/features/patterns/domain/stamp_layer.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pattern.freezed.dart';
part 'pattern.g.dart';

/// `patterns/{patternId}.ownerType`
enum PatternOwnerType {
  @JsonValue('preset')
  preset,
  @JsonValue('user')
  user,
}

/// `patterns/{patternId}`
///
/// 運営プリセットとユーザー作成パターンを1コレクションに集約し、`ownerType` で区別する
/// (design.md データモデル・ストレージ・セキュリティルール設計章 準拠)。
///
/// 注意: dart:core の `Pattern` と同名だが、Dartでは非プラットフォームライブラリの
/// 宣言がプラットフォームライブラリ(dart:core)の同名宣言を優先解決するため、
/// importするだけで衝突エラーにはならない(design.md 明記のとおり)。
///
/// フィールド定義は design.md データモデル章の統合スキーマを正とし、
/// リテンション機能設計章(§プレミアムパターン)の `isPremium` / `publishedAt` を
/// 追加で反映する。`frameAssetId` / `stampLayers[].assetId` は実際に運用中の
/// `firestore.rules` `isValidPattern` / `storage.rules` / `firestore.indexes.json`
/// (`assets` コレクション: `type` + `sortOrder` の複合インデックス)と一致させている
/// (coreChangeRequests参照: editor feature 側の想定と食い違いがあるため要調整依頼)。
@freezed
sealed class Pattern with _$Pattern {
  const factory Pattern({
    /// ドキュメントID(Firestoreには保存しない。読み取り時に付与)
    @JsonKey(includeToJson: false) required String id,
    required PatternOwnerType ownerType,

    /// プリセットの場合は null
    String? ownerUid,
    required String name,
    required FilterParams filterParams,

    /// フレーム素材のアセットID(`assets/{assetId}` のドキュメントID)。
    /// フレームなしは null
    String? frameAssetId,

    /// スタンプレイヤー(最大10件。配列順 = 重ね順)
    @Default(<StampLayer>[]) List<StampLayer> stampLayers,

    /// プリセットの表示順。ユーザー作成は0固定
    @Default(0) int sortOrder,

    /// Pro限定パターン(要件§3.2)。`ownerType: preset` のみ true になり得る。
    /// ユーザー作成パターンでは常に false(リテンション機能設計章準拠。
    /// Rulesの `hasOnly` / `affectedKeys().hasOnly` に含まれないためクライアントは
    /// 書き込めない)
    @Default(false) bool isPremium,

    /// 公式パターンの配信日時(NEWバッジ表示用)。ユーザー作成は null
    /// (リテンション機能設計章準拠)
    @NullableTimestampConverter() DateTime? publishedAt,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _Pattern;

  factory Pattern.fromJson(Map<String, Object?> json) =>
      _$PatternFromJson(json);
}

/// design.md データモデル章「name(1〜50文字)」準拠。
abstract final class PatternNameLimits {
  static const int maxLength = 50;
}
