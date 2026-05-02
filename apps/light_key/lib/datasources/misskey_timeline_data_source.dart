import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/auth_session.dart';
import '../models/note.dart';
import '../models/response_with_cache_hints.dart';
import '../utils/misskey_http_client.dart';
import 'misskey_timeline_connection.dart';
import 'timeline_connection.dart';
import 'timeline_data_source.dart';

class MisskeyTimelineDataSource implements TimelineDataSource {
  MisskeyTimelineDataSource(this.client);

  final MisskeyHttpClient client;

  @override
  Future<void> createReaction(
    AuthSession session, {
    required String noteId,
    required String reaction,
  }) async {
    await client.postVoid(
      baseUrl: session.baseUrl,
      path: '/api/notes/reactions/create',
      body: {'i': session.accessToken, 'noteId': noteId, 'reaction': reaction},
    );
  }

  @override
  Future<void> createRenote(
    AuthSession session, {
    required String noteId,
  }) async {
    await client.postVoid(
      baseUrl: session.baseUrl,
      path: '/api/notes/create',
      body: {'i': session.accessToken, 'renoteId': noteId},
    );
  }

  @override
  Future<ResponseWithCacheHints<List<Note>>> fetchTimeline(
    AuthSession session, {
    int limit = 20,
  }) async {
    final response = await client.postJsonListWithCacheHints(
      baseUrl: session.baseUrl,
      path: '/api/notes/timeline',
      body: {'i': session.accessToken, 'limit': limit},
    );
    return ResponseWithCacheHints(
      data: response.data.map(Note.fromJson).toList(growable: false),
      emojisToCache: response.emojisToCache,
    );
  }

  @override
  Future<ResponseWithCacheHints<Note>> fetchNote(
    AuthSession session,
    String noteId,
  ) async {
    final response = await client.postJsonWithCacheHints(
      baseUrl: session.baseUrl,
      path: '/api/notes/show',
      body: {'i': session.accessToken, 'noteId': noteId},
    );
    return ResponseWithCacheHints(
      data: Note.fromJson(response.data),
      emojisToCache: response.emojisToCache,
    );
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
