// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Post {

 String get id; String get userId; String get imagePath; String get caption; String? get patternId;/// 投稿時点のパターン名スナップショット(retention章「posts/{postId}へのフィールド追加」節。
/// パターン削除・改名後もランキング表示を成立させるための非正規化)。
 String? get patternName; PostTarget get instagram; PostTarget get x; PostOverallStatus get overallStatus; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostCopyWith<Post> get copyWith => _$PostCopyWithImpl<Post>(this as Post, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Post&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.patternId, patternId) || other.patternId == patternId)&&(identical(other.patternName, patternName) || other.patternName == patternName)&&(identical(other.instagram, instagram) || other.instagram == instagram)&&(identical(other.x, x) || other.x == x)&&(identical(other.overallStatus, overallStatus) || other.overallStatus == overallStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,userId,imagePath,caption,patternId,patternName,instagram,x,overallStatus,createdAt,updatedAt);

@override
String toString() {
  return 'Post(id: $id, userId: $userId, imagePath: $imagePath, caption: $caption, patternId: $patternId, patternName: $patternName, instagram: $instagram, x: $x, overallStatus: $overallStatus, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PostCopyWith<$Res>  {
  factory $PostCopyWith(Post value, $Res Function(Post) _then) = _$PostCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String imagePath, String caption, String? patternId, String? patternName, PostTarget instagram, PostTarget x, PostOverallStatus overallStatus, DateTime createdAt, DateTime updatedAt
});


