// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sns_connection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SnsConnection {

 SnsProvider get provider; SnsConnectionStatus get status; String? get username;/// Instagramのみ意味を持つ(プロアカウント判定)。Xでは常に `null`。
///
/// backend章「プロアカウント(Business/Creator)判定」節: 非プロアカウントの
/// トークンは `igExchangeToken` が保存前に破棄するため、実装上
/// `status == connected` のInstagramドキュメントは通常 `true` になる
/// (`false` は将来の仕様変化・異常系に備えた防御的な値として保持する)。
 bool? get isProAccount;/// Instagramの `account_type` 生値(例: `'BUSINESS'` / `'MEDIA_CREATOR'`。
/// バッジ表示用。backend章「プロアカウント判定」節準拠)。
 String? get accountType; DateTime? get updatedAt;
/// Create a copy of SnsConnection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnsConnectionCopyWith<SnsConnection> get copyWith => _$SnsConnectionCopyWithImpl<SnsConnection>(this as SnsConnection, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnsConnection&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.status, status) || other.status == status)&&(identical(other.username, username) || other.username == username)&&(identical(other.isProAccount, isProAccount) || other.isProAccount == isProAccount)&&(identical(other.accountType, accountType) || other.accountType == accountType)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,provider,status,username,isProAccount,accountType,updatedAt);

@override
String toString() {
  return 'SnsConnection(provider: $provider, status: $status, username: $username, isProAccount: $isProAccount, accountType: $accountType, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SnsConnectionCopyWith<$Res>  {
  factory $SnsConnectionCopyWith(SnsConnection value, $Res Function(SnsConnection) _then) = _$SnsConnectionCopyWithImpl;
@useResult
$Res call({
 SnsProvider provider, SnsConnectionStatus status, String? username, bool? isProAccount, String? accountType, DateTime? updatedAt
});




}
/// @nodoc
class _$SnsConnectionCopyWithImpl<$Res>
    implements $SnsConnectionCopyWith<$Res> {
  _$SnsConnectionCopyWithImpl(this._self, this._then);

  final SnsConnection _self;
  final $Res Function(SnsConnection) _then;

/// Create a copy of SnsConnection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? provider = null,Object? status = null,Object? username = freezed,Object? isProAccount = freezed,Object? accountType = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as SnsProvider,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SnsConnectionStatus,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,isProAccount: freezed == isProAccount ? _self.isProAccount : isProAccount // ignore: cast_nullable_to_non_nullable
as bool?,accountType: freezed == accountType ? _self.accountType : accountType // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnsConnection].
extension SnsConnectionPatterns on SnsConnection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnsConnection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnsConnection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnsConnection value)  $default,){
final _that = this;
switch (_that) {
case _SnsConnection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnsConnection value)?  $default,){
final _that = this;
switch (_that) {
case _SnsConnection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SnsProvider provider,  SnsConnectionStatus status,  String? username,  bool? isProAccount,  String? accountType,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnsConnection() when $default != null:
return $default(_that.provider,_that.status,_that.username,_that.isProAccount,_that.accountType,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SnsProvider provider,  SnsConnectionStatus status,  String? username,  bool? isProAccount,  String? accountType,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SnsConnection():
return $default(_that.provider,_that.status,_that.username,_that.isProAccount,_that.accountType,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SnsProvider provider,  SnsConnectionStatus status,  String? username,  bool? isProAccount,  String? accountType,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnsConnection() when $default != null:
return $default(_that.provider,_that.status,_that.username,_that.isProAccount,_that.accountType,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _SnsConnection extends SnsConnection {
  const _SnsConnection({required this.provider, required this.status, this.username, this.isProAccount, this.accountType, this.updatedAt}): super._();
  

@override final  SnsProvider provider;
@override final  SnsConnectionStatus status;
@override final  String? username;
/// Instagramのみ意味を持つ(プロアカウント判定)。Xでは常に `null`。
///
/// backend章「プロアカウント(Business/Creator)判定」節: 非プロアカウントの
/// トークンは `igExchangeToken` が保存前に破棄するため、実装上
/// `status == connected` のInstagramドキュメントは通常 `true` になる
/// (`false` は将来の仕様変化・異常系に備えた防御的な値として保持する)。
@override final  bool? isProAccount;
/// Instagramの `account_type` 生値(例: `'BUSINESS'` / `'MEDIA_CREATOR'`。
/// バッジ表示用。backend章「プロアカウント判定」節準拠)。
@override final  String? accountType;
@override final  DateTime? updatedAt;

/// Create a copy of SnsConnection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnsConnectionCopyWith<_SnsConnection> get copyWith => __$SnsConnectionCopyWithImpl<_SnsConnection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnsConnection&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.status, status) || other.status == status)&&(identical(other.username, username) || other.username == username)&&(identical(other.isProAccount, isProAccount) || other.isProAccount == isProAccount)&&(identical(other.accountType, accountType) || other.accountType == accountType)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,provider,status,username,isProAccount,accountType,updatedAt);

@override
String toString() {
  return 'SnsConnection(provider: $provider, status: $status, username: $username, isProAccount: $isProAccount, accountType: $accountType, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SnsConnectionCopyWith<$Res> implements $SnsConnectionCopyWith<$Res> {
  factory _$SnsConnectionCopyWith(_SnsConnection value, $Res Function(_SnsConnection) _then) = __$SnsConnectionCopyWithImpl;
@override @useResult
$Res call({
 SnsProvider provider, SnsConnectionStatus status, String? username, bool? isProAccount, String? accountType, DateTime? updatedAt
});




}
/// @nodoc
class __$SnsConnectionCopyWithImpl<$Res>
    implements _$SnsConnectionCopyWith<$Res> {
  __$SnsConnectionCopyWithImpl(this._self, this._then);

  final _SnsConnection _self;
  final $Res Function(_SnsConnection) _then;

/// Create a copy of SnsConnection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? provider = null,Object? status = null,Object? username = freezed,Object? isProAccount = freezed,Object? accountType = freezed,Object? updatedAt = freezed,}) {
  return _then(_SnsConnection(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as SnsProvider,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SnsConnectionStatus,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,isProAccount: freezed == isProAccount ? _self.isProAccount : isProAccount // ignore: cast_nullable_to_non_nullable
as bool?,accountType: freezed == accountType ? _self.accountType : accountType // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
