import '../../models/schedule_notification.dart';
import '../../models/todo.dart' as model;

class FirestoreTodoDto {
  const FirestoreTodoDto({
    required this.id,
    required this.title,
    required this.isDone,
    required this.scheduleNotification,
  });

  final String? id;
  final String title;
  final bool isDone;
  final Map<String, dynamic>? scheduleNotification;

  factory FirestoreTodoDto.fromDomain(model.Todo todo) {
    return FirestoreTodoDto(
      id: todo.id,
      title: todo.title,
      isDone: todo.isDone,
      scheduleNotification: todo.scheduleNotification?.toJson(),
    );
  }

  factory FirestoreTodoDto.fromFirestore(Map<String, dynamic> data) {
    final rawSchedule = data['scheduleNotification'];
    return FirestoreTodoDto(
      id: data['id'] as String?,
      title: data['title'] as String? ?? '',
      isDone: data['isDone'] as bool? ?? false,
      scheduleNotification: rawSchedule is Map<String, dynamic>
          ? rawSchedule
          : rawSchedule is Map
              ? Map<String, dynamic>.from(rawSchedule)
              : null,
    );
  }

  model.Todo toDomain(String documentId) {
    final resolvedId = (id != null && id!.isNotEmpty) ? id! : documentId;
    return model.Todo(
      id: resolvedId,
      title: title,
      isDone: isDone,
      scheduleNotification: scheduleNotification == null
          ? null
          : ScheduleNotification.fromJson(scheduleNotification!),
    );
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'isDone': isDone,
      'scheduleNotification': scheduleNotification,
    };
  }
}