$PostTargetCopyWith<$Res> get instagram;$PostTargetCopyWith<$Res> get x;

}
/// @nodoc
class _$PostCopyWithImpl<$Res>
    implements $PostCopyWith<$Res> {
  _$PostCopyWithImpl(this._self, this._then);

  final Post _self;
  final $Res Function(Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? imagePath = null,Object? caption = null,Object? patternId = freezed,Object? patternName = freezed,Object? instagram = null,Object? x = null,Object? overallStatus = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,imagePath: null == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String,caption: null == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String,patternId: freezed == patternId ? _self.patternId : patternId // ignore: cast_nullable_to_non_nullable
as String?,patternName: freezed == patternName ? _self.patternName : patternName // ignore: cast_nullable_to_non_nullable
as String?,instagram: null == instagram ? _self.instagram : instagram // ignore: cast_nullable_to_non_nullable
as PostTarget,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as PostTarget,overallStatus: null == overallStatus ? _self.overallStatus : overallStatus // ignore: cast_nullable_to_non_nullable
as PostOverallStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostTargetCopyWith<$Res> get instagram {
  
  return $PostTargetCopyWith<$Res>(_self.instagram, (value) {
    return _then(_self.copyWith(instagram: value));
  });
}/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostTargetCopyWith<$Res> get x {
  
  return $PostTargetCopyWith<$Res>(_self.x, (value) {
    return _then(_self.copyWith(x: value));
  });
}
}


/// Adds pattern-matching-related methods to [Post].
extension PostPatterns on Post {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Post value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Post() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Post value)  $default,){
final _that = this;
switch (_that) {
case _Post():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Post value)?  $default,){
final _that = this;
switch (_that) {
case _Post() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String imagePath,  String caption,  String? patternId,  String? patternName,  PostTarget instagram,  PostTarget x,  PostOverallStatus overallStatus,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.id,_that.userId,_that.imagePath,_that.caption,_that.patternId,_that.patternName,_that.instagram,_that.x,_that.overallStatus,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String imagePath,  String caption,  String? patternId,  String? patternName,  PostTarget instagram,  PostTarget x,  PostOverallStatus overallStatus,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Post():
return $default(_that.id,_that.userId,_that.imagePath,_that.caption,_that.patternId,_that.patternName,_that.instagram,_that.x,_that.overallStatus,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String imagePath,  String caption,  String? patternId,  String? patternName,  PostTarget instagram,  PostTarget x,  PostOverallStatus overallStatus,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.id,_that.userId,_that.imagePath,_that.caption,_that.patternId,_that.patternName,_that.instagram,_that.x,_that.overallStatus,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Post extends Post {
  const _Post({required this.id, required this.userId, required this.imagePath, required this.caption, this.patternId, this.patternName, required this.instagram, required this.x, required this.overallStatus, required this.createdAt, required this.updatedAt}): super._();
  

@override final  String id;
@override final  String userId;
@override final  String imagePath;
@override final  String caption;
@override final  String? patternId;
/// 投稿時点のパターン名スナップショット(retention章「posts/{postId}へのフィールド追加」節。
/// パターン削除・改名後もランキング表示を成立させるための非正規化)。
@override final  String? patternName;
@override final  PostTarget instagram;
@override final  PostTarget x;
@override final  PostOverallStatus overallStatus;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostCopyWith<_Post> get copyWith => __$PostCopyWithImpl<_Post>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Post&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.patternId, patternId) || other.patternId == patternId)&&(identical(other.patternName, patternName) || other.patternName == patternName)&&(identical(other.instagram, instagram) || other.instagram == instagram)&&(identical(other.x, x) || other.x == x)&&(identical(other.overallStatus, overallStatus) || other.overallStatus == overallStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,userId,imagePath,caption,patternId,patternName,instagram,x,overallStatus,createdAt,updatedAt);

@override
String toString() {
  return 'Post(id: $id, userId: $userId, imagePath: $imagePath, caption: $caption, patternId: $patternId, patternName: $patternName, instagram: $instagram, x: $x, overallStatus: $overallStatus, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PostCopyWith<$Res> implements $PostCopyWith<$Res> {
  factory _$PostCopyWith(_Post value, $Res Function(_Post) _then) = __$PostCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String imagePath, String caption, String? patternId, String? patternName, PostTarget instagram, PostTarget x, PostOverallStatus overallStatus, DateTime createdAt, DateTime updatedAt
});


@override $PostTargetCopyWith<$Res> get instagram;@override $PostTargetCopyWith<$Res> get x;

}
/// @nodoc
class __$PostCopyWithImpl<$Res>
    implements _$PostCopyWith<$Res> {
  __$PostCopyWithImpl(this._self, this._then);

  final _Post _self;
  final $Res Function(_Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? imagePath = null,Object? caption = null,Object? patternId = freezed,Object? patternName = freezed,Object? instagram = null,Object? x = null,Object? overallStatus = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Post(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,imagePath: null == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String,caption: null == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String,patternId: freezed == patternId ? _self.patternId : patternId // ignore: cast_nullable_to_non_nullable
as String?,patternName: freezed == patternName ? _self.patternName : patternName // ignore: cast_nullable_to_non_nullable
as String?,instagram: null == instagram ? _self.instagram : instagram // ignore: cast_nullable_to_non_nullable
as PostTarget,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as PostTarget,overallStatus: null == overallStatus ? _self.overallStatus : overallStatus // ignore: cast_nullable_to_non_nullable
as PostOverallStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostTargetCopyWith<$Res> get instagram {
  
  return $PostTargetCopyWith<$Res>(_self.instagram, (value) {
    return _then(_self.copyWith(instagram: value));
  });
}/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostTargetCopyWith<$Res> get x {
  
  return $PostTargetCopyWith<$Res>(_self.x, (value) {
    return _then(_self.copyWith(x: value));
  });
}
}

/// @nodoc
mixin _$PostTarget {

 SnsProvider get provider; bool get selected; PostTargetStatus get status; PostTargetFailureKind? get failureKind;/// backend章「onCallエラーコード一覧」+ quota/retention章追加分の
/// 小文字スネークケースコード(例: 'x_quota_exceeded' 等)。
 String? get errorCode; String? get errorMessage; String? get publishedId; DateTime? get postedAt;/// Xターゲットのみ設定される(quota章「Firestoreデータ設計の拡張」節準拠)。
 XQuotaSource? get quotaSource; bool get quotaRefunded;/// Instagramターゲットのみ設定される
/// (retention章「Instagramフェアユース上限」節。`quotaIg.ts` 実装準拠)。
 bool get fairUseRefunded;
/// Create a copy of PostTarget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostTargetCopyWith<PostTarget> get copyWith => _$PostTargetCopyWithImpl<PostTarget>(this as PostTarget, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostTarget&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.selected, selected) || other.selected == selected)&&(identical(other.status, status) || other.status == status)&&(identical(other.failureKind, failureKind) || other.failureKind == failureKind)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.publishedId, publishedId) || other.publishedId == publishedId)&&(identical(other.postedAt, postedAt) || other.postedAt == postedAt)&&(identical(other.quotaSource, quotaSource) || other.quotaSource == quotaSource)&&(identical(other.quotaRefunded, quotaRefunded) || other.quotaRefunded == quotaRefunded)&&(identical(other.fairUseRefunded, fairUseRefunded) || other.fairUseRefunded == fairUseRefunded));
}


@override
int get hashCode => Object.hash(runtimeType,provider,selected,status,failureKind,errorCode,errorMessage,publishedId,postedAt,quotaSource,quotaRefunded,fairUseRefunded);

@override
String toString() {
  return 'PostTarget(provider: $provider, selected: $selected, status: $status, failureKind: $failureKind, errorCode: $errorCode, errorMessage: $errorMessage, publishedId: $publishedId, postedAt: $postedAt, quotaSource: $quotaSource, quotaRefunded: $quotaRefunded, fairUseRefunded: $fairUseRefunded)';
}


}

/// @nodoc
abstract mixin class $PostTargetCopyWith<$Res>  {
  factory $PostTargetCopyWith(PostTarget value, $Res Function(PostTarget) _then) = _$PostTargetCopyWithImpl;
@useResult
$Res call({
 SnsProvider provider, bool selected, PostTargetStatus status, PostTargetFailureKind? failureKind, String? errorCode, String? errorMessage, String? publishedId, DateTime? postedAt, XQuotaSource? quotaSource, bool quotaRefunded, bool fairUseRefunded
});




}
/// @nodoc
class _$PostTargetCopyWithImpl<$Res>
    implements $PostTargetCopyWith<$Res> {
  _$PostTargetCopyWithImpl(this._self, this._then);

  final PostTarget _self;
  final $Res Function(PostTarget) _then;

/// Create a copy of PostTarget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? provider = null,Object? selected = null,Object? status = null,Object? failureKind = freezed,Object? errorCode = freezed,Object? errorMessage = freezed,Object? publishedId = freezed,Object? postedAt = freezed,Object? quotaSource = freezed,Object? quotaRefunded = null,Object? fairUseRefunded = null,}) {
  return _then(_self.copyWith(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as SnsProvider,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PostTargetStatus,failureKind: freezed == failureKind ? _self.failureKind : failureKind // ignore: cast_nullable_to_non_nullable
as PostTargetFailureKind?,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,publishedId: freezed == publishedId ? _self.publishedId : publishedId // ignore: cast_nullable_to_non_nullable
as String?,postedAt: freezed == postedAt ? _self.postedAt : postedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,quotaSource: freezed == quotaSource ? _self.quotaSource : quotaSource // ignore: cast_nullable_to_non_nullable
as XQuotaSource?,quotaRefunded: null == quotaRefunded ? _self.quotaRefunded : quotaRefunded // ignore: cast_nullable_to_non_nullable
as bool,fairUseRefunded: null == fairUseRefunded ? _self.fairUseRefunded : fairUseRefunded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PostTarget].
extension PostTargetPatterns on PostTarget {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostTarget value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostTarget() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostTarget value)  $default,){
final _that = this;
switch (_that) {
case _PostTarget():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostTarget value)?  $default,){
final _that = this;
switch (_that) {
case _PostTarget() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SnsProvider provider,  bool selected,  PostTargetStatus status,  PostTargetFailureKind? failureKind,  String? errorCode,  String? errorMessage,  String? publishedId,  DateTime? postedAt,  XQuotaSource? quotaSource,  bool quotaRefunded,  bool fairUseRefunded)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostTarget() when $default != null:
return $default(_that.provider,_that.selected,_that.status,_that.failureKind,_that.errorCode,_that.errorMessage,_that.publishedId,_that.postedAt,_that.quotaSource,_that.quotaRefunded,_that.fairUseRefunded);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SnsProvider provider,  bool selected,  PostTargetStatus status,  PostTargetFailureKind? failureKind,  String? errorCode,  String? errorMessage,  String? publishedId,  DateTime? postedAt,  XQuotaSource? quotaSource,  bool quotaRefunded,  bool fairUseRefunded)  $default,) {final _that = this;
switch (_that) {
case _PostTarget():
return $default(_that.provider,_that.selected,_that.status,_that.failureKind,_that.errorCode,_that.errorMessage,_that.publishedId,_that.postedAt,_that.quotaSource,_that.quotaRefunded,_that.fairUseRefunded);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SnsProvider provider,  bool selected,  PostTargetStatus status,  PostTargetFailureKind? failureKind,  String? errorCode,  String? errorMessage,  String? publishedId,  DateTime? postedAt,  XQuotaSource? quotaSource,  bool quotaRefunded,  bool fairUseRefunded)?  $default,) {final _that = this;
switch (_that) {
case _PostTarget() when $default != null:
return $default(_that.provider,_that.selected,_that.status,_that.failureKind,_that.errorCode,_that.errorMessage,_that.publishedId,_that.postedAt,_that.quotaSource,_that.quotaRefunded,_that.fairUseRefunded);case _:
  return null;

}
}

}

