// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'billing_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BillingState {

 Plan get plan; bool get isTrial; String? get planProductId;/// 現エンタイトルメントの失効日時(RC `expires_date`。グレースピリオド中は
/// `grace_period_expires_date`)。プラン解決規則2(読み取り時失効ガード)の
/// 判定に使用する([resolvedPlan] 参照)。
@NullableTimestampConverter() DateTime? get planExpiresAt;/// 購入クレジット残高(無期限。加算=rcWebhook、減算=quota消費トランザクション
/// と返金処理のみ)。
 int get postCredits;@NullableTimestampConverter() DateTime? get updatedAt;
/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillingStateCopyWith<BillingState> get copyWith => _$BillingStateCopyWithImpl<BillingState>(this as BillingState, _$identity);

  /// Serializes this BillingState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingState&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.isTrial, isTrial) || other.isTrial == isTrial)&&(identical(other.planProductId, planProductId) || other.planProductId == planProductId)&&(identical(other.planExpiresAt, planExpiresAt) || other.planExpiresAt == planExpiresAt)&&(identical(other.postCredits, postCredits) || other.postCredits == postCredits)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,plan,isTrial,planProductId,planExpiresAt,postCredits,updatedAt);

@override
String toString() {
  return 'BillingState(plan: $plan, isTrial: $isTrial, planProductId: $planProductId, planExpiresAt: $planExpiresAt, postCredits: $postCredits, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $BillingStateCopyWith<$Res>  {
  factory $BillingStateCopyWith(BillingState value, $Res Function(BillingState) _then) = _$BillingStateCopyWithImpl;
@useResult
$Res call({
 Plan plan, bool isTrial, String? planProductId,@NullableTimestampConverter() DateTime? planExpiresAt, int postCredits,@NullableTimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$BillingStateCopyWithImpl<$Res>
    implements $BillingStateCopyWith<$Res> {
  _$BillingStateCopyWithImpl(this._self, this._then);

  final BillingState _self;
  final $Res Function(BillingState) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? plan = null,Object? isTrial = null,Object? planProductId = freezed,Object? planExpiresAt = freezed,Object? postCredits = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as Plan,isTrial: null == isTrial ? _self.isTrial : isTrial // ignore: cast_nullable_to_non_nullable
as bool,planProductId: freezed == planProductId ? _self.planProductId : planProductId // ignore: cast_nullable_to_non_nullable
as String?,planExpiresAt: freezed == planExpiresAt ? _self.planExpiresAt : planExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,postCredits: null == postCredits ? _self.postCredits : postCredits // ignore: cast_nullable_to_non_nullable
as int,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [BillingState].
extension BillingStatePatterns on BillingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillingState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillingState value)  $default,){
final _that = this;
switch (_that) {
case _BillingState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillingState value)?  $default,){
final _that = this;
switch (_that) {
case _BillingState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Plan plan,  bool isTrial,  String? planProductId, @NullableTimestampConverter()  DateTime? planExpiresAt,  int postCredits, @NullableTimestampConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillingState() when $default != null:
return $default(_that.plan,_that.isTrial,_that.planProductId,_that.planExpiresAt,_that.postCredits,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Plan plan,  bool isTrial,  String? planProductId, @NullableTimestampConverter()  DateTime? planExpiresAt,  int postCredits, @NullableTimestampConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _BillingState():
return $default(_that.plan,_that.isTrial,_that.planProductId,_that.planExpiresAt,_that.postCredits,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Plan plan,  bool isTrial,  String? planProductId, @NullableTimestampConverter()  DateTime? planExpiresAt,  int postCredits, @NullableTimestampConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _BillingState() when $default != null:
return $default(_that.plan,_that.isTrial,_that.planProductId,_that.planExpiresAt,_that.postCredits,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BillingState extends BillingState {
  const _BillingState({this.plan = Plan.free, this.isTrial = false, this.planProductId, @NullableTimestampConverter() this.planExpiresAt, this.postCredits = 0, @NullableTimestampConverter() this.updatedAt}): super._();
  factory _BillingState.fromJson(Map<String, dynamic> json) => _$BillingStateFromJson(json);

@override@JsonKey() final  Plan plan;
@override@JsonKey() final  bool isTrial;
@override final  String? planProductId;
/// 現エンタイトルメントの失効日時(RC `expires_date`。グレースピリオド中は
/// `grace_period_expires_date`)。プラン解決規則2(読み取り時失効ガード)の
/// 判定に使用する([resolvedPlan] 参照)。
@override@NullableTimestampConverter() final  DateTime? planExpiresAt;
/// 購入クレジット残高(無期限。加算=rcWebhook、減算=quota消費トランザクション
/// と返金処理のみ)。
@override@JsonKey() final  int postCredits;
@override@NullableTimestampConverter() final  DateTime? updatedAt;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillingStateCopyWith<_BillingState> get copyWith => __$BillingStateCopyWithImpl<_BillingState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BillingStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillingState&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.isTrial, isTrial) || other.isTrial == isTrial)&&(identical(other.planProductId, planProductId) || other.planProductId == planProductId)&&(identical(other.planExpiresAt, planExpiresAt) || other.planExpiresAt == planExpiresAt)&&(identical(other.postCredits, postCredits) || other.postCredits == postCredits)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,plan,isTrial,planProductId,planExpiresAt,postCredits,updatedAt);

@override
String toString() {
  return 'BillingState(plan: $plan, isTrial: $isTrial, planProductId: $planProductId, planExpiresAt: $planExpiresAt, postCredits: $postCredits, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$BillingStateCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory _$BillingStateCopyWith(_BillingState value, $Res Function(_BillingState) _then) = __$BillingStateCopyWithImpl;
@override @useResult
$Res call({
 Plan plan, bool isTrial, String? planProductId,@NullableTimestampConverter() DateTime? planExpiresAt, int postCredits,@NullableTimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$BillingStateCopyWithImpl<$Res>
    implements _$BillingStateCopyWith<$Res> {
  __$BillingStateCopyWithImpl(this._self, this._then);

  final _BillingState _self;
  final $Res Function(_BillingState) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? plan = null,Object? isTrial = null,Object? planProductId = freezed,Object? planExpiresAt = freezed,Object? postCredits = null,Object? updatedAt = freezed,}) {
  return _then(_BillingState(
plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as Plan,isTrial: null == isTrial ? _self.isTrial : isTrial // ignore: cast_nullable_to_non_nullable
as bool,planProductId: freezed == planProductId ? _self.planProductId : planProductId // ignore: cast_nullable_to_non_nullable
as String?,planExpiresAt: freezed == planExpiresAt ? _self.planExpiresAt : planExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,postCredits: null == postCredits ? _self.postCredits : postCredits // ignore: cast_nullable_to_non_nullable
as int,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
