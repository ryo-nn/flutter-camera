// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stamp_layer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StampLayer _$StampLayerFromJson(Map<String, dynamic> json) => _StampLayer(
  assetId: json['assetId'] as String,
  cx: (json['cx'] as num).toDouble(),
  cy: (json['cy'] as num).toDouble(),
  widthRatio: (json['widthRatio'] as num).toDouble(),
  rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
  flipX: json['flipX'] as bool? ?? false,
  flipY: json['flipY'] as bool? ?? false,
);

Map<String, dynamic> _$StampLayerToJson(_StampLayer instance) =>
    <String, dynamic>{
      'assetId': instance.assetId,
      'cx': instance.cx,
      'cy': instance.cy,
      'widthRatio': instance.widthRatio,
      'rotation': instance.rotation,
      'flipX': instance.flipX,
      'flipY': instance.flipY,
    };
