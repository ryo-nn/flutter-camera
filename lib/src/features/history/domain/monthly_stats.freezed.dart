// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MonthlyStats {

 int get totalPosts; int get instagramSucceeded; int get xSucceeded; List<PatternUsage> get patternRanking;
/// Create a copy of MonthlyStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthlyStatsCopyWith<MonthlyStats> get copyWith => _$MonthlyStatsCopyWithImpl<MonthlyStats>(this as MonthlyStats, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthlyStats&&(identical(other.totalPosts, totalPosts) || other.totalPosts == totalPosts)&&(identical(other.instagramSucceeded, instagramSucceeded) || other.instagramSucceeded == instagramSucceeded)&&(identical(other.xSucceeded, xSucceeded) || other.xSucceeded == xSucceeded)&&const DeepCollectionEquality().equals(other.patternRanking, patternRanking));
}


@override
int get hashCode => Object.hash(runtimeType,totalPosts,instagramSucceeded,xSucceeded,const DeepCollectionEquality().hash(patternRanking));

@override
String toString() {
  return 'MonthlyStats(totalPosts: $totalPosts, instagramSucceeded: $instagramSucceeded, xSucceeded: $xSucceeded, patternRanking: $patternRanking)';
}


}

/// @nodoc
abstract mixin class $MonthlyStatsCopyWith<$Res>  {
  factory $MonthlyStatsCopyWith(MonthlyStats value, $Res Function(MonthlyStats) _then) = _$MonthlyStatsCopyWithImpl;
@useResult
$Res call({
 int totalPosts, int instagramSucceeded, int xSucceeded, List<PatternUsage> patternRanking
});




}
/// @nodoc
class _$MonthlyStatsCopyWithImpl<$Res>
    implements $MonthlyStatsCopyWith<$Res> {
  _$MonthlyStatsCopyWithImpl(this._self, this._then);

  final MonthlyStats _self;
  final $Res Function(MonthlyStats) _then;

/// Create a copy of MonthlyStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalPosts = null,Object? instagramSucceeded = null,Object? xSucceeded = null,Object? patternRanking = null,}) {
  return _then(_self.copyWith(
totalPosts: null == totalPosts ? _self.totalPosts : totalPosts // ignore: cast_nullable_to_non_nullable
as int,instagramSucceeded: null == instagramSucceeded ? _self.instagramSucceeded : instagramSucceeded // ignore: cast_nullable_to_non_nullable
as int,xSucceeded: null == xSucceeded ? _self.xSucceeded : xSucceeded // ignore: cast_nullable_to_non_nullable
as int,patternRanking: null == patternRanking ? _self.patternRanking : patternRanking // ignore: cast_nullable_to_non_nullable
as List<PatternUsage>,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthlyStats].
extension MonthlyStatsPatterns on MonthlyStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthlyStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthlyStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthlyStats value)  $default,){
final _that = this;
switch (_that) {
case _MonthlyStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthlyStats value)?  $default,){
final _that = this;
switch (_that) {
case _MonthlyStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalPosts,  int instagramSucceeded,  int xSucceeded,  List<PatternUsage> patternRanking)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthlyStats() when $default != null:
return $default(_that.totalPosts,_that.instagramSucceeded,_that.xSucceeded,_that.patternRanking);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalPosts,  int instagramSucceeded,  int xSucceeded,  List<PatternUsage> patternRanking)  $default,) {final _that = this;
switch (_that) {
case _MonthlyStats():
return $default(_that.totalPosts,_that.instagramSucceeded,_that.xSucceeded,_that.patternRanking);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalPosts,  int instagramSucceeded,  int xSucceeded,  List<PatternUsage> patternRanking)?  $default,) {final _that = this;
switch (_that) {
case _MonthlyStats() when $default != null:
return $default(_that.totalPosts,_that.instagramSucceeded,_that.xSucceeded,_that.patternRanking);case _:
  return null;

}
}

}

/// @nodoc


class _MonthlyStats extends MonthlyStats {
  const _MonthlyStats({required this.totalPosts, required this.instagramSucceeded, required this.xSucceeded, required final  List<PatternUsage> patternRanking}): _patternRanking = patternRanking,super._();
  

@override final  int totalPosts;
@override final  int instagramSucceeded;
@override final  int xSucceeded;
 final  List<PatternUsage> _patternRanking;
@override List<PatternUsage> get patternRanking {
  if (_patternRanking is EqualUnmodifiableListView) return _patternRanking;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_patternRanking);
}


/// Create a copy of MonthlyStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthlyStatsCopyWith<_MonthlyStats> get copyWith => __$MonthlyStatsCopyWithImpl<_MonthlyStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthlyStats&&(identical(other.totalPosts, totalPosts) || other.totalPosts == totalPosts)&&(identical(other.instagramSucceeded, instagramSucceeded) || other.instagramSucceeded == instagramSucceeded)&&(identical(other.xSucceeded, xSucceeded) || other.xSucceeded == xSucceeded)&&const DeepCollectionEquality().equals(other._patternRanking, _patternRanking));
}


@override
int get hashCode => Object.hash(runtimeType,totalPosts,instagramSucceeded,xSucceeded,const DeepCollectionEquality().hash(_patternRanking));

@override
String toString() {
  return 'MonthlyStats(totalPosts: $totalPosts, instagramSucceeded: $instagramSucceeded, xSucceeded: $xSucceeded, patternRanking: $patternRanking)';
}


}