/// @nodoc


class _PostTarget extends PostTarget {
  const _PostTarget({required this.provider, required this.selected, required this.status, this.failureKind, this.errorCode, this.errorMessage, this.publishedId, this.postedAt, this.quotaSource, this.quotaRefunded = false, this.fairUseRefunded = false}): super._();
  

@override final  SnsProvider provider;
@override final  bool selected;
@override final  PostTargetStatus status;
@override final  PostTargetFailureKind? failureKind;
/// backend章「onCallエラーコード一覧」+ quota/retention章追加分の
/// 小文字スネークケースコード(例: 'x_quota_exceeded' 等)。
@override final  String? errorCode;
@override final  String? errorMessage;
@override final  String? publishedId;
@override final  DateTime? postedAt;
/// Xターゲットのみ設定される(quota章「Firestoreデータ設計の拡張」節準拠)。
@override final  XQuotaSource? quotaSource;
@override@JsonKey() final  bool quotaRefunded;
/// Instagramターゲットのみ設定される
/// (retention章「Instagramフェアユース上限」節。`quotaIg.ts` 実装準拠)。
@override@JsonKey() final  bool fairUseRefunded;

/// Create a copy of PostTarget
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostTargetCopyWith<_PostTarget> get copyWith => __$PostTargetCopyWithImpl<_PostTarget>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostTarget&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.selected, selected) || other.selected == selected)&&(identical(other.status, status) || other.status == status)&&(identical(other.failureKind, failureKind) || other.failureKind == failureKind)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.publishedId, publishedId) || other.publishedId == publishedId)&&(identical(other.postedAt, postedAt) || other.postedAt == postedAt)&&(identical(other.quotaSource, quotaSource) || other.quotaSource == quotaSource)&&(identical(other.quotaRefunded, quotaRefunded) || other.quotaRefunded == quotaRefunded)&&(identical(other.fairUseRefunded, fairUseRefunded) || other.fairUseRefunded == fairUseRefunded));
}


