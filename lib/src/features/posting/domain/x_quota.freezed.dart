// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'x_quota.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$XQuota {

 Plan get plan; int get monthlyLimit; int get monthlyUsed; int get dailyLimit; int get dailyUsed; int get creditBalance;
/// Create a copy of XQuota
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$XQuotaCopyWith<XQuota> get copyWith => _$XQuotaCopyWithImpl<XQuota>(this as XQuota, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is XQuota&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.monthlyLimit, monthlyLimit) || other.monthlyLimit == monthlyLimit)&&(identical(other.monthlyUsed, monthlyUsed) || other.monthlyUsed == monthlyUsed)&&(identical(other.dailyLimit, dailyLimit) || other.dailyLimit == dailyLimit)&&(identical(other.dailyUsed, dailyUsed) || other.dailyUsed == dailyUsed)&&(identical(other.creditBalance, creditBalance) || other.creditBalance == creditBalance));
}


@override
int get hashCode => Object.hash(runtimeType,plan,monthlyLimit,monthlyUsed,dailyLimit,dailyUsed,creditBalance);

@override
String toString() {
  return 'XQuota(plan: $plan, monthlyLimit: $monthlyLimit, monthlyUsed: $monthlyUsed, dailyLimit: $dailyLimit, dailyUsed: $dailyUsed, creditBalance: $creditBalance)';
}


}

/// @nodoc
abstract mixin class $XQuotaCopyWith<$Res>  {
  factory $XQuotaCopyWith(XQuota value, $Res Function(XQuota) _then) = _$XQuotaCopyWithImpl;
@useResult
$Res call({
 Plan plan, int monthlyLimit, int monthlyUsed, int dailyLimit, int dailyUsed, int creditBalance
});




}
/// @nodoc
class _$XQuotaCopyWithImpl<$Res>
    implements $XQuotaCopyWith<$Res> {
  _$XQuotaCopyWithImpl(this._self, this._then);

  final XQuota _self;
  final $Res Function(XQuota) _then;

/// Create a copy of XQuota
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? plan = null,Object? monthlyLimit = null,Object? monthlyUsed = null,Object? dailyLimit = null,Object? dailyUsed = null,Object? creditBalance = null,}) {
  return _then(_self.copyWith(
plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as Plan,monthlyLimit: null == monthlyLimit ? _self.monthlyLimit : monthlyLimit // ignore: cast_nullable_to_non_nullable
as int,monthlyUsed: null == monthlyUsed ? _self.monthlyUsed : monthlyUsed // ignore: cast_nullable_to_non_nullable
as int,dailyLimit: null == dailyLimit ? _self.dailyLimit : dailyLimit // ignore: cast_nullable_to_non_nullable
as int,dailyUsed: null == dailyUsed ? _self.dailyUsed : dailyUsed // ignore: cast_nullable_to_non_nullable
as int,creditBalance: null == creditBalance ? _self.creditBalance : creditBalance // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [XQuota].
extension XQuotaPatterns on XQuota {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _XQuota value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _XQuota() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _XQuota value)  $default,){
final _that = this;
switch (_that) {
case _XQuota():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _XQuota value)?  $default,){
final _that = this;
switch (_that) {
case _XQuota() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Plan plan,  int monthlyLimit,  int monthlyUsed,  int dailyLimit,  int dailyUsed,  int creditBalance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _XQuota() when $default != null:
return $default(_that.plan,_that.monthlyLimit,_that.monthlyUsed,_that.dailyLimit,_that.dailyUsed,_that.creditBalance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Plan plan,  int monthlyLimit,  int monthlyUsed,  int dailyLimit,  int dailyUsed,  int creditBalance)  $default,) {final _that = this;
switch (_that) {
case _XQuota():
return $default(_that.plan,_that.monthlyLimit,_that.monthlyUsed,_that.dailyLimit,_that.dailyUsed,_that.creditBalance);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Plan plan,  int monthlyLimit,  int monthlyUsed,  int dailyLimit,  int dailyUsed,  int creditBalance)?  $default,) {final _that = this;
switch (_that) {
case _XQuota() when $default != null:
return $default(_that.plan,_that.monthlyLimit,_that.monthlyUsed,_that.dailyLimit,_that.dailyUsed,_that.creditBalance);case _:
  return null;

}
}

}

/// @nodoc


class _XQuota extends XQuota {
  const _XQuota({required this.plan, required this.monthlyLimit, required this.monthlyUsed, required this.dailyLimit, required this.dailyUsed, required this.creditBalance}): super._();
  

@override final  Plan plan;
@override final  int monthlyLimit;
@override final  int monthlyUsed;
@override final  int dailyLimit;
@override final  int dailyUsed;
@override final  int creditBalance;

/// Create a copy of XQuota
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$XQuotaCopyWith<_XQuota> get copyWith => __$XQuotaCopyWithImpl<_XQuota>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _XQuota&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.monthlyLimit, monthlyLimit) || other.monthlyLimit == monthlyLimit)&&(identical(other.monthlyUsed, monthlyUsed) || other.monthlyUsed == monthlyUsed)&&(identical(other.dailyLimit, dailyLimit) || other.dailyLimit == dailyLimit)&&(identical(other.dailyUsed, dailyUsed) || other.dailyUsed == dailyUsed)&&(identical(other.creditBalance, creditBalance) || other.creditBalance == creditBalance));
}


@override
int get hashCode => Object.hash(runtimeType,plan,monthlyLimit,monthlyUsed,dailyLimit,dailyUsed,creditBalance);

@override
String toString() {
  return 'XQuota(plan: $plan, monthlyLimit: $monthlyLimit, monthlyUsed: $monthlyUsed, dailyLimit: $dailyLimit, dailyUsed: $dailyUsed, creditBalance: $creditBalance)';
}


}

/// @nodoc
abstract mixin class _$XQuotaCopyWith<$Res> implements $XQuotaCopyWith<$Res> {
  factory _$XQuotaCopyWith(_XQuota value, $Res Function(_XQuota) _then) = __$XQuotaCopyWithImpl;
@override @useResult
$Res call({
 Plan plan, int monthlyLimit, int monthlyUsed, int dailyLimit, int dailyUsed, int creditBalance
});




}
/// @nodoc
class __$XQuotaCopyWithImpl<$Res>
    implements _$XQuotaCopyWith<$Res> {
  __$XQuotaCopyWithImpl(this._self, this._then);

  final _XQuota _self;
  final $Res Function(_XQuota) _then;

/// Create a copy of XQuota
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? plan = null,Object? monthlyLimit = null,Object? monthlyUsed = null,Object? dailyLimit = null,Object? dailyUsed = null,Object? creditBalance = null,}) {
  return _then(_XQuota(
plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as Plan,monthlyLimit: null == monthlyLimit ? _self.monthlyLimit : monthlyLimit // ignore: cast_nullable_to_non_nullable
as int,monthlyUsed: null == monthlyUsed ? _self.monthlyUsed : monthlyUsed // ignore: cast_nullable_to_non_nullable
as int,dailyLimit: null == dailyLimit ? _self.dailyLimit : dailyLimit // ignore: cast_nullable_to_non_nullable
as int,dailyUsed: null == dailyUsed ? _self.dailyUsed : dailyUsed // ignore: cast_nullable_to_non_nullable
as int,creditBalance: null == creditBalance ? _self.creditBalance : creditBalance // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