/// @nodoc
abstract mixin class _$MonthlyStatsCopyWith<$Res> implements $MonthlyStatsCopyWith<$Res> {
  factory _$MonthlyStatsCopyWith(_MonthlyStats value, $Res Function(_MonthlyStats) _then) = __$MonthlyStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalPosts, int instagramSucceeded, int xSucceeded, List<PatternUsage> patternRanking
});




}
/// @nodoc
class __$MonthlyStatsCopyWithImpl<$Res>
    implements _$MonthlyStatsCopyWith<$Res> {
  __$MonthlyStatsCopyWithImpl(this._self, this._then);

  final _MonthlyStats _self;
  final $Res Function(_MonthlyStats) _then;

/// Create a copy of MonthlyStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalPosts = null,Object? instagramSucceeded = null,Object? xSucceeded = null,Object? patternRanking = null,}) {
  return _then(_MonthlyStats(
totalPosts: null == totalPosts ? _self.totalPosts : totalPosts // ignore: cast_nullable_to_non_nullable
as int,instagramSucceeded: null == instagramSucceeded ? _self.instagramSucceeded : instagramSucceeded // ignore: cast_nullable_to_non_nullable
as int,xSucceeded: null == xSucceeded ? _self.xSucceeded : xSucceeded // ignore: cast_nullable_to_non_nullable
as int,patternRanking: null == patternRanking ? _self._patternRanking : patternRanking // ignore: cast_nullable_to_non_nullable
as List<PatternUsage>,
  ));
}


}

/// @nodoc
mixin _$PatternUsage {

 String get patternId; String get patternName; int get count;
/// Create a copy of PatternUsage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PatternUsageCopyWith<PatternUsage> get copyWith => _$PatternUsageCopyWithImpl<PatternUsage>(this as PatternUsage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PatternUsage&&(identical(other.patternId, patternId) || other.patternId == patternId)&&(identical(other.patternName, patternName) || other.patternName == patternName)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode => Object.hash(runtimeType,patternId,patternName,count);

@override
String toString() {
  return 'PatternUsage(patternId: $patternId, patternName: $patternName, count: $count)';
}


}

/// @nodoc
abstract mixin class $PatternUsageCopyWith<$Res>  {
  factory $PatternUsageCopyWith(PatternUsage value, $Res Function(PatternUsage) _then) = _$PatternUsageCopyWithImpl;
@useResult
$Res call({
 String patternId, String patternName, int count
});




}
/// @nodoc
class _$PatternUsageCopyWithImpl<$Res>
    implements $PatternUsageCopyWith<$Res> {
  _$PatternUsageCopyWithImpl(this._self, this._then);

  final PatternUsage _self;
  final $Res Function(PatternUsage) _then;

/// Create a copy of PatternUsage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? patternId = null,Object? patternName = null,Object? count = null,}) {
  return _then(_self.copyWith(
patternId: null == patternId ? _self.patternId : patternId // ignore: cast_nullable_to_non_nullable
as String,patternName: null == patternName ? _self.patternName : patternName // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PatternUsage].
extension PatternUsagePatterns on PatternUsage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PatternUsage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PatternUsage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PatternUsage value)  $default,){
final _that = this;
switch (_that) {
case _PatternUsage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PatternUsage value)?  $default,){
final _that = this;
switch (_that) {
case _PatternUsage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String patternId,  String patternName,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PatternUsage() when $default != null:
return $default(_that.patternId,_that.patternName,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String patternId,  String patternName,  int count)  $default,) {final _that = this;
switch (_that) {
case _PatternUsage():
return $default(_that.patternId,_that.patternName,_that.count);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String patternId,  String patternName,  int count)?  $default,) {final _that = this;
switch (_that) {
case _PatternUsage() when $default != null:
return $default(_that.patternId,_that.patternName,_that.count);case _:
  return null;

}
}

}

/// @nodoc


class _PatternUsage implements PatternUsage {
  const _PatternUsage({required this.patternId, required this.patternName, required this.count});
  

@override final  String patternId;
@override final  String patternName;
@override final  int count;

/// Create a copy of PatternUsage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PatternUsageCopyWith<_PatternUsage> get copyWith => __$PatternUsageCopyWithImpl<_PatternUsage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PatternUsage&&(identical(other.patternId, patternId) || other.patternId == patternId)&&(identical(other.patternName, patternName) || other.patternName == patternName)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode => Object.hash(runtimeType,patternId,patternName,count);

@override
String toString() {
  return 'PatternUsage(patternId: $patternId, patternName: $patternName, count: $count)';
}


}

/// @nodoc
abstract mixin class _$PatternUsageCopyWith<$Res> implements $PatternUsageCopyWith<$Res> {
  factory _$PatternUsageCopyWith(_PatternUsage value, $Res Function(_PatternUsage) _then) = __$PatternUsageCopyWithImpl;
@override @useResult
$Res call({
 String patternId, String patternName, int count
});




}
/// @nodoc
class __$PatternUsageCopyWithImpl<$Res>
    implements _$PatternUsageCopyWith<$Res> {
  __$PatternUsageCopyWithImpl(this._self, this._then);

  final _PatternUsage _self;
  final $Res Function(_PatternUsage) _then;

/// Create a copy of PatternUsage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? patternId = null,Object? patternName = null,Object? count = null,}) {
  return _then(_PatternUsage(
patternId: null == patternId ? _self.patternId : patternId // ignore: cast_nullable_to_non_nullable
as String,patternName: null == patternName ? _self.patternName : patternName // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
