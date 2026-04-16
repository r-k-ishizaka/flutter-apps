// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'add_todo_effect_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AddTodoEffectState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddTodoEffectState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AddTodoEffectState()';
}


}

/// @nodoc
class $AddTodoEffectStateCopyWith<$Res>  {
$AddTodoEffectStateCopyWith(AddTodoEffectState _, $Res Function(AddTodoEffectState) __);
}


/// Adds pattern-matching-related methods to [AddTodoEffectState].
extension AddTodoEffectStatePatterns on AddTodoEffectState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AddTodoEffectNoneState value)?  none,TResult Function( AddTodoEffectSuccessState value)?  success,TResult Function( AddTodoEffectFailureState value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AddTodoEffectNoneState() when none != null:
return none(_that);case AddTodoEffectSuccessState() when success != null:
return success(_that);case AddTodoEffectFailureState() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AddTodoEffectNoneState value)  none,required TResult Function( AddTodoEffectSuccessState value)  success,required TResult Function( AddTodoEffectFailureState value)  failure,}){
final _that = this;
switch (_that) {
case AddTodoEffectNoneState():
return none(_that);case AddTodoEffectSuccessState():
return success(_that);case AddTodoEffectFailureState():
return failure(_that);case _:
  throw StateError('Unexpected subclass');

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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AddTodoEffectNoneState value)?  none,TResult? Function( AddTodoEffectSuccessState value)?  success,TResult? Function( AddTodoEffectFailureState value)?  failure,}){
final _that = this;
switch (_that) {
case AddTodoEffectNoneState() when none != null:
return none(_that);case AddTodoEffectSuccessState() when success != null:
return success(_that);case AddTodoEffectFailureState() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  none,TResult Function()?  success,TResult Function( String error)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AddTodoEffectNoneState() when none != null:
return none();case AddTodoEffectSuccessState() when success != null:
return success();case AddTodoEffectFailureState() when failure != null:
return failure(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  none,required TResult Function()  success,required TResult Function( String error)  failure,}) {final _that = this;
switch (_that) {
case AddTodoEffectNoneState():
return none();case AddTodoEffectSuccessState():
return success();case AddTodoEffectFailureState():
return failure(_that.error);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  none,TResult? Function()?  success,TResult? Function( String error)?  failure,}) {final _that = this;
switch (_that) {
case AddTodoEffectNoneState() when none != null:
return none();case AddTodoEffectSuccessState() when success != null:
return success();case AddTodoEffectFailureState() when failure != null:
return failure(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class AddTodoEffectNoneState implements AddTodoEffectState {
  const AddTodoEffectNoneState();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddTodoEffectNoneState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AddTodoEffectState.none()';
}


}




/// @nodoc


class AddTodoEffectSuccessState implements AddTodoEffectState {
  const AddTodoEffectSuccessState();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddTodoEffectSuccessState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AddTodoEffectState.success()';
}


}




/// @nodoc


class AddTodoEffectFailureState implements AddTodoEffectState {
  const AddTodoEffectFailureState(this.error);
  

 final  String error;

/// Create a copy of AddTodoEffectState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddTodoEffectFailureStateCopyWith<AddTodoEffectFailureState> get copyWith => _$AddTodoEffectFailureStateCopyWithImpl<AddTodoEffectFailureState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddTodoEffectFailureState&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'AddTodoEffectState.failure(error: $error)';
}


}

/// @nodoc
abstract mixin class $AddTodoEffectFailureStateCopyWith<$Res> implements $AddTodoEffectStateCopyWith<$Res> {
  factory $AddTodoEffectFailureStateCopyWith(AddTodoEffectFailureState value, $Res Function(AddTodoEffectFailureState) _then) = _$AddTodoEffectFailureStateCopyWithImpl;
@useResult
$Res call({
 String error
});




}
/// @nodoc
class _$AddTodoEffectFailureStateCopyWithImpl<$Res>
    implements $AddTodoEffectFailureStateCopyWith<$Res> {
  _$AddTodoEffectFailureStateCopyWithImpl(this._self, this._then);

  final AddTodoEffectFailureState _self;
  final $Res Function(AddTodoEffectFailureState) _then;

/// Create a copy of AddTodoEffectState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(AddTodoEffectFailureState(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
