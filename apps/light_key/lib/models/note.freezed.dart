// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Note {

 String get id; String get text;/// Contents Warning テキスト。null でない場合、本文・メディアを折りたたんで表示する。
 String? get cw; DateTime get createdAt; User get user; List<NoteFile> get files;@JsonKey(fromJson: _reactionsFromJson) Map<String, int> get reactions;/// 自分がつけたリアクション。未リアクションの場合は null。
 String? get myReaction;/// リノート元のノート。純粋リノート・引用リノートの場合に設定される。
 Note? get renote;/// 公開範囲
@JsonKey(fromJson: _visibilityFromJson) NoteVisibility get visibility;/// ローカルのみ（連合なし）
 bool get localOnly;
/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteCopyWith<Note> get copyWith => _$NoteCopyWithImpl<Note>(this as Note, _$identity);

  /// Serializes this Note to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Note&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.cw, cw) || other.cw == cw)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.user, user) || other.user == user)&&const DeepCollectionEquality().equals(other.files, files)&&const DeepCollectionEquality().equals(other.reactions, reactions)&&(identical(other.myReaction, myReaction) || other.myReaction == myReaction)&&(identical(other.renote, renote) || other.renote == renote)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.localOnly, localOnly) || other.localOnly == localOnly));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,text,cw,createdAt,user,const DeepCollectionEquality().hash(files),const DeepCollectionEquality().hash(reactions),myReaction,renote,visibility,localOnly);

@override
String toString() {
  return 'Note(id: $id, text: $text, cw: $cw, createdAt: $createdAt, user: $user, files: $files, reactions: $reactions, myReaction: $myReaction, renote: $renote, visibility: $visibility, localOnly: $localOnly)';
}


}

/// @nodoc
abstract mixin class $NoteCopyWith<$Res>  {
  factory $NoteCopyWith(Note value, $Res Function(Note) _then) = _$NoteCopyWithImpl;
@useResult
$Res call({
 String id, String text, String? cw, DateTime createdAt, User user, List<NoteFile> files,@JsonKey(fromJson: _reactionsFromJson) Map<String, int> reactions, String? myReaction, Note? renote,@JsonKey(fromJson: _visibilityFromJson) NoteVisibility visibility, bool localOnly
});


$UserCopyWith<$Res> get user;$NoteCopyWith<$Res>? get renote;

}
/// @nodoc
class _$NoteCopyWithImpl<$Res>
    implements $NoteCopyWith<$Res> {
  _$NoteCopyWithImpl(this._self, this._then);

  final Note _self;
  final $Res Function(Note) _then;

/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? text = null,Object? cw = freezed,Object? createdAt = null,Object? user = null,Object? files = null,Object? reactions = null,Object? myReaction = freezed,Object? renote = freezed,Object? visibility = null,Object? localOnly = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,cw: freezed == cw ? _self.cw : cw // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,files: null == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as List<NoteFile>,reactions: null == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as Map<String, int>,myReaction: freezed == myReaction ? _self.myReaction : myReaction // ignore: cast_nullable_to_non_nullable
as String?,renote: freezed == renote ? _self.renote : renote // ignore: cast_nullable_to_non_nullable
as Note?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as NoteVisibility,localOnly: null == localOnly ? _self.localOnly : localOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NoteCopyWith<$Res>? get renote {
    if (_self.renote == null) {
    return null;
  }

  return $NoteCopyWith<$Res>(_self.renote!, (value) {
    return _then(_self.copyWith(renote: value));
  });
}
}


