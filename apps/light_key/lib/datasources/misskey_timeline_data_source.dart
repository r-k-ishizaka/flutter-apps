import '../models/auth_session.dart';
import '../models/note.dart';
import '../utils/misskey_http_client.dart';
import 'timeline_data_source.dart';

class MisskeyTimelineDataSource implements TimelineDataSource {
  MisskeyTimelineDataSource(this.client);

  final MisskeyHttpClient client;

  @override
  Future<List<Note>> fetchTimeline(AuthSession session, {int limit = 20}) async {
    final response = await client.postJsonList(
      baseUrl: session.baseUrl,
      path: '/api/notes/timeline',
      body: {'i': session.accessToken, 'limit': limit},
    );
    return response.map(Note.fromJson).toList(growable: false);
  }
}
