// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'filter_params.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FilterParams {

/// 明るさ: -0.5〜0.5(0.0 = 無補正)
 double get brightness;/// コントラスト: -0.5〜0.5
 double get contrast;/// 彩度: -0.5〜0.5
 double get saturation;/// 露出: -1.0〜1.0
 double get exposure;/// 色相: -0.25〜0.25
 double get hue;/// 色温度: -0.5〜0.5
 double get temperature;/// ティント: -0.5〜0.5
 double get tint;/// フェード: -1.0〜1.0
 double get fade;/// 美肌補正強度: 0.0〜1.0(カスタム実装。imagingセクション参照)
 double get smoothing;
/// Create a copy of FilterParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilterParamsCopyWith<FilterParams> get copyWith => _$FilterParamsCopyWithImpl<FilterParams>(this as FilterParams, _$identity);

  /// Serializes this FilterParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilterParams&&(identical(other.brightness, brightness) || other.brightness == brightness)&&(identical(other.contrast, contrast) || other.contrast == contrast)&&(identical(other.saturation, saturation) || other.saturation == saturation)&&(identical(other.exposure, exposure) || other.exposure == exposure)&&(identical(other.hue, hue) || other.hue == hue)&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.tint, tint) || other.tint == tint)&&(identical(other.fade, fade) || other.fade == fade)&&(identical(other.smoothing, smoothing) || other.smoothing == smoothing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,brightness,contrast,saturation,exposure,hue,temperature,tint,fade,smoothing);

@override
String toString() {
  return 'FilterParams(brightness: $brightness, contrast: $contrast, saturation: $saturation, exposure: $exposure, hue: $hue, temperature: $temperature, tint: $tint, fade: $fade, smoothing: $smoothing)';
}


}

