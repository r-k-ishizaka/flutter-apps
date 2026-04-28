import '../models/auth_session.dart';
import '../models/note.dart';
import 'timeline_connection.dart';

abstract interface class TimelineDataSource {
  Future<List<Note>> fetchTimeline(AuthSession session, {int limit = 20});

  Future<void> createReaction(
    AuthSession session, {
    required String noteId,
    required String reaction,
  });

  /// Fetches a single note by ID.
  Future<Note> fetchNote(AuthSession session, String noteId);

  /// Opens a raw WebSocket connection.
  /// The caller is responsible for sending connect/disconnect/subNote/unsubNote
  /// messages and for parsing incoming messages.
  TimelineConnection openConnection(AuthSession session);
}
