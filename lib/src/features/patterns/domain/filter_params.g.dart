// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FilterParams _$FilterParamsFromJson(Map<String, dynamic> json) =>
    _FilterParams(
      brightness: (json['brightness'] as num?)?.toDouble() ?? 0.0,
      contrast: (json['contrast'] as num?)?.toDouble() ?? 0.0,
      saturation: (json['saturation'] as num?)?.toDouble() ?? 0.0,
      exposure: (json['exposure'] as num?)?.toDouble() ?? 0.0,
      hue: (json['hue'] as num?)?.toDouble() ?? 0.0,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      tint: (json['tint'] as num?)?.toDouble() ?? 0.0,
      fade: (json['fade'] as num?)?.toDouble() ?? 0.0,
      smoothing: (json['smoothing'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$FilterParamsToJson(_FilterParams instance) =>
    <String, dynamic>{
      'brightness': instance.brightness,
      'contrast': instance.contrast,
      'saturation': instance.saturation,
      'exposure': instance.exposure,
      'hue': instance.hue,
      'temperature': instance.temperature,
      'tint': instance.tint,
      'fade': instance.fade,
      'smoothing': instance.smoothing,
    };
