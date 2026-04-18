// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduleNotification {

 bool get isScheduled; NotificationMonth get month; NotificationDay get day;@JsonKey(fromJson: NotificationTime.fromJson, toJson: NotificationTime.toJson) NotificationTime get time;
/// Create a copy of ScheduleNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleNotificationCopyWith<ScheduleNotification> get copyWith => _$ScheduleNotificationCopyWithImpl<ScheduleNotification>(this as ScheduleNotification, _$identity);

  /// Serializes this ScheduleNotification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleNotification&&(identical(other.isScheduled, isScheduled) || other.isScheduled == isScheduled)&&(identical(other.month, month) || other.month == month)&&(identical(other.day, day) || other.day == day)&&(identical(other.time, time) || other.time == time));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isScheduled,month,day,time);

@override
String toString() {
  return 'ScheduleNotification(isScheduled: $isScheduled, month: $month, day: $day, time: $time)';
}


}

/// @nodoc
abstract mixin class $ScheduleNotificationCopyWith<$Res>  {
  factory $ScheduleNotificationCopyWith(ScheduleNotification value, $Res Function(ScheduleNotification) _then) = _$ScheduleNotificationCopyWithImpl;
@useResult
$Res call({
 bool isScheduled, NotificationMonth month, NotificationDay day,@JsonKey(fromJson: NotificationTime.fromJson, toJson: NotificationTime.toJson) NotificationTime time
});




}
/// @nodoc
class _$ScheduleNotificationCopyWithImpl<$Res>
    implements $ScheduleNotificationCopyWith<$Res> {
  _$ScheduleNotificationCopyWithImpl(this._self, this._then);

  final ScheduleNotification _self;
  final $Res Function(ScheduleNotification) _then;

/// Create a copy of ScheduleNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isScheduled = null,Object? month = null,Object? day = null,Object? time = null,}) {
  return _then(_self.copyWith(
isScheduled: null == isScheduled ? _self.isScheduled : isScheduled // ignore: cast_nullable_to_non_nullable
as bool,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as NotificationMonth,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as NotificationDay,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as NotificationTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ScheduleNotification].
extension ScheduleNotificationPatterns on ScheduleNotification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduleNotification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduleNotification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduleNotification value)  $default,){
final _that = this;
switch (_that) {
case _ScheduleNotification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduleNotification value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduleNotification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isScheduled,  NotificationMonth month,  NotificationDay day, @JsonKey(fromJson: NotificationTime.fromJson, toJson: NotificationTime.toJson)  NotificationTime time)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduleNotification() when $default != null:
return $default(_that.isScheduled,_that.month,_that.day,_that.time);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isScheduled,  NotificationMonth month,  NotificationDay day, @JsonKey(fromJson: NotificationTime.fromJson, toJson: NotificationTime.toJson)  NotificationTime time)  $default,) {final _that = this;
switch (_that) {
case _ScheduleNotification():
return $default(_that.isScheduled,_that.month,_that.day,_that.time);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isScheduled,  NotificationMonth month,  NotificationDay day, @JsonKey(fromJson: NotificationTime.fromJson, toJson: NotificationTime.toJson)  NotificationTime time)?  $default,) {final _that = this;
switch (_that) {
case _ScheduleNotification() when $default != null:
return $default(_that.isScheduled,_that.month,_that.day,_that.time);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScheduleNotification implements ScheduleNotification {
  const _ScheduleNotification({required this.isScheduled, required this.month, required this.day, @JsonKey(fromJson: NotificationTime.fromJson, toJson: NotificationTime.toJson) required this.time});
  factory _ScheduleNotification.fromJson(Map<String, dynamic> json) => _$ScheduleNotificationFromJson(json);

@override final  bool isScheduled;
@override final  NotificationMonth month;
@override final  NotificationDay day;
@override@JsonKey(fromJson: NotificationTime.fromJson, toJson: NotificationTime.toJson) final  NotificationTime time;

/// Create a copy of ScheduleNotification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduleNotificationCopyWith<_ScheduleNotification> get copyWith => __$ScheduleNotificationCopyWithImpl<_ScheduleNotification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduleNotificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduleNotification&&(identical(other.isScheduled, isScheduled) || other.isScheduled == isScheduled)&&(identical(other.month, month) || other.month == month)&&(identical(other.day, day) || other.day == day)&&(identical(other.time, time) || other.time == time));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isScheduled,month,day,time);

@override
String toString() {
  return 'ScheduleNotification(isScheduled: $isScheduled, month: $month, day: $day, time: $time)';
}


}

/// @nodoc
abstract mixin class _$ScheduleNotificationCopyWith<$Res> implements $ScheduleNotificationCopyWith<$Res> {
  factory _$ScheduleNotificationCopyWith(_ScheduleNotification value, $Res Function(_ScheduleNotification) _then) = __$ScheduleNotificationCopyWithImpl;
@override @useResult
$Res call({
 bool isScheduled, NotificationMonth month, NotificationDay day,@JsonKey(fromJson: NotificationTime.fromJson, toJson: NotificationTime.toJson) NotificationTime time
});




}
/// @nodoc
class __$ScheduleNotificationCopyWithImpl<$Res>
    implements _$ScheduleNotificationCopyWith<$Res> {
  __$ScheduleNotificationCopyWithImpl(this._self, this._then);

  final _ScheduleNotification _self;
  final $Res Function(_ScheduleNotification) _then;

/// Create a copy of ScheduleNotification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isScheduled = null,Object? month = null,Object? day = null,Object? time = null,}) {
  return _then(_ScheduleNotification(
isScheduled: null == isScheduled ? _self.isScheduled : isScheduled // ignore: cast_nullable_to_non_nullable
as bool,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as NotificationMonth,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as NotificationDay,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as NotificationTime,
  ));
}


}

// dart format on
