import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:todo_app/models/schedule_notification.dart';

part 'todo.freezed.dart';
part 'todo.g.dart';

@freezed
sealed class Todo with _$Todo {
  const factory Todo({
    required String id,
    required String title,
    @Default(false) bool isDone,
    @Default(null) ScheduleNotification? scheduleNotification,
  }) = _Todo;

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
}
