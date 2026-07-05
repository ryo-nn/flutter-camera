// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'captured_video.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CapturedVideo {

/// `CameraSession.stopRecording()` が返す動画一時ファイルのパス、
/// またはフォトライブラリから選択した動画のパス。
 String get videoPath;/// 撮影時に選択されていたレンズ向き(フロント/バック)。フォトライブラリ由来の
/// 場合は該当する概念が無いため `null`。
 CameraLensDirection? get lensDirection;/// カメラ撮影/フォトライブラリ選択のいずれに由来するか(既定はカメラ撮影)。
 CapturedMediaSource get source;
/// Create a copy of CapturedVideo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CapturedVideoCopyWith<CapturedVideo> get copyWith => _$CapturedVideoCopyWithImpl<CapturedVideo>(this as CapturedVideo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CapturedVideo&&(identical(other.videoPath, videoPath) || other.videoPath == videoPath)&&(identical(other.lensDirection, lensDirection) || other.lensDirection == lensDirection)&&(identical(other.source, source) || other.source == source));
}


@override
int get hashCode => Object.hash(runtimeType,videoPath,lensDirection,source);

@override
String toString() {
  return 'CapturedVideo(videoPath: $videoPath, lensDirection: $lensDirection, source: $source)';
}


}

/// @nodoc
abstract mixin class $CapturedVideoCopyWith<$Res>  {
  factory $CapturedVideoCopyWith(CapturedVideo value, $Res Function(CapturedVideo) _then) = _$CapturedVideoCopyWithImpl;
@useResult
$Res call({
 String videoPath, CameraLensDirection? lensDirection, CapturedMediaSource source
});




}
/// @nodoc
class _$CapturedVideoCopyWithImpl<$Res>
    implements $CapturedVideoCopyWith<$Res> {
  _$CapturedVideoCopyWithImpl(this._self, this._then);

  final CapturedVideo _self;
  final $Res Function(CapturedVideo) _then;

/// Create a copy of CapturedVideo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? videoPath = null,Object? lensDirection = freezed,Object? source = null,}) {
  return _then(_self.copyWith(
videoPath: null == videoPath ? _self.videoPath : videoPath // ignore: cast_nullable_to_non_nullable
as String,lensDirection: freezed == lensDirection ? _self.lensDirection : lensDirection // ignore: cast_nullable_to_non_nullable
as CameraLensDirection?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as CapturedMediaSource,
  ));
}

}


/// Adds pattern-matching-related methods to [CapturedVideo].
extension CapturedVideoPatterns on CapturedVideo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CapturedVideo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CapturedVideo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CapturedVideo value)  $default,){
final _that = this;
switch (_that) {
case _CapturedVideo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CapturedVideo value)?  $default,){
final _that = this;
switch (_that) {
case _CapturedVideo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String videoPath,  CameraLensDirection? lensDirection,  CapturedMediaSource source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CapturedVideo() when $default != null:
return $default(_that.videoPath,_that.lensDirection,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String videoPath,  CameraLensDirection? lensDirection,  CapturedMediaSource source)  $default,) {final _that = this;
switch (_that) {
case _CapturedVideo():
return $default(_that.videoPath,_that.lensDirection,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String videoPath,  CameraLensDirection? lensDirection,  CapturedMediaSource source)?  $default,) {final _that = this;
switch (_that) {
case _CapturedVideo() when $default != null:
return $default(_that.videoPath,_that.lensDirection,_that.source);case _:
  return null;

}
}

}

/// @nodoc


class _CapturedVideo implements CapturedVideo {
  const _CapturedVideo({required this.videoPath, this.lensDirection, this.source = CapturedMediaSource.camera});
  

/// `CameraSession.stopRecording()` が返す動画一時ファイルのパス、
/// またはフォトライブラリから選択した動画のパス。
@override final  String videoPath;
/// 撮影時に選択されていたレンズ向き(フロント/バック)。フォトライブラリ由来の
/// 場合は該当する概念が無いため `null`。
@override final  CameraLensDirection? lensDirection;
/// カメラ撮影/フォトライブラリ選択のいずれに由来するか(既定はカメラ撮影)。
@override@JsonKey() final  CapturedMediaSource source;

/// Create a copy of CapturedVideo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CapturedVideoCopyWith<_CapturedVideo> get copyWith => __$CapturedVideoCopyWithImpl<_CapturedVideo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CapturedVideo&&(identical(other.videoPath, videoPath) || other.videoPath == videoPath)&&(identical(other.lensDirection, lensDirection) || other.lensDirection == lensDirection)&&(identical(other.source, source) || other.source == source));
}


@override
int get hashCode => Object.hash(runtimeType,videoPath,lensDirection,source);

@override
String toString() {
  return 'CapturedVideo(videoPath: $videoPath, lensDirection: $lensDirection, source: $source)';
}


}

/// @nodoc
abstract mixin class _$CapturedVideoCopyWith<$Res> implements $CapturedVideoCopyWith<$Res> {
  factory _$CapturedVideoCopyWith(_CapturedVideo value, $Res Function(_CapturedVideo) _then) = __$CapturedVideoCopyWithImpl;
@override @useResult
$Res call({
 String videoPath, CameraLensDirection? lensDirection, CapturedMediaSource source
});




}
/// @nodoc
class __$CapturedVideoCopyWithImpl<$Res>
    implements _$CapturedVideoCopyWith<$Res> {
  __$CapturedVideoCopyWithImpl(this._self, this._then);

  final _CapturedVideo _self;
  final $Res Function(_CapturedVideo) _then;

/// Create a copy of CapturedVideo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? videoPath = null,Object? lensDirection = freezed,Object? source = null,}) {
  return _then(_CapturedVideo(
videoPath: null == videoPath ? _self.videoPath : videoPath // ignore: cast_nullable_to_non_nullable
as String,lensDirection: freezed == lensDirection ? _self.lensDirection : lensDirection // ignore: cast_nullable_to_non_nullable
as CameraLensDirection?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as CapturedMediaSource,
  ));
}


}

// dart format on
