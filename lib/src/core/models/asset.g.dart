// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Asset _$AssetFromJson(Map<String, dynamic> json) => _Asset(
  id: json['id'] as String,
  type: $enumDecode(_$AssetTypeEnumMap, json['type']),
  name: json['name'] as String,
  storagePath: json['storagePath'] as String,
  width: (json['width'] as num).toInt(),
  height: (json['height'] as num).toInt(),
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  isPremium: json['isPremium'] as bool? ?? false,
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  updatedAt: const TimestampConverter().fromJson(
    json['updatedAt'] as Timestamp,
  ),
);

Map<String, dynamic> _$AssetToJson(_Asset instance) => <String, dynamic>{
  'type': _$AssetTypeEnumMap[instance.type]!,
  'name': instance.name,
  'storagePath': instance.storagePath,
  'width': instance.width,
  'height': instance.height,
  'sortOrder': instance.sortOrder,
  'isPremium': instance.isPremium,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
};

const _$AssetTypeEnumMap = {AssetType.frame: 'frame', AssetType.stamp: 'stamp'};
