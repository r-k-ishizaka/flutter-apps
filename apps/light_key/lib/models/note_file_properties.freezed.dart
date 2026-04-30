// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note_file_properties.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NoteFileProperties {

  @JsonKey(fromJson: _intFromJson) int get width;

  @JsonKey(fromJson: _intFromJson) int get height;

  /// Create a copy of NoteFileProperties
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NoteFilePropertiesCopyWith<NoteFileProperties> get copyWith =>
      _$NoteFilePropertiesCopyWithImpl<NoteFileProperties>(
          this as NoteFileProperties, _$identity);

  /// Serializes this NoteFileProperties to a JSON map.
  Map<String, dynamic> toJson();


  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is NoteFileProperties &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, width, height);

  @override
  String toString() {
    return 'NoteFileProperties(width: $width, height: $height)';
  }


}

/// @nodoc
abstract mixin class $NoteFilePropertiesCopyWith<$Res> {
  factory $NoteFilePropertiesCopyWith(NoteFileProperties value,
      $Res Function(NoteFileProperties) _then) = _$NoteFilePropertiesCopyWithImpl;

  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int width, @JsonKey(
        fromJson: _intFromJson) int height
  });


}

/// @nodoc
class _$NoteFilePropertiesCopyWithImpl<$Res>
    implements $NoteFilePropertiesCopyWith<$Res> {
  _$NoteFilePropertiesCopyWithImpl(this._self, this._then);

  final NoteFileProperties _self;
  final $Res Function(NoteFileProperties) _then;

  /// Create a copy of NoteFileProperties
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? width = null, Object? height = null,}) {
    return _then(_self.copyWith(
      width: null == width
          ? _self.width
          : width // ignore: cast_nullable_to_non_nullable
      as int,
      height: null == height
          ? _self.height
          : height // ignore: cast_nullable_to_non_nullable
      as int,
    ));
  }

}


/// Adds pattern-matching-related methods to [NoteFileProperties].
extension NoteFilePropertiesPatterns on NoteFileProperties {
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

  TResult Function( _NoteFileProperties value)? $default,{required TResult orElse(),}){
  final _that = this;
  switch (_that) {
  case _NoteFileProperties() when $default != null:
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

  @optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NoteFileProperties value) $default,){
  final _that = this;
  switch (_that) {
  case _NoteFileProperties():
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

  @optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NoteFileProperties value)? $default,){
  final _that = this;
  switch (_that) {
  case _NoteFileProperties() when $default != null:
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

  @optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _intFromJson) int width, @JsonKey(fromJson: _intFromJson) int height)? $default,{required TResult orElse(),}) {final _that = this;
  switch (_that) {
  case _NoteFileProperties() when $default != null:
  return $default(_that.width,_that.height);case _:
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

  @optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _intFromJson) int width, @JsonKey(fromJson: _intFromJson) int height) $default,) {final _that = this;
  switch (_that) {
  case _NoteFileProperties():
  return $default(_that.width,_that.height);}
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

  @optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _intFromJson) int width, @JsonKey(fromJson: _intFromJson) int height)? $default,) {final _that = this;
  switch (_that) {
  case _NoteFileProperties() when $default != null:
  return $default(_that.width,_that.height);case _:
  return null;

  }
  }

}

/// @nodoc
@JsonSerializable()
class _NoteFileProperties implements NoteFileProperties {
  const _NoteFileProperties(
      {@JsonKey(fromJson: _intFromJson) this.width = 0, @JsonKey(
          fromJson: _intFromJson) this.height = 0});

  factory _NoteFileProperties.fromJson(Map<String, dynamic> json) =>
      _$NoteFilePropertiesFromJson(json);

  @override
  @JsonKey(fromJson: _intFromJson)
  final int width;
  @override
  @JsonKey(fromJson: _intFromJson)
  final int height;

  /// Create a copy of NoteFileProperties
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NoteFilePropertiesCopyWith<_NoteFileProperties> get copyWith =>
      __$NoteFilePropertiesCopyWithImpl<_NoteFileProperties>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$NoteFilePropertiesToJson(this,);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _NoteFileProperties &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, width, height);

  @override
  String toString() {
    return 'NoteFileProperties(width: $width, height: $height)';
  }


}

/// @nodoc
abstract mixin class _$NoteFilePropertiesCopyWith<$Res>
    implements $NoteFilePropertiesCopyWith<$Res> {
  factory _$NoteFilePropertiesCopyWith(_NoteFileProperties value,
      $Res Function(_NoteFileProperties) _then) = __$NoteFilePropertiesCopyWithImpl;

  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int width, @JsonKey(
        fromJson: _intFromJson) int height
  });


}

/// @nodoc
class __$NoteFilePropertiesCopyWithImpl<$Res>
    implements _$NoteFilePropertiesCopyWith<$Res> {
  __$NoteFilePropertiesCopyWithImpl(this._self, this._then);

  final _NoteFileProperties _self;
  final $Res Function(_NoteFileProperties) _then;

  /// Create a copy of NoteFileProperties
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({Object? width = null, Object? height = null,}) {
    return _then(_NoteFileProperties(
      width: null == width
          ? _self.width
          : width // ignore: cast_nullable_to_non_nullable
      as int,
      height: null == height
          ? _self.height
          : height // ignore: cast_nullable_to_non_nullable
      as int,
    ));
  }


}

// dart format on
