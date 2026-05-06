// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_screen_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsScreenState {

 theme_constants.ThemeMode get themeMode; bool get isSigningOut;
/// Create a copy of SettingsScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsScreenStateCopyWith<SettingsScreenState> get copyWith => _$SettingsScreenStateCopyWithImpl<SettingsScreenState>(this as SettingsScreenState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsScreenState&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.isSigningOut, isSigningOut) || other.isSigningOut == isSigningOut));
}


@override
int get hashCode => Object.hash(runtimeType,themeMode,isSigningOut);

@override
String toString() {
  return 'SettingsScreenState(themeMode: $themeMode, isSigningOut: $isSigningOut)';
}


}

/// @nodoc
abstract mixin class $SettingsScreenStateCopyWith<$Res>  {
  factory $SettingsScreenStateCopyWith(SettingsScreenState value, $Res Function(SettingsScreenState) _then) = _$SettingsScreenStateCopyWithImpl;
@useResult
$Res call({
 theme_constants.ThemeMode themeMode, bool isSigningOut
});




}
/// @nodoc
class _$SettingsScreenStateCopyWithImpl<$Res>
    implements $SettingsScreenStateCopyWith<$Res> {
  _$SettingsScreenStateCopyWithImpl(this._self, this._then);

  final SettingsScreenState _self;
  final $Res Function(SettingsScreenState) _then;

/// Create a copy of SettingsScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? themeMode = null,Object? isSigningOut = null,}) {
  return _then(_self.copyWith(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as theme_constants.ThemeMode,isSigningOut: null == isSigningOut ? _self.isSigningOut : isSigningOut // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SettingsScreenState].
extension SettingsScreenStatePatterns on SettingsScreenState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SettingsScreenStateReady value)?  ready,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SettingsScreenStateReady() when ready != null:
return ready(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SettingsScreenStateReady value)  ready,}){
final _that = this;
switch (_that) {
case SettingsScreenStateReady():
return ready(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SettingsScreenStateReady value)?  ready,}){
final _that = this;
switch (_that) {
case SettingsScreenStateReady() when ready != null:
return ready(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( theme_constants.ThemeMode themeMode,  bool isSigningOut)?  ready,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SettingsScreenStateReady() when ready != null:
return ready(_that.themeMode,_that.isSigningOut);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( theme_constants.ThemeMode themeMode,  bool isSigningOut)  ready,}) {final _that = this;
switch (_that) {
case SettingsScreenStateReady():
return ready(_that.themeMode,_that.isSigningOut);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( theme_constants.ThemeMode themeMode,  bool isSigningOut)?  ready,}) {final _that = this;
switch (_that) {
case SettingsScreenStateReady() when ready != null:
return ready(_that.themeMode,_that.isSigningOut);case _:
  return null;

}
}

}

/// @nodoc


class SettingsScreenStateReady implements SettingsScreenState {
  const SettingsScreenStateReady({required this.themeMode, this.isSigningOut = false});
  

@override final  theme_constants.ThemeMode themeMode;
@override@JsonKey() final  bool isSigningOut;

/// Create a copy of SettingsScreenState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsScreenStateReadyCopyWith<SettingsScreenStateReady> get copyWith => _$SettingsScreenStateReadyCopyWithImpl<SettingsScreenStateReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsScreenStateReady&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.isSigningOut, isSigningOut) || other.isSigningOut == isSigningOut));
}


@override
int get hashCode => Object.hash(runtimeType,themeMode,isSigningOut);

@override
String toString() {
  return 'SettingsScreenState.ready(themeMode: $themeMode, isSigningOut: $isSigningOut)';
}


}

/// @nodoc
abstract mixin class $SettingsScreenStateReadyCopyWith<$Res> implements $SettingsScreenStateCopyWith<$Res> {
  factory $SettingsScreenStateReadyCopyWith(SettingsScreenStateReady value, $Res Function(SettingsScreenStateReady) _then) = _$SettingsScreenStateReadyCopyWithImpl;
@override @useResult
$Res call({
 theme_constants.ThemeMode themeMode, bool isSigningOut
});




}
/// @nodoc
class _$SettingsScreenStateReadyCopyWithImpl<$Res>
    implements $SettingsScreenStateReadyCopyWith<$Res> {
  _$SettingsScreenStateReadyCopyWithImpl(this._self, this._then);

  final SettingsScreenStateReady _self;
  final $Res Function(SettingsScreenStateReady) _then;

/// Create a copy of SettingsScreenState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? themeMode = null,Object? isSigningOut = null,}) {
  return _then(SettingsScreenStateReady(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as theme_constants.ThemeMode,isSigningOut: null == isSigningOut ? _self.isSigningOut : isSigningOut // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
