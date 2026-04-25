import '../../models/note.dart';

enum TimelineStatus { idle, loading, loaded, error }

class TimelineScreenState {
  const TimelineScreenState({
    required this.status,
    required this.notes,
    this.message,
  });

  const TimelineScreenState.idle()
    : status = TimelineStatus.idle,
      notes = const [],
      message = null;

  final TimelineStatus status;
  final List<Note> notes;
  final String? message;

  TimelineScreenState copyWith({
    TimelineStatus? status,
    List<Note>? notes,
    String? message,
    bool clearMessage = false,
  }) {
    return TimelineScreenState(
      status: status ?? this.status,
      notes: notes ?? this.notes,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}
