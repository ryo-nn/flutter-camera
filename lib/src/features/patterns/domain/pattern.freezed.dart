// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pattern.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Pattern {

/// ドキュメントID(Firestoreには保存しない。読み取り時に付与)
@JsonKey(includeToJson: false) String get id; PatternOwnerType get ownerType;/// プリセットの場合は null
 String? get ownerUid; String get name; FilterParams get filterParams;/// フレーム素材のアセットID(`assets/{assetId}` のドキュメントID)。
/// フレームなしは null
 String? get frameAssetId;/// スタンプレイヤー(最大10件。配列順 = 重ね順)
 List<StampLayer> get stampLayers;/// プリセットの表示順。ユーザー作成は0固定
 int get sortOrder;/// Pro限定パターン(要件§3.2)。`ownerType: preset` のみ true になり得る。
/// ユーザー作成パターンでは常に false(リテンション機能設計章準拠。
/// Rulesの `hasOnly` / `affectedKeys().hasOnly` に含まれないためクライアントは
/// 書き込めない)
 bool get isPremium;/// 公式パターンの配信日時(NEWバッジ表示用)。ユーザー作成は null
/// (リテンション機能設計章準拠)
@NullableTimestampConverter() DateTime? get publishedAt;@TimestampConverter() DateTime get createdAt;@TimestampConverter() DateTime get updatedAt;
/// Create a copy of Pattern
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PatternCopyWith<Pattern> get copyWith => _$PatternCopyWithImpl<Pattern>(this as Pattern, _$identity);

  /// Serializes this Pattern to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Pattern&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerType, ownerType) || other.ownerType == ownerType)&&(identical(other.ownerUid, ownerUid) || other.ownerUid == ownerUid)&&(identical(other.name, name) || other.name == name)&&(identical(other.filterParams, filterParams) || other.filterParams == filterParams)&&(identical(other.frameAssetId, frameAssetId) || other.frameAssetId == frameAssetId)&&const DeepCollectionEquality().equals(other.stampLayers, stampLayers)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerType,ownerUid,name,filterParams,frameAssetId,const DeepCollectionEquality().hash(stampLayers),sortOrder,isPremium,publishedAt,createdAt,updatedAt);

@override
String toString() {
  return 'Pattern(id: $id, ownerType: $ownerType, ownerUid: $ownerUid, name: $name, filterParams: $filterParams, frameAssetId: $frameAssetId, stampLayers: $stampLayers, sortOrder: $sortOrder, isPremium: $isPremium, publishedAt: $publishedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PatternCopyWith<$Res>  {
  factory $PatternCopyWith(Pattern value, $Res Function(Pattern) _then) = _$PatternCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String id, PatternOwnerType ownerType, String? ownerUid, String name, FilterParams filterParams, String? frameAssetId, List<StampLayer> stampLayers, int sortOrder, bool isPremium,@NullableTimestampConverter() DateTime? publishedAt,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});


$FilterParamsCopyWith<$Res> get filterParams;

}
/// @nodoc
class _$PatternCopyWithImpl<$Res>
    implements $PatternCopyWith<$Res> {
  _$PatternCopyWithImpl(this._self, this._then);

  final Pattern _self;
  final $Res Function(Pattern) _then;

/// Create a copy of Pattern
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerType = null,Object? ownerUid = freezed,Object? name = null,Object? filterParams = null,Object? frameAssetId = freezed,Object? stampLayers = null,Object? sortOrder = null,Object? isPremium = null,Object? publishedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerType: null == ownerType ? _self.ownerType : ownerType // ignore: cast_nullable_to_non_nullable
as PatternOwnerType,ownerUid: freezed == ownerUid ? _self.ownerUid : ownerUid // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,filterParams: null == filterParams ? _self.filterParams : filterParams // ignore: cast_nullable_to_non_nullable
as FilterParams,frameAssetId: freezed == frameAssetId ? _self.frameAssetId : frameAssetId // ignore: cast_nullable_to_non_nullable
as String?,stampLayers: null == stampLayers ? _self.stampLayers : stampLayers // ignore: cast_nullable_to_non_nullable
as List<StampLayer>,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of Pattern
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FilterParamsCopyWith<$Res> get filterParams {
  
  return $FilterParamsCopyWith<$Res>(_self.filterParams, (value) {
    return _then(_self.copyWith(filterParams: value));
  });
}
}


