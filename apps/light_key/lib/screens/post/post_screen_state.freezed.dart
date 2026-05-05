// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_screen_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostScreenState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostScreenState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PostScreenState()';
}


}

/// @nodoc
class $PostScreenStateCopyWith<$Res>  {
$PostScreenStateCopyWith(PostScreenState _, $Res Function(PostScreenState) __);
}


/// Adds pattern-matching-related methods to [PostScreenState].
extension PostScreenStatePatterns on PostScreenState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PostScreenStateIdle value)?  idle,TResult Function( PostScreenStateSubmitting value)?  submitting,TResult Function( PostScreenStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PostScreenStateIdle() when idle != null:
return idle(_that);case PostScreenStateSubmitting() when submitting != null:
return submitting(_that);case PostScreenStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PostScreenStateIdle value)  idle,required TResult Function( PostScreenStateSubmitting value)  submitting,required TResult Function( PostScreenStateError value)  error,}){
final _that = this;
switch (_that) {
case PostScreenStateIdle():
return idle(_that);case PostScreenStateSubmitting():
return submitting(_that);case PostScreenStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PostScreenStateIdle value)?  idle,TResult? Function( PostScreenStateSubmitting value)?  submitting,TResult? Function( PostScreenStateError value)?  error,}){
final _that = this;
switch (_that) {
case PostScreenStateIdle() when idle != null:
return idle(_that);case PostScreenStateSubmitting() when submitting != null:
return submitting(_that);case PostScreenStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  submitting,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PostScreenStateIdle() when idle != null:
return idle();case PostScreenStateSubmitting() when submitting != null:
return submitting();case PostScreenStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  submitting,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case PostScreenStateIdle():
return idle();case PostScreenStateSubmitting():
return submitting();case PostScreenStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  submitting,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case PostScreenStateIdle() when idle != null:
return idle();case PostScreenStateSubmitting() when submitting != null:
return submitting();case PostScreenStateError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class PostScreenStateIdle implements PostScreenState {
  const PostScreenStateIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostScreenStateIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PostScreenState.idle()';
}


}




/// @nodoc


class PostScreenStateSubmitting implements PostScreenState {
  const PostScreenStateSubmitting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostScreenStateSubmitting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PostScreenState.submitting()';
}


}




/// @nodoc


class PostScreenStateError implements PostScreenState {
  const PostScreenStateError({required this.message});
  

 final  String message;

/// Create a copy of PostScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostScreenStateErrorCopyWith<PostScreenStateError> get copyWith => _$PostScreenStateErrorCopyWithImpl<PostScreenStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostScreenStateError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'PostScreenState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $PostScreenStateErrorCopyWith<$Res> implements $PostScreenStateCopyWith<$Res> {
  factory $PostScreenStateErrorCopyWith(PostScreenStateError value, $Res Function(PostScreenStateError) _then) = _$PostScreenStateErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$PostScreenStateErrorCopyWithImpl<$Res>
    implements $PostScreenStateErrorCopyWith<$Res> {
  _$PostScreenStateErrorCopyWithImpl(this._self, this._then);

  final PostScreenStateError _self;
  final $Res Function(PostScreenStateError) _then;

/// Create a copy of PostScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(PostScreenStateError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