@override
int get hashCode => Object.hash(runtimeType,provider,selected,status,failureKind,errorCode,errorMessage,publishedId,postedAt,quotaSource,quotaRefunded,fairUseRefunded);

@override
String toString() {
  return 'PostTarget(provider: $provider, selected: $selected, status: $status, failureKind: $failureKind, errorCode: $errorCode, errorMessage: $errorMessage, publishedId: $publishedId, postedAt: $postedAt, quotaSource: $quotaSource, quotaRefunded: $quotaRefunded, fairUseRefunded: $fairUseRefunded)';
}


}

/// @nodoc
abstract mixin class _$PostTargetCopyWith<$Res> implements $PostTargetCopyWith<$Res> {
  factory _$PostTargetCopyWith(_PostTarget value, $Res Function(_PostTarget) _then) = __$PostTargetCopyWithImpl;
@override @useResult
$Res call({
 SnsProvider provider, bool selected, PostTargetStatus status, PostTargetFailureKind? failureKind, String? errorCode, String? errorMessage, String? publishedId, DateTime? postedAt, XQuotaSource? quotaSource, bool quotaRefunded, bool fairUseRefunded
});




}
/// @nodoc
class __$PostTargetCopyWithImpl<$Res>
    implements _$PostTargetCopyWith<$Res> {
  __$PostTargetCopyWithImpl(this._self, this._then);

  final _PostTarget _self;
  final $Res Function(_PostTarget) _then;

/// Create a copy of PostTarget
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? provider = null,Object? selected = null,Object? status = null,Object? failureKind = freezed,Object? errorCode = freezed,Object? errorMessage = freezed,Object? publishedId = freezed,Object? postedAt = freezed,Object? quotaSource = freezed,Object? quotaRefunded = null,Object? fairUseRefunded = null,}) {
  return _then(_PostTarget(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as SnsProvider,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PostTargetStatus,failureKind: freezed == failureKind ? _self.failureKind : failureKind // ignore: cast_nullable_to_non_nullable
as PostTargetFailureKind?,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,publishedId: freezed == publishedId ? _self.publishedId : publishedId // ignore: cast_nullable_to_non_nullable
as String?,postedAt: freezed == postedAt ? _self.postedAt : postedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,quotaSource: freezed == quotaSource ? _self.quotaSource : quotaSource // ignore: cast_nullable_to_non_nullable
as XQuotaSource?,quotaRefunded: null == quotaRefunded ? _self.quotaRefunded : quotaRefunded // ignore: cast_nullable_to_non_nullable
as bool,fairUseRefunded: null == fairUseRefunded ? _self.fairUseRefunded : fairUseRefunded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
