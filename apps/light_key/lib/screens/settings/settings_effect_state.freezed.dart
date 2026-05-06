// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_effect_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsEffectState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsEffectState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SettingsEffectState()';
}


}

/// @nodoc
class $SettingsEffectStateCopyWith<$Res>  {
$SettingsEffectStateCopyWith(SettingsEffectState _, $Res Function(SettingsEffectState) __);
}


/// Adds pattern-matching-related methods to [SettingsEffectState].
extension SettingsEffectStatePatterns on SettingsEffectState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SettingsEffectStateNone value)?  none,TResult Function( SettingsEffectStateShowMessage value)?  showMessage,TResult Function( SettingsEffectStateShowError value)?  showError,TResult Function( SettingsEffectStateLoggedOut value)?  loggedOut,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SettingsEffectStateNone() when none != null:
return none(_that);case SettingsEffectStateShowMessage() when showMessage != null:
return showMessage(_that);case SettingsEffectStateShowError() when showError != null:
return showError(_that);case SettingsEffectStateLoggedOut() when loggedOut != null:
return loggedOut(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SettingsEffectStateNone value)  none,required TResult Function( SettingsEffectStateShowMessage value)  showMessage,required TResult Function( SettingsEffectStateShowError value)  showError,required TResult Function( SettingsEffectStateLoggedOut value)  loggedOut,}){
final _that = this;
switch (_that) {
case SettingsEffectStateNone():
return none(_that);case SettingsEffectStateShowMessage():
return showMessage(_that);case SettingsEffectStateShowError():
return showError(_that);case SettingsEffectStateLoggedOut():
return loggedOut(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SettingsEffectStateNone value)?  none,TResult? Function( SettingsEffectStateShowMessage value)?  showMessage,TResult? Function( SettingsEffectStateShowError value)?  showError,TResult? Function( SettingsEffectStateLoggedOut value)?  loggedOut,}){
final _that = this;
switch (_that) {
case SettingsEffectStateNone() when none != null:
return none(_that);case SettingsEffectStateShowMessage() when showMessage != null:
return showMessage(_that);case SettingsEffectStateShowError() when showError != null:
return showError(_that);case SettingsEffectStateLoggedOut() when loggedOut != null:
return loggedOut(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  none,TResult Function( String message)?  showMessage,TResult Function( String message)?  showError,TResult Function()?  loggedOut,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SettingsEffectStateNone() when none != null:
return none();case SettingsEffectStateShowMessage() when showMessage != null:
return showMessage(_that.message);case SettingsEffectStateShowError() when showError != null:
return showError(_that.message);case SettingsEffectStateLoggedOut() when loggedOut != null:
return loggedOut();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  none,required TResult Function( String message)  showMessage,required TResult Function( String message)  showError,required TResult Function()  loggedOut,}) {final _that = this;
switch (_that) {
case SettingsEffectStateNone():
return none();case SettingsEffectStateShowMessage():
return showMessage(_that.message);case SettingsEffectStateShowError():
return showError(_that.message);case SettingsEffectStateLoggedOut():
return loggedOut();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  none,TResult? Function( String message)?  showMessage,TResult? Function( String message)?  showError,TResult? Function()?  loggedOut,}) {final _that = this;
switch (_that) {
case SettingsEffectStateNone() when none != null:
return none();case SettingsEffectStateShowMessage() when showMessage != null:
return showMessage(_that.message);case SettingsEffectStateShowError() when showError != null:
return showError(_that.message);case SettingsEffectStateLoggedOut() when loggedOut != null:
return loggedOut();case _:
  return null;

}
}

}

/// @nodoc


class SettingsEffectStateNone implements SettingsEffectState {
  const SettingsEffectStateNone();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsEffectStateNone);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SettingsEffectState.none()';
}


}




/// @nodoc


class SettingsEffectStateShowMessage implements SettingsEffectState {
  const SettingsEffectStateShowMessage(this.message);
  

 final  String message;

/// Create a copy of SettingsEffectState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsEffectStateShowMessageCopyWith<SettingsEffectStateShowMessage> get copyWith => _$SettingsEffectStateShowMessageCopyWithImpl<SettingsEffectStateShowMessage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsEffectStateShowMessage&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'SettingsEffectState.showMessage(message: $message)';
}


}

/// @nodoc
abstract mixin class $SettingsEffectStateShowMessageCopyWith<$Res> implements $SettingsEffectStateCopyWith<$Res> {
  factory $SettingsEffectStateShowMessageCopyWith(SettingsEffectStateShowMessage value, $Res Function(SettingsEffectStateShowMessage) _then) = _$SettingsEffectStateShowMessageCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$SettingsEffectStateShowMessageCopyWithImpl<$Res>
    implements $SettingsEffectStateShowMessageCopyWith<$Res> {
  _$SettingsEffectStateShowMessageCopyWithImpl(this._self, this._then);

  final SettingsEffectStateShowMessage _self;
  final $Res Function(SettingsEffectStateShowMessage) _then;

/// Create a copy of SettingsEffectState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(SettingsEffectStateShowMessage(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SettingsEffectStateShowError implements SettingsEffectState {
  const SettingsEffectStateShowError(this.message);
  

 final  String message;

/// Create a copy of SettingsEffectState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsEffectStateShowErrorCopyWith<SettingsEffectStateShowError> get copyWith => _$SettingsEffectStateShowErrorCopyWithImpl<SettingsEffectStateShowError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsEffectStateShowError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'SettingsEffectState.showError(message: $message)';
}


}

/// @nodoc
abstract mixin class $SettingsEffectStateShowErrorCopyWith<$Res> implements $SettingsEffectStateCopyWith<$Res> {
  factory $SettingsEffectStateShowErrorCopyWith(SettingsEffectStateShowError value, $Res Function(SettingsEffectStateShowError) _then) = _$SettingsEffectStateShowErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$SettingsEffectStateShowErrorCopyWithImpl<$Res>
    implements $SettingsEffectStateShowErrorCopyWith<$Res> {
  _$SettingsEffectStateShowErrorCopyWithImpl(this._self, this._then);

  final SettingsEffectStateShowError _self;
  final $Res Function(SettingsEffectStateShowError) _then;

/// Create a copy of SettingsEffectState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(SettingsEffectStateShowError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SettingsEffectStateLoggedOut implements SettingsEffectState {
  const SettingsEffectStateLoggedOut();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsEffectStateLoggedOut);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SettingsEffectState.loggedOut()';
}


}




// dart format on
