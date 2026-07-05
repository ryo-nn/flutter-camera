// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stamp_layer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StampLayer {

/// スタンプ素材のアセットID(`assets/{assetId}` のドキュメントID。
/// 実際に運用中の `firestore.rules` `isValidPattern` が参照するフィールド名に
/// 合わせる。coreChangeRequests参照)。
 String get assetId;/// スタンプ中心のX座標(基準画像に対する正規化座標 0.0〜1.0)
 double get cx;/// スタンプ中心のY座標(正規化座標 0.0〜1.0)
 double get cy;/// 基準画像幅に対するスタンプ幅の比(0.05〜1.0。カメラ・自動加工パイプライン
/// 設計章 §2.2 準拠。下限0.05は視認不能なほど小さいスタンプを防ぐUI制約)
 double get widthRatio;/// 回転角(ラジアン)。既定0.0
 double get rotation;/// 左右反転
 bool get flipX;/// 上下反転
 bool get flipY;
/// Create a copy of StampLayer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StampLayerCopyWith<StampLayer> get copyWith => _$StampLayerCopyWithImpl<StampLayer>(this as StampLayer, _$identity);

  /// Serializes this StampLayer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StampLayer&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.cx, cx) || other.cx == cx)&&(identical(other.cy, cy) || other.cy == cy)&&(identical(other.widthRatio, widthRatio) || other.widthRatio == widthRatio)&&(identical(other.rotation, rotation) || other.rotation == rotation)&&(identical(other.flipX, flipX) || other.flipX == flipX)&&(identical(other.flipY, flipY) || other.flipY == flipY));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,assetId,cx,cy,widthRatio,rotation,flipX,flipY);

@override
String toString() {
  return 'StampLayer(assetId: $assetId, cx: $cx, cy: $cy, widthRatio: $widthRatio, rotation: $rotation, flipX: $flipX, flipY: $flipY)';
}


}

