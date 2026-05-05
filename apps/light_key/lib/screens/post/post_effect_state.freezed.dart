// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_effect_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostEffectState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostEffectState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PostEffectState()';
}


}

/// @nodoc
class $PostEffectStateCopyWith<$Res>  {
$PostEffectStateCopyWith(PostEffectState _, $Res Function(PostEffectState) __);
}


/// Adds pattern-matching-related methods to [PostEffectState].
extension PostEffectStatePatterns on PostEffectState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PostEffectStateNone value)?  none,TResult Function( PostEffectStateCloseWithMessage value)?  closeWithMessage,TResult Function( PostEffectStateShowError value)?  showError,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PostEffectStateNone() when none != null:
return none(_that);case PostEffectStateCloseWithMessage() when closeWithMessage != null:
return closeWithMessage(_that);case PostEffectStateShowError() when showError != null:
return showError(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PostEffectStateNone value)  none,required TResult Function( PostEffectStateCloseWithMessage value)  closeWithMessage,required TResult Function( PostEffectStateShowError value)  showError,}){
final _that = this;
switch (_that) {
case PostEffectStateNone():
return none(_that);case PostEffectStateCloseWithMessage():
return closeWithMessage(_that);case PostEffectStateShowError():
return showError(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PostEffectStateNone value)?  none,TResult? Function( PostEffectStateCloseWithMessage value)?  closeWithMessage,TResult? Function( PostEffectStateShowError value)?  showError,}){
final _that = this;
switch (_that) {
case PostEffectStateNone() when none != null:
return none(_that);case PostEffectStateCloseWithMessage() when closeWithMessage != null:
return closeWithMessage(_that);case PostEffectStateShowError() when showError != null:
return showError(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  none,TResult Function( String message)?  closeWithMessage,TResult Function( String message)?  showError,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PostEffectStateNone() when none != null:
return none();case PostEffectStateCloseWithMessage() when closeWithMessage != null:
return closeWithMessage(_that.message);case PostEffectStateShowError() when showError != null:
return showError(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  none,required TResult Function( String message)  closeWithMessage,required TResult Function( String message)  showError,}) {final _that = this;
switch (_that) {
case PostEffectStateNone():
return none();case PostEffectStateCloseWithMessage():
return closeWithMessage(_that.message);case PostEffectStateShowError():
return showError(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  none,TResult? Function( String message)?  closeWithMessage,TResult? Function( String message)?  showError,}) {final _that = this;
switch (_that) {
case PostEffectStateNone() when none != null:
return none();case PostEffectStateCloseWithMessage() when closeWithMessage != null:
return closeWithMessage(_that.message);case PostEffectStateShowError() when showError != null:
return showError(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class PostEffectStateNone implements PostEffectState {
  const PostEffectStateNone();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostEffectStateNone);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PostEffectState.none()';
}


}




/// @nodoc


class PostEffectStateCloseWithMessage implements PostEffectState {
  const PostEffectStateCloseWithMessage(this.message);
  

 final  String message;

/// Create a copy of PostEffectState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostEffectStateCloseWithMessageCopyWith<PostEffectStateCloseWithMessage> get copyWith => _$PostEffectStateCloseWithMessageCopyWithImpl<PostEffectStateCloseWithMessage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostEffectStateCloseWithMessage&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'PostEffectState.closeWithMessage(message: $message)';
}


}

/// @nodoc
abstract mixin class $PostEffectStateCloseWithMessageCopyWith<$Res> implements $PostEffectStateCopyWith<$Res> {
  factory $PostEffectStateCloseWithMessageCopyWith(PostEffectStateCloseWithMessage value, $Res Function(PostEffectStateCloseWithMessage) _then) = _$PostEffectStateCloseWithMessageCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$PostEffectStateCloseWithMessageCopyWithImpl<$Res>
    implements $PostEffectStateCloseWithMessageCopyWith<$Res> {
  _$PostEffectStateCloseWithMessageCopyWithImpl(this._self, this._then);

  final PostEffectStateCloseWithMessage _self;
  final $Res Function(PostEffectStateCloseWithMessage) _then;

/// Create a copy of PostEffectState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(PostEffectStateCloseWithMessage(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PostEffectStateShowError implements PostEffectState {
  const PostEffectStateShowError(this.message);
  

 final  String message;

/// Create a copy of PostEffectState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostEffectStateShowErrorCopyWith<PostEffectStateShowError> get copyWith => _$PostEffectStateShowErrorCopyWithImpl<PostEffectStateShowError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostEffectStateShowError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'PostEffectState.showError(message: $message)';
}


}

/// @nodoc
abstract mixin class $PostEffectStateShowErrorCopyWith<$Res> implements $PostEffectStateCopyWith<$Res> {
  factory $PostEffectStateShowErrorCopyWith(PostEffectStateShowError value, $Res Function(PostEffectStateShowError) _then) = _$PostEffectStateShowErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$PostEffectStateShowErrorCopyWithImpl<$Res>
    implements $PostEffectStateShowErrorCopyWith<$Res> {
  _$PostEffectStateShowErrorCopyWithImpl(this._self, this._then);

  final PostEffectStateShowError _self;
  final $Res Function(PostEffectStateShowError) _then;

/// Create a copy of PostEffectState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(PostEffectStateShowError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
