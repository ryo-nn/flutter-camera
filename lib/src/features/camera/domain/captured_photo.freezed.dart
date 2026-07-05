// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'captured_photo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CapturedPhoto {

/// `CameraSession.capture()`(= `CameraController.takePicture()`)が返す
/// JPEG一時ファイルのパス、またはフォトライブラリから選択した画像のパス。
 String get imagePath;/// 撮影時に選択されていたレンズ向き(フロント/バック)。フォトライブラリ由来の
/// 場合は該当する概念が無いため `null`。
 CameraLensDirection? get lensDirection;/// カメラ撮影/フォトライブラリ選択のいずれに由来するか(既定はカメラ撮影)。
 CapturedMediaSource get source;
/// Create a copy of CapturedPhoto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CapturedPhotoCopyWith<CapturedPhoto> get copyWith => _$CapturedPhotoCopyWithImpl<CapturedPhoto>(this as CapturedPhoto, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CapturedPhoto&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath)&&(identical(other.lensDirection, lensDirection) || other.lensDirection == lensDirection)&&(identical(other.source, source) || other.source == source));
}


@override
int get hashCode => Object.hash(runtimeType,imagePath,lensDirection,source);

@override
String toString() {
  return 'CapturedPhoto(imagePath: $imagePath, lensDirection: $lensDirection, source: $source)';
}


}

/// @nodoc
abstract mixin class $CapturedPhotoCopyWith<$Res>  {
  factory $CapturedPhotoCopyWith(CapturedPhoto value, $Res Function(CapturedPhoto) _then) = _$CapturedPhotoCopyWithImpl;
@useResult
$Res call({
 String imagePath, CameraLensDirection? lensDirection, CapturedMediaSource source
});




}
/// @nodoc
class _$CapturedPhotoCopyWithImpl<$Res>
    implements $CapturedPhotoCopyWith<$Res> {
  _$CapturedPhotoCopyWithImpl(this._self, this._then);

  final CapturedPhoto _self;
  final $Res Function(CapturedPhoto) _then;

/// Create a copy of CapturedPhoto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? imagePath = null,Object? lensDirection = freezed,Object? source = null,}) {
  return _then(_self.copyWith(
imagePath: null == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String,lensDirection: freezed == lensDirection ? _self.lensDirection : lensDirection // ignore: cast_nullable_to_non_nullable
as CameraLensDirection?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as CapturedMediaSource,
  ));
}

}


/// Adds pattern-matching-related methods to [CapturedPhoto].
extension CapturedPhotoPatterns on CapturedPhoto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CapturedPhoto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CapturedPhoto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CapturedPhoto value)  $default,){
final _that = this;
switch (_that) {
case _CapturedPhoto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CapturedPhoto value)?  $default,){
final _that = this;
switch (_that) {
case _CapturedPhoto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String imagePath,  CameraLensDirection? lensDirection,  CapturedMediaSource source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CapturedPhoto() when $default != null:
return $default(_that.imagePath,_that.lensDirection,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String imagePath,  CameraLensDirection? lensDirection,  CapturedMediaSource source)  $default,) {final _that = this;
switch (_that) {
case _CapturedPhoto():
return $default(_that.imagePath,_that.lensDirection,_that.source);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String imagePath,  CameraLensDirection? lensDirection,  CapturedMediaSource source)?  $default,) {final _that = this;
switch (_that) {
case _CapturedPhoto() when $default != null:
return $default(_that.imagePath,_that.lensDirection,_that.source);case _:
  return null;

}
}

}

/// @nodoc


class _CapturedPhoto implements CapturedPhoto {
  const _CapturedPhoto({required this.imagePath, this.lensDirection, this.source = CapturedMediaSource.camera});
  

/// `CameraSession.capture()`(= `CameraController.takePicture()`)が返す
/// JPEG一時ファイルのパス、またはフォトライブラリから選択した画像のパス。
@override final  String imagePath;
/// 撮影時に選択されていたレンズ向き(フロント/バック)。フォトライブラリ由来の
/// 場合は該当する概念が無いため `null`。
@override final  CameraLensDirection? lensDirection;
/// カメラ撮影/フォトライブラリ選択のいずれに由来するか(既定はカメラ撮影)。
@override@JsonKey() final  CapturedMediaSource source;

/// Create a copy of CapturedPhoto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CapturedPhotoCopyWith<_CapturedPhoto> get copyWith => __$CapturedPhotoCopyWithImpl<_CapturedPhoto>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CapturedPhoto&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath)&&(identical(other.lensDirection, lensDirection) || other.lensDirection == lensDirection)&&(identical(other.source, source) || other.source == source));
}


@override
int get hashCode => Object.hash(runtimeType,imagePath,lensDirection,source);

@override
String toString() {
  return 'CapturedPhoto(imagePath: $imagePath, lensDirection: $lensDirection, source: $source)';
}


}

/// @nodoc
abstract mixin class _$CapturedPhotoCopyWith<$Res> implements $CapturedPhotoCopyWith<$Res> {
  factory _$CapturedPhotoCopyWith(_CapturedPhoto value, $Res Function(_CapturedPhoto) _then) = __$CapturedPhotoCopyWithImpl;
@override @useResult
$Res call({
 String imagePath, CameraLensDirection? lensDirection, CapturedMediaSource source
});




}
/// @nodoc
class __$CapturedPhotoCopyWithImpl<$Res>
    implements _$CapturedPhotoCopyWith<$Res> {
  __$CapturedPhotoCopyWithImpl(this._self, this._then);

  final _CapturedPhoto _self;
  final $Res Function(_CapturedPhoto) _then;

/// Create a copy of CapturedPhoto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? imagePath = null,Object? lensDirection = freezed,Object? source = null,}) {
  return _then(_CapturedPhoto(
imagePath: null == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String,lensDirection: freezed == lensDirection ? _self.lensDirection : lensDirection // ignore: cast_nullable_to_non_nullable
as CameraLensDirection?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as CapturedMediaSource,
  ));
}


}

// dart format on
