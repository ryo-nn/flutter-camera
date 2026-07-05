// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'camera_session_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CameraSessionState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CameraSessionState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CameraSessionState()';
}


}

/// @nodoc
class $CameraSessionStateCopyWith<$Res>  {
$CameraSessionStateCopyWith(CameraSessionState _, $Res Function(CameraSessionState) __);
}


/// Adds pattern-matching-related methods to [CameraSessionState].
extension CameraSessionStatePatterns on CameraSessionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CameraSessionReady value)?  ready,TResult Function( CameraSessionSuspended value)?  suspended,TResult Function( CameraSessionPermissionDenied value)?  permissionDenied,TResult Function( CameraSessionRestricted value)?  restricted,TResult Function( CameraSessionError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CameraSessionReady() when ready != null:
return ready(_that);case CameraSessionSuspended() when suspended != null:
return suspended(_that);case CameraSessionPermissionDenied() when permissionDenied != null:
return permissionDenied(_that);case CameraSessionRestricted() when restricted != null:
return restricted(_that);case CameraSessionError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CameraSessionReady value)  ready,required TResult Function( CameraSessionSuspended value)  suspended,required TResult Function( CameraSessionPermissionDenied value)  permissionDenied,required TResult Function( CameraSessionRestricted value)  restricted,required TResult Function( CameraSessionError value)  error,}){
final _that = this;
switch (_that) {
case CameraSessionReady():
return ready(_that);case CameraSessionSuspended():
return suspended(_that);case CameraSessionPermissionDenied():
return permissionDenied(_that);case CameraSessionRestricted():
return restricted(_that);case CameraSessionError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CameraSessionReady value)?  ready,TResult? Function( CameraSessionSuspended value)?  suspended,TResult? Function( CameraSessionPermissionDenied value)?  permissionDenied,TResult? Function( CameraSessionRestricted value)?  restricted,TResult? Function( CameraSessionError value)?  error,}){
final _that = this;
switch (_that) {
case CameraSessionReady() when ready != null:
return ready(_that);case CameraSessionSuspended() when suspended != null:
return suspended(_that);case CameraSessionPermissionDenied() when permissionDenied != null:
return permissionDenied(_that);case CameraSessionRestricted() when restricted != null:
return restricted(_that);case CameraSessionError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( CameraController controller,  CameraLensDirection lens,  CameraCaptureMode mode)?  ready,TResult Function()?  suspended,TResult Function( bool canRetry)?  permissionDenied,TResult Function()?  restricted,TResult Function( String code)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CameraSessionReady() when ready != null:
return ready(_that.controller,_that.lens,_that.mode);case CameraSessionSuspended() when suspended != null:
return suspended();case CameraSessionPermissionDenied() when permissionDenied != null:
return permissionDenied(_that.canRetry);case CameraSessionRestricted() when restricted != null:
return restricted();case CameraSessionError() when error != null:
return error(_that.code);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( CameraController controller,  CameraLensDirection lens,  CameraCaptureMode mode)  ready,required TResult Function()  suspended,required TResult Function( bool canRetry)  permissionDenied,required TResult Function()  restricted,required TResult Function( String code)  error,}) {final _that = this;
switch (_that) {
case CameraSessionReady():
return ready(_that.controller,_that.lens,_that.mode);case CameraSessionSuspended():
return suspended();case CameraSessionPermissionDenied():
return permissionDenied(_that.canRetry);case CameraSessionRestricted():
return restricted();case CameraSessionError():
return error(_that.code);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( CameraController controller,  CameraLensDirection lens,  CameraCaptureMode mode)?  ready,TResult? Function()?  suspended,TResult? Function( bool canRetry)?  permissionDenied,TResult? Function()?  restricted,TResult? Function( String code)?  error,}) {final _that = this;
switch (_that) {
case CameraSessionReady() when ready != null:
return ready(_that.controller,_that.lens,_that.mode);case CameraSessionSuspended() when suspended != null:
return suspended();case CameraSessionPermissionDenied() when permissionDenied != null:
return permissionDenied(_that.canRetry);case CameraSessionRestricted() when restricted != null:
return restricted();case CameraSessionError() when error != null:
return error(_that.code);case _:
  return null;

}
}

}

/// @nodoc


class CameraSessionReady implements CameraSessionState {
  const CameraSessionReady({required this.controller, required this.lens, this.mode = CameraCaptureMode.photo});
  

 final  CameraController controller;
 final  CameraLensDirection lens;
@JsonKey() final  CameraCaptureMode mode;

/// Create a copy of CameraSessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CameraSessionReadyCopyWith<CameraSessionReady> get copyWith => _$CameraSessionReadyCopyWithImpl<CameraSessionReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CameraSessionReady&&(identical(other.controller, controller) || other.controller == controller)&&(identical(other.lens, lens) || other.lens == lens)&&(identical(other.mode, mode) || other.mode == mode));
}


