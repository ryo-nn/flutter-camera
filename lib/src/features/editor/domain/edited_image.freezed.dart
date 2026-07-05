// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'edited_image.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EditedImage {

 String get filePath; bool get isFinal;
/// Create a copy of EditedImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditedImageCopyWith<EditedImage> get copyWith => _$EditedImageCopyWithImpl<EditedImage>(this as EditedImage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditedImage&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.isFinal, isFinal) || other.isFinal == isFinal));
}


@override
int get hashCode => Object.hash(runtimeType,filePath,isFinal);

@override
String toString() {
  return 'EditedImage(filePath: $filePath, isFinal: $isFinal)';
}


}

/// @nodoc
abstract mixin class $EditedImageCopyWith<$Res>  {
  factory $EditedImageCopyWith(EditedImage value, $Res Function(EditedImage) _then) = _$EditedImageCopyWithImpl;
@useResult
$Res call({
 String filePath, bool isFinal
});




}
/// @nodoc
class _$EditedImageCopyWithImpl<$Res>
    implements $EditedImageCopyWith<$Res> {
  _$EditedImageCopyWithImpl(this._self, this._then);

  final EditedImage _self;
  final $Res Function(EditedImage) _then;

/// Create a copy of EditedImage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? filePath = null,Object? isFinal = null,}) {
  return _then(_self.copyWith(
filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,isFinal: null == isFinal ? _self.isFinal : isFinal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [EditedImage].
extension EditedImagePatterns on EditedImage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EditedImage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EditedImage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EditedImage value)  $default,){
final _that = this;
switch (_that) {
case _EditedImage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EditedImage value)?  $default,){
final _that = this;
switch (_that) {
case _EditedImage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String filePath,  bool isFinal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EditedImage() when $default != null:
return $default(_that.filePath,_that.isFinal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String filePath,  bool isFinal)  $default,) {final _that = this;
switch (_that) {
case _EditedImage():
return $default(_that.filePath,_that.isFinal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String filePath,  bool isFinal)?  $default,) {final _that = this;
switch (_that) {
case _EditedImage() when $default != null:
return $default(_that.filePath,_that.isFinal);case _:
  return null;

}
}

}

/// @nodoc


class _EditedImage implements EditedImage {
  const _EditedImage({required this.filePath, required this.isFinal});
  

@override final  String filePath;
@override final  bool isFinal;

/// Create a copy of EditedImage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditedImageCopyWith<_EditedImage> get copyWith => __$EditedImageCopyWithImpl<_EditedImage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EditedImage&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.isFinal, isFinal) || other.isFinal == isFinal));
}


@override
int get hashCode => Object.hash(runtimeType,filePath,isFinal);

@override
String toString() {
  return 'EditedImage(filePath: $filePath, isFinal: $isFinal)';
}


}

/// @nodoc
abstract mixin class _$EditedImageCopyWith<$Res> implements $EditedImageCopyWith<$Res> {
  factory _$EditedImageCopyWith(_EditedImage value, $Res Function(_EditedImage) _then) = __$EditedImageCopyWithImpl;
@override @useResult
$Res call({
 String filePath, bool isFinal
});




}
/// @nodoc
class __$EditedImageCopyWithImpl<$Res>
    implements _$EditedImageCopyWith<$Res> {
  __$EditedImageCopyWithImpl(this._self, this._then);

  final _EditedImage _self;
  final $Res Function(_EditedImage) _then;

/// Create a copy of EditedImage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? filePath = null,Object? isFinal = null,}) {
  return _then(_EditedImage(
filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,isFinal: null == isFinal ? _self.isFinal : isFinal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
