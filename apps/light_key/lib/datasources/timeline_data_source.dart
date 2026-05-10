import '../models/auth_session.dart';
import '../models/note.dart';
import '../models/response_with_cache_hints.dart';
import 'timeline_connection.dart';

abstract interface class TimelineDataSource {
  Future<ResponseWithCacheHints<List<Note>>> fetchTimeline(
    AuthSession session, {
    int limit = 20,
  });

  Future<void> createReaction(
    AuthSession session, {
    required String noteId,
    required String reaction,
  });

  Future<void> createRenote(AuthSession session, {required String noteId});

  Future<void> createFavorite(AuthSession session, {required String noteId});

  Future<void> createPin(AuthSession session, {required String noteId});

  Future<void> createMute(AuthSession session, {required String userId});

  Future<void> createRenoteMute(AuthSession session, {required String userId});

  Future<void> createBlock(AuthSession session, {required String userId});

  Future<void> createReport(
    AuthSession session, {
    required String userId,
    required String noteId,
    required String category,
    String userComment = '',
    String? noteUrl,
  });

  Future<void> deleteNote(AuthSession session, {required String noteId});

  /// Fetches a single note by ID.
  Future<ResponseWithCacheHints<Note>> fetchNote(
    AuthSession session,
    String noteId,
  );

  /// Opens a raw WebSocket connection.
  /// The caller is responsible for sending connect/disconnect/subNote/unsubNote
  /// messages and for parsing incoming messages.
  TimelineConnection openConnection(AuthSession session);
}