@override
int get hashCode => Object.hash(runtimeType,controller,lens,mode);

@override
String toString() {
  return 'CameraSessionState.ready(controller: $controller, lens: $lens, mode: $mode)';
}


}

/// @nodoc
abstract mixin class $CameraSessionReadyCopyWith<$Res> implements $CameraSessionStateCopyWith<$Res> {
  factory $CameraSessionReadyCopyWith(CameraSessionReady value, $Res Function(CameraSessionReady) _then) = _$CameraSessionReadyCopyWithImpl;
@useResult
$Res call({
 CameraController controller, CameraLensDirection lens, CameraCaptureMode mode
});




}
/// @nodoc
class _$CameraSessionReadyCopyWithImpl<$Res>
    implements $CameraSessionReadyCopyWith<$Res> {
  _$CameraSessionReadyCopyWithImpl(this._self, this._then);

  final CameraSessionReady _self;
  final $Res Function(CameraSessionReady) _then;

/// Create a copy of CameraSessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? controller = null,Object? lens = null,Object? mode = null,}) {
  return _then(CameraSessionReady(
controller: null == controller ? _self.controller : controller // ignore: cast_nullable_to_non_nullable
as CameraController,lens: null == lens ? _self.lens : lens // ignore: cast_nullable_to_non_nullable
as CameraLensDirection,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as CameraCaptureMode,
  ));
}


}

/// @nodoc


class CameraSessionSuspended implements CameraSessionState {
  const CameraSessionSuspended();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CameraSessionSuspended);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CameraSessionState.suspended()';
}


}




/// @nodoc


class CameraSessionPermissionDenied implements CameraSessionState {
  const CameraSessionPermissionDenied({required this.canRetry});
  

 final  bool canRetry;

/// Create a copy of CameraSessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CameraSessionPermissionDeniedCopyWith<CameraSessionPermissionDenied> get copyWith => _$CameraSessionPermissionDeniedCopyWithImpl<CameraSessionPermissionDenied>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CameraSessionPermissionDenied&&(identical(other.canRetry, canRetry) || other.canRetry == canRetry));
}


@override
int get hashCode => Object.hash(runtimeType,canRetry);

@override
String toString() {
  return 'CameraSessionState.permissionDenied(canRetry: $canRetry)';
}


}

/// @nodoc
abstract mixin class $CameraSessionPermissionDeniedCopyWith<$Res> implements $CameraSessionStateCopyWith<$Res> {
  factory $CameraSessionPermissionDeniedCopyWith(CameraSessionPermissionDenied value, $Res Function(CameraSessionPermissionDenied) _then) = _$CameraSessionPermissionDeniedCopyWithImpl;
@useResult
$Res call({
 bool canRetry
});




}
/// @nodoc
class _$CameraSessionPermissionDeniedCopyWithImpl<$Res>
    implements $CameraSessionPermissionDeniedCopyWith<$Res> {
  _$CameraSessionPermissionDeniedCopyWithImpl(this._self, this._then);

  final CameraSessionPermissionDenied _self;
  final $Res Function(CameraSessionPermissionDenied) _then;

/// Create a copy of CameraSessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? canRetry = null,}) {
  return _then(CameraSessionPermissionDenied(
canRetry: null == canRetry ? _self.canRetry : canRetry // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class CameraSessionRestricted implements CameraSessionState {
  const CameraSessionRestricted();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CameraSessionRestricted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CameraSessionState.restricted()';
}


}




/// @nodoc


class CameraSessionError implements CameraSessionState {
  const CameraSessionError(this.code);
  

 final  String code;

/// Create a copy of CameraSessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CameraSessionErrorCopyWith<CameraSessionError> get copyWith => _$CameraSessionErrorCopyWithImpl<CameraSessionError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CameraSessionError&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode => Object.hash(runtimeType,code);

@override
String toString() {
  return 'CameraSessionState.error(code: $code)';
}


}

/// @nodoc
abstract mixin class $CameraSessionErrorCopyWith<$Res> implements $CameraSessionStateCopyWith<$Res> {
  factory $CameraSessionErrorCopyWith(CameraSessionError value, $Res Function(CameraSessionError) _then) = _$CameraSessionErrorCopyWithImpl;
@useResult
$Res call({
 String code
});




}
/// @nodoc
class _$CameraSessionErrorCopyWithImpl<$Res>
    implements $CameraSessionErrorCopyWith<$Res> {
  _$CameraSessionErrorCopyWithImpl(this._self, this._then);

  final CameraSessionError _self;
  final $Res Function(CameraSessionError) _then;

/// Create a copy of CameraSessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? code = null,}) {
  return _then(CameraSessionError(
null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
