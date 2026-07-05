// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_grant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OnboardingGrant {

 String get uid;@TimestampConverter() DateTime get firstPostUsedAt; String get firstPostId;@TimestampConverter() DateTime get updatedAt;
/// Create a copy of OnboardingGrant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingGrantCopyWith<OnboardingGrant> get copyWith => _$OnboardingGrantCopyWithImpl<OnboardingGrant>(this as OnboardingGrant, _$identity);

  /// Serializes this OnboardingGrant to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingGrant&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.firstPostUsedAt, firstPostUsedAt) || other.firstPostUsedAt == firstPostUsedAt)&&(identical(other.firstPostId, firstPostId) || other.firstPostId == firstPostId)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,firstPostUsedAt,firstPostId,updatedAt);

@override
String toString() {
  return 'OnboardingGrant(uid: $uid, firstPostUsedAt: $firstPostUsedAt, firstPostId: $firstPostId, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $OnboardingGrantCopyWith<$Res>  {
  factory $OnboardingGrantCopyWith(OnboardingGrant value, $Res Function(OnboardingGrant) _then) = _$OnboardingGrantCopyWithImpl;
@useResult
$Res call({
 String uid,@TimestampConverter() DateTime firstPostUsedAt, String firstPostId,@TimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class _$OnboardingGrantCopyWithImpl<$Res>
    implements $OnboardingGrantCopyWith<$Res> {
  _$OnboardingGrantCopyWithImpl(this._self, this._then);

  final OnboardingGrant _self;
  final $Res Function(OnboardingGrant) _then;

/// Create a copy of OnboardingGrant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? firstPostUsedAt = null,Object? firstPostId = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,firstPostUsedAt: null == firstPostUsedAt ? _self.firstPostUsedAt : firstPostUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime,firstPostId: null == firstPostId ? _self.firstPostId : firstPostId // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingGrant].
extension OnboardingGrantPatterns on OnboardingGrant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingGrant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingGrant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingGrant value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingGrant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingGrant value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingGrant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid, @TimestampConverter()  DateTime firstPostUsedAt,  String firstPostId, @TimestampConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingGrant() when $default != null:
return $default(_that.uid,_that.firstPostUsedAt,_that.firstPostId,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid, @TimestampConverter()  DateTime firstPostUsedAt,  String firstPostId, @TimestampConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _OnboardingGrant():
return $default(_that.uid,_that.firstPostUsedAt,_that.firstPostId,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid, @TimestampConverter()  DateTime firstPostUsedAt,  String firstPostId, @TimestampConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingGrant() when $default != null:
return $default(_that.uid,_that.firstPostUsedAt,_that.firstPostId,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OnboardingGrant implements OnboardingGrant {
  const _OnboardingGrant({required this.uid, @TimestampConverter() required this.firstPostUsedAt, required this.firstPostId, @TimestampConverter() required this.updatedAt});
  factory _OnboardingGrant.fromJson(Map<String, dynamic> json) => _$OnboardingGrantFromJson(json);

@override final  String uid;
@override@TimestampConverter() final  DateTime firstPostUsedAt;
@override final  String firstPostId;
@override@TimestampConverter() final  DateTime updatedAt;

/// Create a copy of OnboardingGrant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingGrantCopyWith<_OnboardingGrant> get copyWith => __$OnboardingGrantCopyWithImpl<_OnboardingGrant>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OnboardingGrantToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingGrant&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.firstPostUsedAt, firstPostUsedAt) || other.firstPostUsedAt == firstPostUsedAt)&&(identical(other.firstPostId, firstPostId) || other.firstPostId == firstPostId)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,firstPostUsedAt,firstPostId,updatedAt);

@override
String toString() {
  return 'OnboardingGrant(uid: $uid, firstPostUsedAt: $firstPostUsedAt, firstPostId: $firstPostId, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$OnboardingGrantCopyWith<$Res> implements $OnboardingGrantCopyWith<$Res> {
  factory _$OnboardingGrantCopyWith(_OnboardingGrant value, $Res Function(_OnboardingGrant) _then) = __$OnboardingGrantCopyWithImpl;
@override @useResult
$Res call({
 String uid,@TimestampConverter() DateTime firstPostUsedAt, String firstPostId,@TimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class __$OnboardingGrantCopyWithImpl<$Res>
    implements _$OnboardingGrantCopyWith<$Res> {
  __$OnboardingGrantCopyWithImpl(this._self, this._then);

  final _OnboardingGrant _self;
  final $Res Function(_OnboardingGrant) _then;

/// Create a copy of OnboardingGrant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? firstPostUsedAt = null,Object? firstPostId = null,Object? updatedAt = null,}) {
  return _then(_OnboardingGrant(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,firstPostUsedAt: null == firstPostUsedAt ? _self.firstPostUsedAt : firstPostUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime,firstPostId: null == firstPostId ? _self.firstPostId : firstPostId // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
