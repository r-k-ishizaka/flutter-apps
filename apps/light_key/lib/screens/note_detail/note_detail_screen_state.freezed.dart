// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note_detail_screen_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NoteDetailScreenState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoteDetailScreenState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NoteDetailScreenState()';
}


}

/// @nodoc
class $NoteDetailScreenStateCopyWith<$Res>  {
$NoteDetailScreenStateCopyWith(NoteDetailScreenState _, $Res Function(NoteDetailScreenState) __);
}


/// Adds pattern-matching-related methods to [NoteDetailScreenState].
extension NoteDetailScreenStatePatterns on NoteDetailScreenState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NoteDetailScreenStateIdle value)?  idle,TResult Function( NoteDetailScreenStateLoading value)?  loading,TResult Function( NoteDetailScreenStateLoaded value)?  loaded,TResult Function( NoteDetailScreenStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NoteDetailScreenStateIdle() when idle != null:
return idle(_that);case NoteDetailScreenStateLoading() when loading != null:
return loading(_that);case NoteDetailScreenStateLoaded() when loaded != null:
return loaded(_that);case NoteDetailScreenStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NoteDetailScreenStateIdle value)  idle,required TResult Function( NoteDetailScreenStateLoading value)  loading,required TResult Function( NoteDetailScreenStateLoaded value)  loaded,required TResult Function( NoteDetailScreenStateError value)  error,}){
final _that = this;
switch (_that) {
case NoteDetailScreenStateIdle():
return idle(_that);case NoteDetailScreenStateLoading():
return loading(_that);case NoteDetailScreenStateLoaded():
return loaded(_that);case NoteDetailScreenStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NoteDetailScreenStateIdle value)?  idle,TResult? Function( NoteDetailScreenStateLoading value)?  loading,TResult? Function( NoteDetailScreenStateLoaded value)?  loaded,TResult? Function( NoteDetailScreenStateError value)?  error,}){
final _that = this;
switch (_that) {
case NoteDetailScreenStateIdle() when idle != null:
return idle(_that);case NoteDetailScreenStateLoading() when loading != null:
return loading(_that);case NoteDetailScreenStateLoaded() when loaded != null:
return loaded(_that);case NoteDetailScreenStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  loading,TResult Function( Note note,  String? message)?  loaded,TResult Function( String? message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NoteDetailScreenStateIdle() when idle != null:
return idle();case NoteDetailScreenStateLoading() when loading != null:
return loading();case NoteDetailScreenStateLoaded() when loaded != null:
return loaded(_that.note,_that.message);case NoteDetailScreenStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  loading,required TResult Function( Note note,  String? message)  loaded,required TResult Function( String? message)  error,}) {final _that = this;
switch (_that) {
case NoteDetailScreenStateIdle():
return idle();case NoteDetailScreenStateLoading():
return loading();case NoteDetailScreenStateLoaded():
return loaded(_that.note,_that.message);case NoteDetailScreenStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  loading,TResult? Function( Note note,  String? message)?  loaded,TResult? Function( String? message)?  error,}) {final _that = this;
switch (_that) {
case NoteDetailScreenStateIdle() when idle != null:
return idle();case NoteDetailScreenStateLoading() when loading != null:
return loading();case NoteDetailScreenStateLoaded() when loaded != null:
return loaded(_that.note,_that.message);case NoteDetailScreenStateError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class NoteDetailScreenStateIdle implements NoteDetailScreenState {
  const NoteDetailScreenStateIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoteDetailScreenStateIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NoteDetailScreenState.idle()';
}


}




/// @nodoc


class NoteDetailScreenStateLoading implements NoteDetailScreenState {
  const NoteDetailScreenStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoteDetailScreenStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NoteDetailScreenState.loading()';
}


}




/// @nodoc


class NoteDetailScreenStateLoaded implements NoteDetailScreenState {
  const NoteDetailScreenStateLoaded({required this.note, this.message});
  

 final  Note note;
 final  String? message;

/// Create a copy of NoteDetailScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteDetailScreenStateLoadedCopyWith<NoteDetailScreenStateLoaded> get copyWith => _$NoteDetailScreenStateLoadedCopyWithImpl<NoteDetailScreenStateLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoteDetailScreenStateLoaded&&(identical(other.note, note) || other.note == note)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,note,message);

@override
String toString() {
  return 'NoteDetailScreenState.loaded(note: $note, message: $message)';
}


}

/// @nodoc
abstract mixin class $NoteDetailScreenStateLoadedCopyWith<$Res> implements $NoteDetailScreenStateCopyWith<$Res> {
  factory $NoteDetailScreenStateLoadedCopyWith(NoteDetailScreenStateLoaded value, $Res Function(NoteDetailScreenStateLoaded) _then) = _$NoteDetailScreenStateLoadedCopyWithImpl;
@useResult
$Res call({
 Note note, String? message
});


$NoteCopyWith<$Res> get note;

}
/// @nodoc
class _$NoteDetailScreenStateLoadedCopyWithImpl<$Res>
    implements $NoteDetailScreenStateLoadedCopyWith<$Res> {
  _$NoteDetailScreenStateLoadedCopyWithImpl(this._self, this._then);

  final NoteDetailScreenStateLoaded _self;
  final $Res Function(NoteDetailScreenStateLoaded) _then;

/// Create a copy of NoteDetailScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? note = null,Object? message = freezed,}) {
  return _then(NoteDetailScreenStateLoaded(
note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as Note,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of NoteDetailScreenState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NoteCopyWith<$Res> get note {
  
  return $NoteCopyWith<$Res>(_self.note, (value) {
    return _then(_self.copyWith(note: value));
  });
}
}

/// @nodoc


class NoteDetailScreenStateError implements NoteDetailScreenState {
  const NoteDetailScreenStateError({this.message});
  

 final  String? message;

/// Create a copy of NoteDetailScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteDetailScreenStateErrorCopyWith<NoteDetailScreenStateError> get copyWith => _$NoteDetailScreenStateErrorCopyWithImpl<NoteDetailScreenStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoteDetailScreenStateError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'NoteDetailScreenState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $NoteDetailScreenStateErrorCopyWith<$Res> implements $NoteDetailScreenStateCopyWith<$Res> {
  factory $NoteDetailScreenStateErrorCopyWith(NoteDetailScreenStateError value, $Res Function(NoteDetailScreenStateError) _then) = _$NoteDetailScreenStateErrorCopyWithImpl;
@useResult
$Res call({
 String? message
});




}
/// @nodoc
class _$NoteDetailScreenStateErrorCopyWithImpl<$Res>
    implements $NoteDetailScreenStateErrorCopyWith<$Res> {
  _$NoteDetailScreenStateErrorCopyWithImpl(this._self, this._then);

  final NoteDetailScreenStateError _self;
  final $Res Function(NoteDetailScreenStateError) _then;

/// Create a copy of NoteDetailScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(NoteDetailScreenStateError(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
