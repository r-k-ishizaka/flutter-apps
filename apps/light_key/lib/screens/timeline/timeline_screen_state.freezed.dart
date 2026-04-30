// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timeline_screen_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TimelineScreenState {


  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is TimelineScreenState);
  }


  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TimelineScreenState()';
  }


}

/// @nodoc
class $TimelineScreenStateCopyWith<$Res> {
  $TimelineScreenStateCopyWith(TimelineScreenState _,
      $Res Function(TimelineScreenState) __);
}


/// Adds pattern-matching-related methods to [TimelineScreenState].
extension TimelineScreenStatePatterns on TimelineScreenState {
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

  @optionalTypeArgs TResult maybeMap

  <

  TResult

  extends

  Object?

  >

  (

  {

  TResult

  Function

  (

  TimelineScreenStateIdle

  value

  )

  ?

  idle

  ,

  TResult

  Function

  (

  TimelineScreenStateLoading

  value

  )

  ?

  loading

  ,

  TResult

  Function

  (

  TimelineScreenStateLoaded

  value

  )

  ?

  loaded

  ,

  TResult

  Function

  (

  TimelineScreenStateError

  value

  )

  ?

  error

  ,

  required

  TResult

  orElse

  (

  )

  ,
}){
final _that = this;
switch (_that) {
case TimelineScreenStateIdle() when idle != null:
return idle(_that);case TimelineScreenStateLoading() when loading != null:
return loading(_that);case TimelineScreenStateLoaded() when loaded != null:
return loaded(_that);case TimelineScreenStateError() when error != null:
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

@optionalTypeArgs
TResult map<TResult extends Object?>(
    {required TResult Function( TimelineScreenStateIdle value) idle, required TResult Function( TimelineScreenStateLoading value) loading, required TResult Function( TimelineScreenStateLoaded value) loaded, required TResult Function( TimelineScreenStateError value) error,}) {
  final _that = this;
  switch (_that) {
    case TimelineScreenStateIdle():
      return idle(_that);
    case TimelineScreenStateLoading():
      return loading(_that);
    case TimelineScreenStateLoaded():
      return loaded(_that);
    case TimelineScreenStateError():
      return error(_that);
  }
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

@optionalTypeArgs
TResult? mapOrNull<TResult extends Object?>(
    {TResult? Function( TimelineScreenStateIdle value)? idle, TResult? Function( TimelineScreenStateLoading value)? loading, TResult? Function( TimelineScreenStateLoaded value)? loaded, TResult? Function( TimelineScreenStateError value)? error,}) {
  final _that = this;
  switch (_that) {
    case TimelineScreenStateIdle() when idle != null:
      return idle(_that);
    case TimelineScreenStateLoading() when loading != null:
      return loading(_that);
    case TimelineScreenStateLoaded() when loaded != null:
      return loaded(_that);
    case TimelineScreenStateError() when error != null:
      return error(_that);
    case _:
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

@optionalTypeArgs TResult maybeWhen
<
TResult extends Object?>(
{
TResult
Function
(
)
?
idle
,
TResult
Function
(
)
?
loading
,
TResult
Function
(
List
<
Note
>
notes
,
bool
isRefreshing
,
String
?
message
)
?
loaded
,
TResult
Function
(
String
?
message
)
?
error
,
required
TResult
orElse(),}) {final _that = this;
switch (_that) {
case TimelineScreenStateIdle() when idle != null:
return idle();case TimelineScreenStateLoading() when loading != null:
return loading();case TimelineScreenStateLoaded() when loaded != null:
return loaded(_that.notes,_that.isRefreshing,_that.message);case TimelineScreenStateError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function() idle,required TResult Function() loading,required TResult Function( List<Note> notes, bool isRefreshing, String? message) loaded,required TResult Function( String? message) error,}) {final _that = this;
switch (_that) {
case TimelineScreenStateIdle():
return idle();case TimelineScreenStateLoading():
return loading();case TimelineScreenStateLoaded():
return loaded(_that.notes,_that.isRefreshing,_that.message);case TimelineScreenStateError():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()? idle,TResult? Function()? loading,TResult? Function( List<Note> notes, bool isRefreshing, String? message)? loaded,TResult? Function( String? message)? error,}) {final _that = this;
switch (_that) {
case TimelineScreenStateIdle() when idle != null:
return idle();case TimelineScreenStateLoading() when loading != null:
return loading();case TimelineScreenStateLoaded() when loaded != null:
return loaded(_that.notes,_that.isRefreshing,_that.message);case TimelineScreenStateError() when error != null:
return error(_that.message);case _:
return null;

}
}

}

/// @nodoc


class TimelineScreenStateIdle implements TimelineScreenState {
const TimelineScreenStateIdle();


@override
bool operator ==(Object other) {
return identical(this, other) || (other.runtimeType == runtimeType&&other is TimelineScreenStateIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
return 'TimelineScreenState.idle()';
}


}


/// @nodoc


class TimelineScreenStateLoading implements TimelineScreenState {
const TimelineScreenStateLoading();


@override
bool operator ==(Object other) {
return identical(this, other) || (other.runtimeType == runtimeType&&other is TimelineScreenStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
return 'TimelineScreenState.loading()';
}


}


/// @nodoc


class TimelineScreenStateLoaded implements TimelineScreenState {
const TimelineScreenStateLoaded({final List<Note> notes = const <Note>[], this.isRefreshing = false, this.message}): _notes = notes;


final List<Note> _notes;
@JsonKey() List<Note> get notes {
if (_notes is EqualUnmodifiableListView) return _notes;
// ignore: implicit_dynamic_type
return EqualUnmodifiableListView(_notes);
}

@JsonKey() final bool isRefreshing;
final String? message;

/// Create a copy of TimelineScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimelineScreenStateLoadedCopyWith<TimelineScreenStateLoaded> get copyWith => _$TimelineScreenStateLoadedCopyWithImpl<TimelineScreenStateLoaded>(this, _$identity);


@override
bool operator ==(Object other) {
return identical(this, other) || (other.runtimeType == runtimeType&&other is TimelineScreenStateLoaded&&const DeepCollectionEquality().equals(other._notes, _notes)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_notes),isRefreshing,message);

@override
String toString() {
return 'TimelineScreenState.loaded(notes: $notes, isRefreshing: $isRefreshing, message: $message)';
}


}

/// @nodoc
abstract mixin class $TimelineScreenStateLoadedCopyWith<$Res> implements $TimelineScreenStateCopyWith<$Res> {
factory $TimelineScreenStateLoadedCopyWith(TimelineScreenStateLoaded value, $Res Function(TimelineScreenStateLoaded) _then) = _$TimelineScreenStateLoadedCopyWithImpl;
@useResult
$Res call({
List<Note> notes, bool isRefreshing, String? message
});


}
/// @nodoc
class _$TimelineScreenStateLoadedCopyWithImpl<$Res>
implements $TimelineScreenStateLoadedCopyWith<$Res> {
_$TimelineScreenStateLoadedCopyWithImpl(this._self, this._then);

final TimelineScreenStateLoaded _self;
final $Res Function(TimelineScreenStateLoaded) _then;

/// Create a copy of TimelineScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? notes = null,Object? isRefreshing = null,Object? message = freezed,}) {
return _then(TimelineScreenStateLoaded(
notes: null == notes ? _self._notes : notes // ignore: cast_nullable_to_non_nullable
as List<Note>,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
));
}


}

/// @nodoc


class TimelineScreenStateError implements TimelineScreenState {
const TimelineScreenStateError({this.message});


final String? message;

/// Create a copy of TimelineScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimelineScreenStateErrorCopyWith<TimelineScreenStateError> get copyWith => _$TimelineScreenStateErrorCopyWithImpl<TimelineScreenStateError>(this, _$identity);


@override
bool operator ==(Object other) {
return identical(this, other) || (other.runtimeType == runtimeType&&other is TimelineScreenStateError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
return 'TimelineScreenState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $TimelineScreenStateErrorCopyWith<$Res> implements $TimelineScreenStateCopyWith<$Res> {
factory $TimelineScreenStateErrorCopyWith(TimelineScreenStateError value, $Res Function(TimelineScreenStateError) _then) = _$TimelineScreenStateErrorCopyWithImpl;
@useResult
$Res call({
String? message
});


}
/// @nodoc
class _$TimelineScreenStateErrorCopyWithImpl<$Res>
implements $TimelineScreenStateErrorCopyWith<$Res> {
_$TimelineScreenStateErrorCopyWithImpl(this._self, this._then);

final TimelineScreenStateError _self;
final $Res Function(TimelineScreenStateError) _then;

/// Create a copy of TimelineScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
return _then(TimelineScreenStateError(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
));
}


}

// dart format on