/// Adds pattern-matching-related methods to [Note].
extension NotePatterns on Note {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Note value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Note() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Note value)  $default,){
final _that = this;
switch (_that) {
case _Note():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Note value)?  $default,){
final _that = this;
switch (_that) {
case _Note() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String text,  String? cw,  DateTime createdAt,  User user,  List<NoteFile> files, @JsonKey(fromJson: _reactionsFromJson)  Map<String, int> reactions,  String? myReaction,  Note? renote, @JsonKey(fromJson: _visibilityFromJson)  NoteVisibility visibility,  bool localOnly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Note() when $default != null:
return $default(_that.id,_that.text,_that.cw,_that.createdAt,_that.user,_that.files,_that.reactions,_that.myReaction,_that.renote,_that.visibility,_that.localOnly);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String text,  String? cw,  DateTime createdAt,  User user,  List<NoteFile> files, @JsonKey(fromJson: _reactionsFromJson)  Map<String, int> reactions,  String? myReaction,  Note? renote, @JsonKey(fromJson: _visibilityFromJson)  NoteVisibility visibility,  bool localOnly)  $default,) {final _that = this;
switch (_that) {
case _Note():
return $default(_that.id,_that.text,_that.cw,_that.createdAt,_that.user,_that.files,_that.reactions,_that.myReaction,_that.renote,_that.visibility,_that.localOnly);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String text,  String? cw,  DateTime createdAt,  User user,  List<NoteFile> files, @JsonKey(fromJson: _reactionsFromJson)  Map<String, int> reactions,  String? myReaction,  Note? renote, @JsonKey(fromJson: _visibilityFromJson)  NoteVisibility visibility,  bool localOnly)?  $default,) {final _that = this;
switch (_that) {
case _Note() when $default != null:
return $default(_that.id,_that.text,_that.cw,_that.createdAt,_that.user,_that.files,_that.reactions,_that.myReaction,_that.renote,_that.visibility,_that.localOnly);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Note extends Note {
  const _Note({this.id = '', this.text = '', this.cw, required this.createdAt, required this.user, final  List<NoteFile> files = const <NoteFile>[], @JsonKey(fromJson: _reactionsFromJson) final  Map<String, int> reactions = const <String, int>{}, this.myReaction, this.renote, @JsonKey(fromJson: _visibilityFromJson) this.visibility = NoteVisibility.public, this.localOnly = false}): _files = files,_reactions = reactions,super._();
  factory _Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String text;
/// Contents Warning テキスト。null でない場合、本文・メディアを折りたたんで表示する。
@override final  String? cw;
@override final  DateTime createdAt;
@override final  User user;
 final  List<NoteFile> _files;
@override@JsonKey() List<NoteFile> get files {
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_files);
}

 final  Map<String, int> _reactions;
@override@JsonKey(fromJson: _reactionsFromJson) Map<String, int> get reactions {
  if (_reactions is EqualUnmodifiableMapView) return _reactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_reactions);
}

/// 自分がつけたリアクション。未リアクションの場合は null。
@override final  String? myReaction;
/// リノート元のノート。純粋リノート・引用リノートの場合に設定される。
@override final  Note? renote;
/// 公開範囲
@override@JsonKey(fromJson: _visibilityFromJson) final  NoteVisibility visibility;
/// ローカルのみ（連合なし）
@override@JsonKey() final  bool localOnly;

/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NoteCopyWith<_Note> get copyWith => __$NoteCopyWithImpl<_Note>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NoteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Note&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.cw, cw) || other.cw == cw)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.user, user) || other.user == user)&&const DeepCollectionEquality().equals(other._files, _files)&&const DeepCollectionEquality().equals(other._reactions, _reactions)&&(identical(other.myReaction, myReaction) || other.myReaction == myReaction)&&(identical(other.renote, renote) || other.renote == renote)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.localOnly, localOnly) || other.localOnly == localOnly));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,text,cw,createdAt,user,const DeepCollectionEquality().hash(_files),const DeepCollectionEquality().hash(_reactions),myReaction,renote,visibility,localOnly);

@override
String toString() {
  return 'Note(id: $id, text: $text, cw: $cw, createdAt: $createdAt, user: $user, files: $files, reactions: $reactions, myReaction: $myReaction, renote: $renote, visibility: $visibility, localOnly: $localOnly)';
}


}

/// @nodoc
abstract mixin class _$NoteCopyWith<$Res> implements $NoteCopyWith<$Res> {
  factory _$NoteCopyWith(_Note value, $Res Function(_Note) _then) = __$NoteCopyWithImpl;
@override @useResult
$Res call({
 String id, String text, String? cw, DateTime createdAt, User user, List<NoteFile> files,@JsonKey(fromJson: _reactionsFromJson) Map<String, int> reactions, String? myReaction, Note? renote,@JsonKey(fromJson: _visibilityFromJson) NoteVisibility visibility, bool localOnly
});


@override $UserCopyWith<$Res> get user;@override $NoteCopyWith<$Res>? get renote;

}
/// @nodoc
class __$NoteCopyWithImpl<$Res>
    implements _$NoteCopyWith<$Res> {
  __$NoteCopyWithImpl(this._self, this._then);

  final _Note _self;
  final $Res Function(_Note) _then;

/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,Object? cw = freezed,Object? createdAt = null,Object? user = null,Object? files = null,Object? reactions = null,Object? myReaction = freezed,Object? renote = freezed,Object? visibility = null,Object? localOnly = null,}) {
  return _then(_Note(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,cw: freezed == cw ? _self.cw : cw // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<NoteFile>,reactions: null == reactions ? _self._reactions : reactions // ignore: cast_nullable_to_non_nullable
as Map<String, int>,myReaction: freezed == myReaction ? _self.myReaction : myReaction // ignore: cast_nullable_to_non_nullable
as String?,renote: freezed == renote ? _self.renote : renote // ignore: cast_nullable_to_non_nullable
as Note?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as NoteVisibility,localOnly: null == localOnly ? _self.localOnly : localOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NoteCopyWith<$Res>? get renote {
    if (_self.renote == null) {
    return null;
  }

  return $NoteCopyWith<$Res>(_self.renote!, (value) {
    return _then(_self.copyWith(renote: value));
  });
}
}

// dart format on
