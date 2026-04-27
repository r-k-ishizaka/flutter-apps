import '../models/note.dart';

sealed class TimelineStreamEvent {
  const TimelineStreamEvent();
}

class TimelineNoteReceived extends TimelineStreamEvent {
  const TimelineNoteReceived(this.note);

  final Note note;
}

class TimelineReactionUpdated extends TimelineStreamEvent {
  const TimelineReactionUpdated({
    required this.noteId,
    required this.reaction,
    required this.delta,
  });

  final String noteId;
  final String reaction;
  final int delta;
}
