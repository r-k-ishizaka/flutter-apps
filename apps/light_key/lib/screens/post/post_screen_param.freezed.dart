// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_screen_param.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostScreenParam {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostScreenParam);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PostScreenParam()';
}


}

/// @nodoc
class $PostScreenParamCopyWith<$Res>  {
$PostScreenParamCopyWith(PostScreenParam _, $Res Function(PostScreenParam) __);
}


/// Adds pattern-matching-related methods to [PostScreenParam].
extension PostScreenParamPatterns on PostScreenParam {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PostScreenParamNormal value)?  normal,TResult Function( PostScreenParamReply value)?  reply,TResult Function( PostScreenParamQuote value)?  quote,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PostScreenParamNormal() when normal != null:
return normal(_that);case PostScreenParamReply() when reply != null:
return reply(_that);case PostScreenParamQuote() when quote != null:
return quote(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PostScreenParamNormal value)  normal,required TResult Function( PostScreenParamReply value)  reply,required TResult Function( PostScreenParamQuote value)  quote,}){
final _that = this;
switch (_that) {
case PostScreenParamNormal():
return normal(_that);case PostScreenParamReply():
return reply(_that);case PostScreenParamQuote():
return quote(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PostScreenParamNormal value)?  normal,TResult? Function( PostScreenParamReply value)?  reply,TResult? Function( PostScreenParamQuote value)?  quote,}){
final _that = this;
switch (_that) {
case PostScreenParamNormal() when normal != null:
return normal(_that);case PostScreenParamReply() when reply != null:
return reply(_that);case PostScreenParamQuote() when quote != null:
return quote(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  normal,TResult Function( String targetId,  String userName,  String displayName,  String text,  String? avatarUrl)?  reply,TResult Function( String targetId,  String userName,  String displayName,  String text,  String? avatarUrl)?  quote,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PostScreenParamNormal() when normal != null:
return normal();case PostScreenParamReply() when reply != null:
return reply(_that.targetId,_that.userName,_that.displayName,_that.text,_that.avatarUrl);case PostScreenParamQuote() when quote != null:
return quote(_that.targetId,_that.userName,_that.displayName,_that.text,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  normal,required TResult Function( String targetId,  String userName,  String displayName,  String text,  String? avatarUrl)  reply,required TResult Function( String targetId,  String userName,  String displayName,  String text,  String? avatarUrl)  quote,}) {final _that = this;
switch (_that) {
case PostScreenParamNormal():
return normal();case PostScreenParamReply():
return reply(_that.targetId,_that.userName,_that.displayName,_that.text,_that.avatarUrl);case PostScreenParamQuote():
return quote(_that.targetId,_that.userName,_that.displayName,_that.text,_that.avatarUrl);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  normal,TResult? Function( String targetId,  String userName,  String displayName,  String text,  String? avatarUrl)?  reply,TResult? Function( String targetId,  String userName,  String displayName,  String text,  String? avatarUrl)?  quote,}) {final _that = this;
switch (_that) {
case PostScreenParamNormal() when normal != null:
return normal();case PostScreenParamReply() when reply != null:
return reply(_that.targetId,_that.userName,_that.displayName,_that.text,_that.avatarUrl);case PostScreenParamQuote() when quote != null:
return quote(_that.targetId,_that.userName,_that.displayName,_that.text,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc


class PostScreenParamNormal implements PostScreenParam {
  const PostScreenParamNormal();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostScreenParamNormal);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PostScreenParam.normal()';
}


}




/// @nodoc


class PostScreenParamReply implements PostScreenParam {
  const PostScreenParamReply({required this.targetId, required this.userName, required this.displayName, required this.text, this.avatarUrl});
  

 final  String targetId;
 final  String userName;
 final  String displayName;
 final  String text;
 final  String? avatarUrl;

/// Create a copy of PostScreenParam
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostScreenParamReplyCopyWith<PostScreenParamReply> get copyWith => _$PostScreenParamReplyCopyWithImpl<PostScreenParamReply>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostScreenParamReply&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.text, text) || other.text == text)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}


@override
int get hashCode => Object.hash(runtimeType,targetId,userName,displayName,text,avatarUrl);

@override
String toString() {
  return 'PostScreenParam.reply(targetId: $targetId, userName: $userName, displayName: $displayName, text: $text, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $PostScreenParamReplyCopyWith<$Res> implements $PostScreenParamCopyWith<$Res> {
  factory $PostScreenParamReplyCopyWith(PostScreenParamReply value, $Res Function(PostScreenParamReply) _then) = _$PostScreenParamReplyCopyWithImpl;
@useResult
$Res call({
 String targetId, String userName, String displayName, String text, String? avatarUrl
});




}
/// @nodoc
class _$PostScreenParamReplyCopyWithImpl<$Res>
    implements $PostScreenParamReplyCopyWith<$Res> {
  _$PostScreenParamReplyCopyWithImpl(this._self, this._then);

  final PostScreenParamReply _self;
  final $Res Function(PostScreenParamReply) _then;

/// Create a copy of PostScreenParam
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? targetId = null,Object? userName = null,Object? displayName = null,Object? text = null,Object? avatarUrl = freezed,}) {
  return _then(PostScreenParamReply(
targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class PostScreenParamQuote implements PostScreenParam {
  const PostScreenParamQuote({required this.targetId, required this.userName, required this.displayName, required this.text, this.avatarUrl});
  

 final  String targetId;
 final  String userName;
 final  String displayName;
 final  String text;
 final  String? avatarUrl;

/// Create a copy of PostScreenParam
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostScreenParamQuoteCopyWith<PostScreenParamQuote> get copyWith => _$PostScreenParamQuoteCopyWithImpl<PostScreenParamQuote>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostScreenParamQuote&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.text, text) || other.text == text)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}


@override
int get hashCode => Object.hash(runtimeType,targetId,userName,displayName,text,avatarUrl);

@override
String toString() {
  return 'PostScreenParam.quote(targetId: $targetId, userName: $userName, displayName: $displayName, text: $text, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $PostScreenParamQuoteCopyWith<$Res> implements $PostScreenParamCopyWith<$Res> {
  factory $PostScreenParamQuoteCopyWith(PostScreenParamQuote value, $Res Function(PostScreenParamQuote) _then) = _$PostScreenParamQuoteCopyWithImpl;
@useResult
$Res call({
 String targetId, String userName, String displayName, String text, String? avatarUrl
});




}
/// @nodoc
class _$PostScreenParamQuoteCopyWithImpl<$Res>
    implements $PostScreenParamQuoteCopyWith<$Res> {
  _$PostScreenParamQuoteCopyWithImpl(this._self, this._then);

  final PostScreenParamQuote _self;
  final $Res Function(PostScreenParamQuote) _then;

/// Create a copy of PostScreenParam
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? targetId = null,Object? userName = null,Object? displayName = null,Object? text = null,Object? avatarUrl = freezed,}) {
  return _then(PostScreenParamQuote(
targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
