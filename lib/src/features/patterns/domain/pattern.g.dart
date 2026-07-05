// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pattern.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Pattern _$PatternFromJson(Map<String, dynamic> json) => _Pattern(
  id: json['id'] as String,
  ownerType: $enumDecode(_$PatternOwnerTypeEnumMap, json['ownerType']),
  ownerUid: json['ownerUid'] as String?,
  name: json['name'] as String,
  filterParams: FilterParams.fromJson(
    json['filterParams'] as Map<String, dynamic>,
  ),
  frameAssetId: json['frameAssetId'] as String?,
  stampLayers:
      (json['stampLayers'] as List<dynamic>?)
          ?.map((e) => StampLayer.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <StampLayer>[],
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  isPremium: json['isPremium'] as bool? ?? false,
  publishedAt: const NullableTimestampConverter().fromJson(
    json['publishedAt'] as Timestamp?,
  ),
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  updatedAt: const TimestampConverter().fromJson(
    json['updatedAt'] as Timestamp,
  ),
);

Map<String, dynamic> _$PatternToJson(_Pattern instance) => <String, dynamic>{
  'ownerType': _$PatternOwnerTypeEnumMap[instance.ownerType]!,
  'ownerUid': instance.ownerUid,
  'name': instance.name,
  'filterParams': instance.filterParams.toJson(),
  'frameAssetId': instance.frameAssetId,
  'stampLayers': instance.stampLayers.map((e) => e.toJson()).toList(),
  'sortOrder': instance.sortOrder,
  'isPremium': instance.isPremium,
  'publishedAt': const NullableTimestampConverter().toJson(
    instance.publishedAt,
  ),
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
};

const _$PatternOwnerTypeEnumMap = {
  PatternOwnerType.preset: 'preset',
  PatternOwnerType.user: 'user',
};
