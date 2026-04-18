// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScheduleNotification _$ScheduleNotificationFromJson(
  Map<String, dynamic> json,
) => _ScheduleNotification(
  isScheduled: json['isScheduled'] as bool,
  month: $enumDecode(_$NotificationMonthEnumMap, json['month']),
  day: $enumDecode(_$NotificationDayEnumMap, json['day']),
  time: NotificationTime.fromJson(json['time'] as String?),
);

Map<String, dynamic> _$ScheduleNotificationToJson(
  _ScheduleNotification instance,
) => <String, dynamic>{
  'isScheduled': instance.isScheduled,
  'month': _$NotificationMonthEnumMap[instance.month]!,
  'day': _$NotificationDayEnumMap[instance.day]!,
  'time': NotificationTime.toJson(instance.time),
};

const _$NotificationMonthEnumMap = {
  NotificationMonth.january: 'january',
  NotificationMonth.february: 'february',
  NotificationMonth.march: 'march',
  NotificationMonth.april: 'april',
  NotificationMonth.may: 'may',
  NotificationMonth.june: 'june',
  NotificationMonth.july: 'july',
  NotificationMonth.august: 'august',
  NotificationMonth.september: 'september',
  NotificationMonth.october: 'october',
  NotificationMonth.november: 'november',
  NotificationMonth.december: 'december',
  NotificationMonth.everyMonth: 'everyMonth',
};

const _$NotificationDayEnumMap = {
  NotificationDay.sunday: 'sunday',
  NotificationDay.monday: 'monday',
  NotificationDay.tuesday: 'tuesday',
  NotificationDay.wednesday: 'wednesday',
  NotificationDay.thursday: 'thursday',
  NotificationDay.friday: 'friday',
  NotificationDay.saturday: 'saturday',
  NotificationDay.everyday: 'everyday',
};
