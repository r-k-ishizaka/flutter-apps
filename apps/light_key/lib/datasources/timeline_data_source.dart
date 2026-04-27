import '../models/auth_session.dart';
import '../models/note.dart';
import 'timeline_stream_event.dart';

abstract interface class TimelineDataSource {
  Future<List<Note>> fetchTimeline(AuthSession session, {int limit = 20});
  Stream<TimelineStreamEvent> watchTimeline(AuthSession session);
}
