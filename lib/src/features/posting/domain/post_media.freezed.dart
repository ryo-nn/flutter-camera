// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_media.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostMedia {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostMedia);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PostMedia()';
}


}

/// @nodoc
class $PostMediaCopyWith<$Res>  {
$PostMediaCopyWith(PostMedia _, $Res Function(PostMedia) __);
}


/// Adds pattern-matching-related methods to [PostMedia].
extension PostMediaPatterns on PostMedia {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PostMediaImage value)?  image,TResult Function( PostMediaVideo value)?  video,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PostMediaImage() when image != null:
return image(_that);case PostMediaVideo() when video != null:
return video(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PostMediaImage value)  image,required TResult Function( PostMediaVideo value)  video,}){
final _that = this;
switch (_that) {
case PostMediaImage():
return image(_that);case PostMediaVideo():
return video(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PostMediaImage value)?  image,TResult? Function( PostMediaVideo value)?  video,}){
final _that = this;
switch (_that) {
case PostMediaImage() when image != null:
return image(_that);case PostMediaVideo() when video != null:
return video(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( EditedImage editedImage)?  image,TResult Function( String filePath,  double durationSec,  int fileSizeBytes,  String contentType)?  video,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PostMediaImage() when image != null:
return image(_that.editedImage);case PostMediaVideo() when video != null:
return video(_that.filePath,_that.durationSec,_that.fileSizeBytes,_that.contentType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( EditedImage editedImage)  image,required TResult Function( String filePath,  double durationSec,  int fileSizeBytes,  String contentType)  video,}) {final _that = this;
switch (_that) {
case PostMediaImage():
return image(_that.editedImage);case PostMediaVideo():
return video(_that.filePath,_that.durationSec,_that.fileSizeBytes,_that.contentType);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( EditedImage editedImage)?  image,TResult? Function( String filePath,  double durationSec,  int fileSizeBytes,  String contentType)?  video,}) {final _that = this;
switch (_that) {
case PostMediaImage() when image != null:
return image(_that.editedImage);case PostMediaVideo() when video != null:
return video(_that.filePath,_that.durationSec,_that.fileSizeBytes,_that.contentType);case _:
  return null;

}
}

}

/// @nodoc


class PostMediaImage implements PostMedia {
  const PostMediaImage(this.editedImage);
  

 final  EditedImage editedImage;

/// Create a copy of PostMedia
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostMediaImageCopyWith<PostMediaImage> get copyWith => _$PostMediaImageCopyWithImpl<PostMediaImage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostMediaImage&&(identical(other.editedImage, editedImage) || other.editedImage == editedImage));
}


@override
int get hashCode => Object.hash(runtimeType,editedImage);

@override
String toString() {
  return 'PostMedia.image(editedImage: $editedImage)';
}


}

/// @nodoc
abstract mixin class $PostMediaImageCopyWith<$Res> implements $PostMediaCopyWith<$Res> {
  factory $PostMediaImageCopyWith(PostMediaImage value, $Res Function(PostMediaImage) _then) = _$PostMediaImageCopyWithImpl;
@useResult
$Res call({
 EditedImage editedImage
});


$EditedImageCopyWith<$Res> get editedImage;

}
/// @nodoc
class _$PostMediaImageCopyWithImpl<$Res>
    implements $PostMediaImageCopyWith<$Res> {
  _$PostMediaImageCopyWithImpl(this._self, this._then);

  final PostMediaImage _self;
  final $Res Function(PostMediaImage) _then;

/// Create a copy of PostMedia
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? editedImage = null,}) {
  return _then(PostMediaImage(
null == editedImage ? _self.editedImage : editedImage // ignore: cast_nullable_to_non_nullable
as EditedImage,
  ));
}

/// Create a copy of PostMedia
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EditedImageCopyWith<$Res> get editedImage {
  
  return $EditedImageCopyWith<$Res>(_self.editedImage, (value) {
    return _then(_self.copyWith(editedImage: value));
  });
}
}

/// @nodoc


class PostMediaVideo implements PostMedia {
  const PostMediaVideo({required this.filePath, required this.durationSec, required this.fileSizeBytes, required this.contentType});
  

/// 動画ファイルの一時パス(S-05v表示に使用したものと同一)。
 final  String filePath;
/// 動画の長さ(秒。小数可。X投稿先バリデーションが0.5秒単位の下限を
/// 持つため `double` とする)。
 final  double durationSec;
/// 動画ファイルのバイト数(IG/X投稿先バリデーションに使用)。
 final  int fileSizeBytes;
/// 動画ファイルの実コンテナ形式に対応するStorage `contentType`
/// (`video/mp4` | `video/quicktime`)。ファイル拡張子から
/// [VideoContentType.fromFilePath] で判定した値をそのまま保持し、
/// アップロード時のcontentType申告・Xターゲットのゲーティング
/// (`VideoTargetRules`)双方で使用する(コードレビュー指摘
/// 「MOV動画のcontentType不整合」対応)。
 final  String contentType;

/// Create a copy of PostMedia
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostMediaVideoCopyWith<PostMediaVideo> get copyWith => _$PostMediaVideoCopyWithImpl<PostMediaVideo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostMediaVideo&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.durationSec, durationSec) || other.durationSec == durationSec)&&(identical(other.fileSizeBytes, fileSizeBytes) || other.fileSizeBytes == fileSizeBytes)&&(identical(other.contentType, contentType) || other.contentType == contentType));
}


@override
int get hashCode => Object.hash(runtimeType,filePath,durationSec,fileSizeBytes,contentType);

@override
String toString() {
  return 'PostMedia.video(filePath: $filePath, durationSec: $durationSec, fileSizeBytes: $fileSizeBytes, contentType: $contentType)';
}


}

/// @nodoc
abstract mixin class $PostMediaVideoCopyWith<$Res> implements $PostMediaCopyWith<$Res> {
  factory $PostMediaVideoCopyWith(PostMediaVideo value, $Res Function(PostMediaVideo) _then) = _$PostMediaVideoCopyWithImpl;
@useResult
$Res call({
 String filePath, double durationSec, int fileSizeBytes, String contentType
});




}
/// @nodoc
class _$PostMediaVideoCopyWithImpl<$Res>
    implements $PostMediaVideoCopyWith<$Res> {
  _$PostMediaVideoCopyWithImpl(this._self, this._then);

  final PostMediaVideo _self;
  final $Res Function(PostMediaVideo) _then;

/// Create a copy of PostMedia
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? filePath = null,Object? durationSec = null,Object? fileSizeBytes = null,Object? contentType = null,}) {
  return _then(PostMediaVideo(
filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,durationSec: null == durationSec ? _self.durationSec : durationSec // ignore: cast_nullable_to_non_nullable
as double,fileSizeBytes: null == fileSizeBytes ? _self.fileSizeBytes : fileSizeBytes // ignore: cast_nullable_to_non_nullable
as int,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