/// Adds pattern-matching-related methods to [Pattern].
extension PatternPatterns on Pattern {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Pattern value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Pattern() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Pattern value)  $default,){
final _that = this;
switch (_that) {
case _Pattern():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Pattern value)?  $default,){
final _that = this;
switch (_that) {
case _Pattern() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  PatternOwnerType ownerType,  String? ownerUid,  String name,  FilterParams filterParams,  String? frameAssetId,  List<StampLayer> stampLayers,  int sortOrder,  bool isPremium, @NullableTimestampConverter()  DateTime? publishedAt, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Pattern() when $default != null:
return $default(_that.id,_that.ownerType,_that.ownerUid,_that.name,_that.filterParams,_that.frameAssetId,_that.stampLayers,_that.sortOrder,_that.isPremium,_that.publishedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  PatternOwnerType ownerType,  String? ownerUid,  String name,  FilterParams filterParams,  String? frameAssetId,  List<StampLayer> stampLayers,  int sortOrder,  bool isPremium, @NullableTimestampConverter()  DateTime? publishedAt, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Pattern():
return $default(_that.id,_that.ownerType,_that.ownerUid,_that.name,_that.filterParams,_that.frameAssetId,_that.stampLayers,_that.sortOrder,_that.isPremium,_that.publishedAt,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String id,  PatternOwnerType ownerType,  String? ownerUid,  String name,  FilterParams filterParams,  String? frameAssetId,  List<StampLayer> stampLayers,  int sortOrder,  bool isPremium, @NullableTimestampConverter()  DateTime? publishedAt, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Pattern() when $default != null:
return $default(_that.id,_that.ownerType,_that.ownerUid,_that.name,_that.filterParams,_that.frameAssetId,_that.stampLayers,_that.sortOrder,_that.isPremium,_that.publishedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Pattern implements Pattern {
  const _Pattern({@JsonKey(includeToJson: false) required this.id, required this.ownerType, this.ownerUid, required this.name, required this.filterParams, this.frameAssetId, final  List<StampLayer> stampLayers = const <StampLayer>[], this.sortOrder = 0, this.isPremium = false, @NullableTimestampConverter() this.publishedAt, @TimestampConverter() required this.createdAt, @TimestampConverter() required this.updatedAt}): _stampLayers = stampLayers;
  factory _Pattern.fromJson(Map<String, dynamic> json) => _$PatternFromJson(json);

/// ドキュメントID(Firestoreには保存しない。読み取り時に付与)
@override@JsonKey(includeToJson: false) final  String id;
@override final  PatternOwnerType ownerType;
/// プリセットの場合は null
@override final  String? ownerUid;
@override final  String name;
@override final  FilterParams filterParams;
/// フレーム素材のアセットID(`assets/{assetId}` のドキュメントID)。
/// フレームなしは null
@override final  String? frameAssetId;
/// スタンプレイヤー(最大10件。配列順 = 重ね順)
 final  List<StampLayer> _stampLayers;
/// スタンプレイヤー(最大10件。配列順 = 重ね順)
@override@JsonKey() List<StampLayer> get stampLayers {
  if (_stampLayers is EqualUnmodifiableListView) return _stampLayers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stampLayers);
}

/// プリセットの表示順。ユーザー作成は0固定
@override@JsonKey() final  int sortOrder;
/// Pro限定パターン(要件§3.2)。`ownerType: preset` のみ true になり得る。
/// ユーザー作成パターンでは常に false(リテンション機能設計章準拠。
/// Rulesの `hasOnly` / `affectedKeys().hasOnly` に含まれないためクライアントは
/// 書き込めない)
@override@JsonKey() final  bool isPremium;
/// 公式パターンの配信日時(NEWバッジ表示用)。ユーザー作成は null
/// (リテンション機能設計章準拠)
@override@NullableTimestampConverter() final  DateTime? publishedAt;
@override@TimestampConverter() final  DateTime createdAt;
@override@TimestampConverter() final  DateTime updatedAt;

/// Create a copy of Pattern
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PatternCopyWith<_Pattern> get copyWith => __$PatternCopyWithImpl<_Pattern>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PatternToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Pattern&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerType, ownerType) || other.ownerType == ownerType)&&(identical(other.ownerUid, ownerUid) || other.ownerUid == ownerUid)&&(identical(other.name, name) || other.name == name)&&(identical(other.filterParams, filterParams) || other.filterParams == filterParams)&&(identical(other.frameAssetId, frameAssetId) || other.frameAssetId == frameAssetId)&&const DeepCollectionEquality().equals(other._stampLayers, _stampLayers)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerType,ownerUid,name,filterParams,frameAssetId,const DeepCollectionEquality().hash(_stampLayers),sortOrder,isPremium,publishedAt,createdAt,updatedAt);

@override
String toString() {
  return 'Pattern(id: $id, ownerType: $ownerType, ownerUid: $ownerUid, name: $name, filterParams: $filterParams, frameAssetId: $frameAssetId, stampLayers: $stampLayers, sortOrder: $sortOrder, isPremium: $isPremium, publishedAt: $publishedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PatternCopyWith<$Res> implements $PatternCopyWith<$Res> {
  factory _$PatternCopyWith(_Pattern value, $Res Function(_Pattern) _then) = __$PatternCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String id, PatternOwnerType ownerType, String? ownerUid, String name, FilterParams filterParams, String? frameAssetId, List<StampLayer> stampLayers, int sortOrder, bool isPremium,@NullableTimestampConverter() DateTime? publishedAt,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});


@override $FilterParamsCopyWith<$Res> get filterParams;

}
/// @nodoc
class __$PatternCopyWithImpl<$Res>
    implements _$PatternCopyWith<$Res> {
  __$PatternCopyWithImpl(this._self, this._then);

  final _Pattern _self;
  final $Res Function(_Pattern) _then;

/// Create a copy of Pattern
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerType = null,Object? ownerUid = freezed,Object? name = null,Object? filterParams = null,Object? frameAssetId = freezed,Object? stampLayers = null,Object? sortOrder = null,Object? isPremium = null,Object? publishedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Pattern(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerType: null == ownerType ? _self.ownerType : ownerType // ignore: cast_nullable_to_non_nullable
as PatternOwnerType,ownerUid: freezed == ownerUid ? _self.ownerUid : ownerUid // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,filterParams: null == filterParams ? _self.filterParams : filterParams // ignore: cast_nullable_to_non_nullable
as FilterParams,frameAssetId: freezed == frameAssetId ? _self.frameAssetId : frameAssetId // ignore: cast_nullable_to_non_nullable
as String?,stampLayers: null == stampLayers ? _self._stampLayers : stampLayers // ignore: cast_nullable_to_non_nullable
as List<StampLayer>,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of Pattern
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FilterParamsCopyWith<$Res> get filterParams {
  
  return $FilterParamsCopyWith<$Res>(_self.filterParams, (value) {
    return _then(_self.copyWith(filterParams: value));
  });
}
}

// dart format on