/// @nodoc
abstract mixin class $FilterParamsCopyWith<$Res>  {
  factory $FilterParamsCopyWith(FilterParams value, $Res Function(FilterParams) _then) = _$FilterParamsCopyWithImpl;
@useResult
$Res call({
 double brightness, double contrast, double saturation, double exposure, double hue, double temperature, double tint, double fade, double smoothing
});




}
/// @nodoc
class _$FilterParamsCopyWithImpl<$Res>
    implements $FilterParamsCopyWith<$Res> {
  _$FilterParamsCopyWithImpl(this._self, this._then);

  final FilterParams _self;
  final $Res Function(FilterParams) _then;

/// Create a copy of FilterParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? brightness = null,Object? contrast = null,Object? saturation = null,Object? exposure = null,Object? hue = null,Object? temperature = null,Object? tint = null,Object? fade = null,Object? smoothing = null,}) {
  return _then(_self.copyWith(
brightness: null == brightness ? _self.brightness : brightness // ignore: cast_nullable_to_non_nullable
as double,contrast: null == contrast ? _self.contrast : contrast // ignore: cast_nullable_to_non_nullable
as double,saturation: null == saturation ? _self.saturation : saturation // ignore: cast_nullable_to_non_nullable
as double,exposure: null == exposure ? _self.exposure : exposure // ignore: cast_nullable_to_non_nullable
as double,hue: null == hue ? _self.hue : hue // ignore: cast_nullable_to_non_nullable
as double,temperature: null == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double,tint: null == tint ? _self.tint : tint // ignore: cast_nullable_to_non_nullable
as double,fade: null == fade ? _self.fade : fade // ignore: cast_nullable_to_non_nullable
as double,smoothing: null == smoothing ? _self.smoothing : smoothing // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [FilterParams].
extension FilterParamsPatterns on FilterParams {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FilterParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FilterParams() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FilterParams value)  $default,){
final _that = this;
switch (_that) {
case _FilterParams():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FilterParams value)?  $default,){
final _that = this;
switch (_that) {
case _FilterParams() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double brightness,  double contrast,  double saturation,  double exposure,  double hue,  double temperature,  double tint,  double fade,  double smoothing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FilterParams() when $default != null:
return $default(_that.brightness,_that.contrast,_that.saturation,_that.exposure,_that.hue,_that.temperature,_that.tint,_that.fade,_that.smoothing);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double brightness,  double contrast,  double saturation,  double exposure,  double hue,  double temperature,  double tint,  double fade,  double smoothing)  $default,) {final _that = this;
switch (_that) {
case _FilterParams():
return $default(_that.brightness,_that.contrast,_that.saturation,_that.exposure,_that.hue,_that.temperature,_that.tint,_that.fade,_that.smoothing);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double brightness,  double contrast,  double saturation,  double exposure,  double hue,  double temperature,  double tint,  double fade,  double smoothing)?  $default,) {final _that = this;
switch (_that) {
case _FilterParams() when $default != null:
return $default(_that.brightness,_that.contrast,_that.saturation,_that.exposure,_that.hue,_that.temperature,_that.tint,_that.fade,_that.smoothing);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FilterParams implements FilterParams {
  const _FilterParams({this.brightness = 0.0, this.contrast = 0.0, this.saturation = 0.0, this.exposure = 0.0, this.hue = 0.0, this.temperature = 0.0, this.tint = 0.0, this.fade = 0.0, this.smoothing = 0.0});
  factory _FilterParams.fromJson(Map<String, dynamic> json) => _$FilterParamsFromJson(json);

/// 明るさ: -0.5〜0.5(0.0 = 無補正)
@override@JsonKey() final  double brightness;
/// コントラスト: -0.5〜0.5
@override@JsonKey() final  double contrast;
/// 彩度: -0.5〜0.5
@override@JsonKey() final  double saturation;
/// 露出: -1.0〜1.0
@override@JsonKey() final  double exposure;
/// 色相: -0.25〜0.25
@override@JsonKey() final  double hue;
/// 色温度: -0.5〜0.5
@override@JsonKey() final  double temperature;
/// ティント: -0.5〜0.5
@override@JsonKey() final  double tint;
/// フェード: -1.0〜1.0
@override@JsonKey() final  double fade;
/// 美肌補正強度: 0.0〜1.0(カスタム実装。imagingセクション参照)
@override@JsonKey() final  double smoothing;

/// Create a copy of FilterParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterParamsCopyWith<_FilterParams> get copyWith => __$FilterParamsCopyWithImpl<_FilterParams>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterParamsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterParams&&(identical(other.brightness, brightness) || other.brightness == brightness)&&(identical(other.contrast, contrast) || other.contrast == contrast)&&(identical(other.saturation, saturation) || other.saturation == saturation)&&(identical(other.exposure, exposure) || other.exposure == exposure)&&(identical(other.hue, hue) || other.hue == hue)&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.tint, tint) || other.tint == tint)&&(identical(other.fade, fade) || other.fade == fade)&&(identical(other.smoothing, smoothing) || other.smoothing == smoothing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,brightness,contrast,saturation,exposure,hue,temperature,tint,fade,smoothing);

@override
String toString() {
  return 'FilterParams(brightness: $brightness, contrast: $contrast, saturation: $saturation, exposure: $exposure, hue: $hue, temperature: $temperature, tint: $tint, fade: $fade, smoothing: $smoothing)';
}


}

/// @nodoc
abstract mixin class _$FilterParamsCopyWith<$Res> implements $FilterParamsCopyWith<$Res> {
  factory _$FilterParamsCopyWith(_FilterParams value, $Res Function(_FilterParams) _then) = __$FilterParamsCopyWithImpl;
@override @useResult
$Res call({
 double brightness, double contrast, double saturation, double exposure, double hue, double temperature, double tint, double fade, double smoothing
});




}
/// @nodoc
class __$FilterParamsCopyWithImpl<$Res>
    implements _$FilterParamsCopyWith<$Res> {
  __$FilterParamsCopyWithImpl(this._self, this._then);

  final _FilterParams _self;
  final $Res Function(_FilterParams) _then;

/// Create a copy of FilterParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? brightness = null,Object? contrast = null,Object? saturation = null,Object? exposure = null,Object? hue = null,Object? temperature = null,Object? tint = null,Object? fade = null,Object? smoothing = null,}) {
  return _then(_FilterParams(
brightness: null == brightness ? _self.brightness : brightness // ignore: cast_nullable_to_non_nullable
as double,contrast: null == contrast ? _self.contrast : contrast // ignore: cast_nullable_to_non_nullable
as double,saturation: null == saturation ? _self.saturation : saturation // ignore: cast_nullable_to_non_nullable
as double,exposure: null == exposure ? _self.exposure : exposure // ignore: cast_nullable_to_non_nullable
as double,hue: null == hue ? _self.hue : hue // ignore: cast_nullable_to_non_nullable
as double,temperature: null == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double,tint: null == tint ? _self.tint : tint // ignore: cast_nullable_to_non_nullable
as double,fade: null == fade ? _self.fade : fade // ignore: cast_nullable_to_non_nullable
as double,smoothing: null == smoothing ? _self.smoothing : smoothing // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