/// @nodoc
abstract mixin class $StampLayerCopyWith<$Res>  {
  factory $StampLayerCopyWith(StampLayer value, $Res Function(StampLayer) _then) = _$StampLayerCopyWithImpl;
@useResult
$Res call({
 String assetId, double cx, double cy, double widthRatio, double rotation, bool flipX, bool flipY
});




}
/// @nodoc
class _$StampLayerCopyWithImpl<$Res>
    implements $StampLayerCopyWith<$Res> {
  _$StampLayerCopyWithImpl(this._self, this._then);

  final StampLayer _self;
  final $Res Function(StampLayer) _then;

/// Create a copy of StampLayer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? assetId = null,Object? cx = null,Object? cy = null,Object? widthRatio = null,Object? rotation = null,Object? flipX = null,Object? flipY = null,}) {
  return _then(_self.copyWith(
assetId: null == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String,cx: null == cx ? _self.cx : cx // ignore: cast_nullable_to_non_nullable
as double,cy: null == cy ? _self.cy : cy // ignore: cast_nullable_to_non_nullable
as double,widthRatio: null == widthRatio ? _self.widthRatio : widthRatio // ignore: cast_nullable_to_non_nullable
as double,rotation: null == rotation ? _self.rotation : rotation // ignore: cast_nullable_to_non_nullable
as double,flipX: null == flipX ? _self.flipX : flipX // ignore: cast_nullable_to_non_nullable
as bool,flipY: null == flipY ? _self.flipY : flipY // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StampLayer].
extension StampLayerPatterns on StampLayer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StampLayer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StampLayer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StampLayer value)  $default,){
final _that = this;
switch (_that) {
case _StampLayer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StampLayer value)?  $default,){
final _that = this;
switch (_that) {
case _StampLayer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String assetId,  double cx,  double cy,  double widthRatio,  double rotation,  bool flipX,  bool flipY)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StampLayer() when $default != null:
return $default(_that.assetId,_that.cx,_that.cy,_that.widthRatio,_that.rotation,_that.flipX,_that.flipY);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String assetId,  double cx,  double cy,  double widthRatio,  double rotation,  bool flipX,  bool flipY)  $default,) {final _that = this;
switch (_that) {
case _StampLayer():
return $default(_that.assetId,_that.cx,_that.cy,_that.widthRatio,_that.rotation,_that.flipX,_that.flipY);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String assetId,  double cx,  double cy,  double widthRatio,  double rotation,  bool flipX,  bool flipY)?  $default,) {final _that = this;
switch (_that) {
case _StampLayer() when $default != null:
return $default(_that.assetId,_that.cx,_that.cy,_that.widthRatio,_that.rotation,_that.flipX,_that.flipY);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StampLayer implements StampLayer {
  const _StampLayer({required this.assetId, required this.cx, required this.cy, required this.widthRatio, this.rotation = 0.0, this.flipX = false, this.flipY = false});
  factory _StampLayer.fromJson(Map<String, dynamic> json) => _$StampLayerFromJson(json);

/// スタンプ素材のアセットID(`assets/{assetId}` のドキュメントID。
/// 実際に運用中の `firestore.rules` `isValidPattern` が参照するフィールド名に
/// 合わせる。coreChangeRequests参照)。
@override final  String assetId;
/// スタンプ中心のX座標(基準画像に対する正規化座標 0.0〜1.0)
@override final  double cx;
/// スタンプ中心のY座標(正規化座標 0.0〜1.0)
@override final  double cy;
/// 基準画像幅に対するスタンプ幅の比(0.05〜1.0。カメラ・自動加工パイプライン
/// 設計章 §2.2 準拠。下限0.05は視認不能なほど小さいスタンプを防ぐUI制約)
@override final  double widthRatio;
/// 回転角(ラジアン)。既定0.0
@override@JsonKey() final  double rotation;
/// 左右反転
@override@JsonKey() final  bool flipX;
/// 上下反転
@override@JsonKey() final  bool flipY;

/// Create a copy of StampLayer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StampLayerCopyWith<_StampLayer> get copyWith => __$StampLayerCopyWithImpl<_StampLayer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StampLayerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StampLayer&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.cx, cx) || other.cx == cx)&&(identical(other.cy, cy) || other.cy == cy)&&(identical(other.widthRatio, widthRatio) || other.widthRatio == widthRatio)&&(identical(other.rotation, rotation) || other.rotation == rotation)&&(identical(other.flipX, flipX) || other.flipX == flipX)&&(identical(other.flipY, flipY) || other.flipY == flipY));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,assetId,cx,cy,widthRatio,rotation,flipX,flipY);

@override
String toString() {
  return 'StampLayer(assetId: $assetId, cx: $cx, cy: $cy, widthRatio: $widthRatio, rotation: $rotation, flipX: $flipX, flipY: $flipY)';
}


}

/// @nodoc
abstract mixin class _$StampLayerCopyWith<$Res> implements $StampLayerCopyWith<$Res> {
  factory _$StampLayerCopyWith(_StampLayer value, $Res Function(_StampLayer) _then) = __$StampLayerCopyWithImpl;
@override @useResult
$Res call({
 String assetId, double cx, double cy, double widthRatio, double rotation, bool flipX, bool flipY
});




}
/// @nodoc
class __$StampLayerCopyWithImpl<$Res>
    implements _$StampLayerCopyWith<$Res> {
  __$StampLayerCopyWithImpl(this._self, this._then);

  final _StampLayer _self;
  final $Res Function(_StampLayer) _then;

/// Create a copy of StampLayer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? assetId = null,Object? cx = null,Object? cy = null,Object? widthRatio = null,Object? rotation = null,Object? flipX = null,Object? flipY = null,}) {
  return _then(_StampLayer(
assetId: null == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String,cx: null == cx ? _self.cx : cx // ignore: cast_nullable_to_non_nullable
as double,cy: null == cy ? _self.cy : cy // ignore: cast_nullable_to_non_nullable
as double,widthRatio: null == widthRatio ? _self.widthRatio : widthRatio // ignore: cast_nullable_to_non_nullable
as double,rotation: null == rotation ? _self.rotation : rotation // ignore: cast_nullable_to_non_nullable
as double,flipX: null == flipX ? _self.flipX : flipX // ignore: cast_nullable_to_non_nullable
as bool,flipY: null == flipY ? _self.flipY : flipY // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
