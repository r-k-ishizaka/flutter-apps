import 'package:freezed_annotation/freezed_annotation.dart';

import 'notification_day.dart';
import 'notification_month.dart';
import 'notification_time.dart';

part 'schedule_notification.freezed.dart';
part 'schedule_notification.g.dart';

@freezed
sealed class ScheduleNotification with _$ScheduleNotification {
  const factory ScheduleNotification({
    required bool isScheduled,
    required NotificationMonth month,
    required NotificationDay day,
    @JsonKey(
      fromJson: NotificationTime.fromJson,
      toJson: NotificationTime.toJson,
    )
    required NotificationTime time,
  }) = _ScheduleNotification;

  factory ScheduleNotification.fromJson(Map<String, dynamic> json) =>
      _$ScheduleNotificationFromJson(json);
}
