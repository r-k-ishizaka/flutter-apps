// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note_file.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NoteFile {

 String get id; String get type; String? get thumbnailUrl; String get url; String? get blurhash; bool get isSensitive; NoteFileProperties? get properties;
/// Create a copy of NoteFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteFileCopyWith<NoteFile> get copyWith => _$NoteFileCopyWithImpl<NoteFile>(this as NoteFile, _$identity);

  /// Serializes this NoteFile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoteFile&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.url, url) || other.url == url)&&(identical(other.blurhash, blurhash) || other.blurhash == blurhash)&&(identical(other.isSensitive, isSensitive) || other.isSensitive == isSensitive)&&(identical(other.properties, properties) || other.properties == properties));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,thumbnailUrl,url,blurhash,isSensitive,properties);

@override
String toString() {
  return 'NoteFile(id: $id, type: $type, thumbnailUrl: $thumbnailUrl, url: $url, blurhash: $blurhash, isSensitive: $isSensitive, properties: $properties)';
}


}

/// @nodoc
abstract mixin class $NoteFileCopyWith<$Res>  {
  factory $NoteFileCopyWith(NoteFile value, $Res Function(NoteFile) _then) = _$NoteFileCopyWithImpl;
@useResult
$Res call({
 String id, String type, String? thumbnailUrl, String url, String? blurhash, bool isSensitive, NoteFileProperties? properties
});


$NoteFilePropertiesCopyWith<$Res>? get properties;

}
/// @nodoc
class _$NoteFileCopyWithImpl<$Res>
    implements $NoteFileCopyWith<$Res> {
  _$NoteFileCopyWithImpl(this._self, this._then);

  final NoteFile _self;
  final $Res Function(NoteFile) _then;

/// Create a copy of NoteFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? thumbnailUrl = freezed,Object? url = null,Object? blurhash = freezed,Object? isSensitive = null,Object? properties = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,blurhash: freezed == blurhash ? _self.blurhash : blurhash // ignore: cast_nullable_to_non_nullable
as String?,isSensitive: null == isSensitive ? _self.isSensitive : isSensitive // ignore: cast_nullable_to_non_nullable
as bool,properties: freezed == properties ? _self.properties : properties // ignore: cast_nullable_to_non_nullable
as NoteFileProperties?,
  ));
}
/// Create a copy of NoteFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NoteFilePropertiesCopyWith<$Res>? get properties {
    if (_self.properties == null) {
    return null;
  }

  return $NoteFilePropertiesCopyWith<$Res>(_self.properties!, (value) {
    return _then(_self.copyWith(properties: value));
  });
}
}


/// Adds pattern-matching-related methods to [NoteFile].
extension NoteFilePatterns on NoteFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NoteFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NoteFile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NoteFile value)  $default,){
final _that = this;
switch (_that) {
case _NoteFile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NoteFile value)?  $default,){
final _that = this;
switch (_that) {
case _NoteFile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String? thumbnailUrl,  String url,  String? blurhash,  bool isSensitive,  NoteFileProperties? properties)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NoteFile() when $default != null:
return $default(_that.id,_that.type,_that.thumbnailUrl,_that.url,_that.blurhash,_that.isSensitive,_that.properties);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String? thumbnailUrl,  String url,  String? blurhash,  bool isSensitive,  NoteFileProperties? properties)  $default,) {final _that = this;
switch (_that) {
case _NoteFile():
return $default(_that.id,_that.type,_that.thumbnailUrl,_that.url,_that.blurhash,_that.isSensitive,_that.properties);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String? thumbnailUrl,  String url,  String? blurhash,  bool isSensitive,  NoteFileProperties? properties)?  $default,) {final _that = this;
switch (_that) {
case _NoteFile() when $default != null:
return $default(_that.id,_that.type,_that.thumbnailUrl,_that.url,_that.blurhash,_that.isSensitive,_that.properties);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NoteFile extends NoteFile {
  const _NoteFile({this.id = '', this.type = '', this.thumbnailUrl, this.url = '', this.blurhash, this.isSensitive = false, this.properties}): super._();
  factory _NoteFile.fromJson(Map<String, dynamic> json) => _$NoteFileFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String type;
@override final  String? thumbnailUrl;
@override@JsonKey() final  String url;
@override final  String? blurhash;
@override@JsonKey() final  bool isSensitive;
@override final  NoteFileProperties? properties;

/// Create a copy of NoteFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NoteFileCopyWith<_NoteFile> get copyWith => __$NoteFileCopyWithImpl<_NoteFile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NoteFileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NoteFile&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.url, url) || other.url == url)&&(identical(other.blurhash, blurhash) || other.blurhash == blurhash)&&(identical(other.isSensitive, isSensitive) || other.isSensitive == isSensitive)&&(identical(other.properties, properties) || other.properties == properties));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,thumbnailUrl,url,blurhash,isSensitive,properties);

@override
String toString() {
  return 'NoteFile(id: $id, type: $type, thumbnailUrl: $thumbnailUrl, url: $url, blurhash: $blurhash, isSensitive: $isSensitive, properties: $properties)';
}


}

/// @nodoc
abstract mixin class _$NoteFileCopyWith<$Res> implements $NoteFileCopyWith<$Res> {
  factory _$NoteFileCopyWith(_NoteFile value, $Res Function(_NoteFile) _then) = __$NoteFileCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String? thumbnailUrl, String url, String? blurhash, bool isSensitive, NoteFileProperties? properties
});


@override $NoteFilePropertiesCopyWith<$Res>? get properties;

}
/// @nodoc
class __$NoteFileCopyWithImpl<$Res>
    implements _$NoteFileCopyWith<$Res> {
  __$NoteFileCopyWithImpl(this._self, this._then);

  final _NoteFile _self;
  final $Res Function(_NoteFile) _then;

/// Create a copy of NoteFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? thumbnailUrl = freezed,Object? url = null,Object? blurhash = freezed,Object? isSensitive = null,Object? properties = freezed,}) {
  return _then(_NoteFile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,blurhash: freezed == blurhash ? _self.blurhash : blurhash // ignore: cast_nullable_to_non_nullable
as String?,isSensitive: null == isSensitive ? _self.isSensitive : isSensitive // ignore: cast_nullable_to_non_nullable
as bool,properties: freezed == properties ? _self.properties : properties // ignore: cast_nullable_to_non_nullable
as NoteFileProperties?,
  ));
}

/// Create a copy of NoteFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NoteFilePropertiesCopyWith<$Res>? get properties {
    if (_self.properties == null) {
    return null;
  }

  return $NoteFilePropertiesCopyWith<$Res>(_self.properties!, (value) {
    return _then(_self.copyWith(properties: value));
  });
}
}

// dart format on
