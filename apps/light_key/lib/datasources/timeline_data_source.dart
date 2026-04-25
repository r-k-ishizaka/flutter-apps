import '../models/auth_session.dart';
import '../models/note.dart';

abstract interface class TimelineDataSource {
  Future<List<Note>> fetchTimeline(AuthSession session, {int limit = 20});
}
