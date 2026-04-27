
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/auth_session.dart';
import '../models/note.dart';
import '../utils/misskey_http_client.dart';
import 'misskey_timeline_connection.dart';
import 'timeline_connection.dart';
import 'timeline_data_source.dart';

class MisskeyTimelineDataSource implements TimelineDataSource {
  MisskeyTimelineDataSource(this.client);

  final MisskeyHttpClient client;

  @override
  Future<List<Note>> fetchTimeline(
    AuthSession session, {
    int limit = 20,
  }) async {
    final response = await client.postJsonList(
      baseUrl: session.baseUrl,
      path: '/api/notes/timeline',
      body: {'i': session.accessToken, 'limit': limit},
    );
    return response.map(Note.fromJson).toList(growable: false);
  }

  @override
  Future<Note> fetchNote(AuthSession session, String noteId) async {
    final response = await client.postJson(
      baseUrl: session.baseUrl,
      path: '/api/notes/show',
      body: {'i': session.accessToken, 'noteId': noteId},
    );
    return Note.fromJson(response);
  }

  @override
  TimelineConnection openConnection(AuthSession session) {
    final wsUrl = _buildStreamingUrl(session);
    final channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    return MisskeyTimelineConnection(channel);
  }

  String _buildStreamingUrl(AuthSession session) {
    final base = Uri.parse(session.baseUrl.trim());
    final scheme = switch (base.scheme) {
      'https' => 'wss',
      'http' => 'ws',
      _ => throw Exception('Unsupported base URL scheme: ${base.scheme}'),
    };

    final normalizedPath = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
    final path = normalizedPath.isEmpty
        ? '/streaming'
        : '$normalizedPath/streaming';

    return base
        .replace(
          scheme: scheme,
          path: path,
          queryParameters: {'i': session.accessToken},
        )
        .toString();
  }
}
