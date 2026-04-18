import 'package:flutter/material.dart';
import '../models/schedule_notification.dart';
import '../models/notification_month.dart';
import '../models/notification_day.dart';
import '../models/notification_time.dart';

class ScheduleNotificationInput extends StatelessWidget {
  final ScheduleNotification? value;
  final ValueChanged<ScheduleNotification?> onChanged;
  const ScheduleNotificationInput({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isScheduled = value?.isScheduled ?? false;
    final month = value?.month ?? NotificationMonth.everyMonth;
    final day = value?.day ?? NotificationDay.everyday;
    final time = value?.time ?? NotificationTime.of(9, 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('通知を設定'),
            Switch(
              value: isScheduled,
              onChanged: (v) {
                if (!v) {
                  onChanged(null);
                } else {
                  onChanged(
                    ScheduleNotification(
                      isScheduled: true,
                      month: month,
                      day: day,
                      time: time,
                    ),
                  );
                }
              },
            ),
          ],
        ),
        if (isScheduled) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('月: '),
              DropdownButton<NotificationMonth>(
                value: month,
                items: NotificationMonth.values
                    .map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
                    .toList(),
                onChanged: (m) {
                  if (m != null) {
                    onChanged(value!.copyWith(month: m));
                  }
                },
              ),
              const SizedBox(width: 16),
              const Text('曜日: '),
              DropdownButton<NotificationDay>(
                value: day,
                items: NotificationDay.values
                    .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
                    .toList(),
                onChanged: (d) {
                  if (d != null) {
                    onChanged(value!.copyWith(day: d));
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('時刻: '),
              TextButton(
                child: Text('${time.hour}:${time.minute}'),
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: int.parse(time.hour),
                      minute: int.parse(time.minute),
                    ),
                  );
                  if (picked != null) {
                    onChanged(
                      value!.copyWith(
                        time: NotificationTime.of(picked.hour, picked.minute),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ],
    );
  }
}
