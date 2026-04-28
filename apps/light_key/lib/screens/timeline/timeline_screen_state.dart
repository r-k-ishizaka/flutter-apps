import '../../models/note.dart';

enum TimelineStatus { idle, loading, loaded, error }

class TimelineScreenState {
  const TimelineScreenState({
    required this.status,
    required this.notes,
    this.isRefreshing = false,
    this.message,
  });

  const TimelineScreenState.idle()
    : status = TimelineStatus.idle,
      notes = const [],
      isRefreshing = false,
      message = null;

  final TimelineStatus status;
  final List<Note> notes;
  final bool isRefreshing;
  final String? message;

  TimelineScreenState copyWith({
    TimelineStatus? status,
    List<Note>? notes,
    bool? isRefreshing,
    String? message,
    bool clearMessage = false,
  }) {
    return TimelineScreenState(
      status: status ?? this.status,
      notes: notes ?? this.notes,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}
