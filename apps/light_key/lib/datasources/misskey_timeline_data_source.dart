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
  Future<void> createFavorite(
    AuthSession session, {
    required String noteId,
  }) async {
    await client.postVoid(
      baseUrl: session.baseUrl,
      path: '/api/notes/favorites/create',
      body: {'i': session.accessToken, 'noteId': noteId},
    );
  }

  @override
  Future<void> createPin(AuthSession session, {required String noteId}) async {
    await client.postVoid(
      baseUrl: session.baseUrl,
      path: '/api/i/pin',
      body: {'i': session.accessToken, 'noteId': noteId},
    );
  }

  @override
  Future<void> createMute(AuthSession session, {required String userId}) async {
    await client.postVoid(
      baseUrl: session.baseUrl,
      path: '/api/mute/create',
      body: {'i': session.accessToken, 'userId': userId},
    );
  }

  @override
  Future<void> createRenoteMute(
    AuthSession session, {
    required String userId,
  }) async {
    await client.postVoid(
      baseUrl: session.baseUrl,
      path: '/api/renote-mute/create',
      body: {'i': session.accessToken, 'userId': userId},
    );
  }

  @override
  Future<void> createBlock(
    AuthSession session, {
    required String userId,
  }) async {
    await client.postVoid(
      baseUrl: session.baseUrl,
      path: '/api/blocking/create',
      body: {'i': session.accessToken, 'userId': userId},
    );
  }

  @override
  Future<void> createReport(
    AuthSession session, {
    required String userId,
    required String noteId,
    required String category,
    String userComment = '',
    String? noteUrl,
  }) async {
    final localNoteUrl = _buildNoteUrlFromBase(session.baseUrl, noteId);
    await client.postVoid(
      baseUrl: session.baseUrl,
      path: '/api/users/report-abuse',
      body: {
        'i': session.accessToken,
        'userId': userId,
        'comment': _buildReportComment(
          noteUrl: noteUrl,
          localNoteUrl: localNoteUrl,
          category: category,
          userComment: userComment,
        ),
      },
    );
  }

  @override
  Future<void> deleteNote(AuthSession session, {required String noteId}) async {
    await client.postVoid(
      baseUrl: session.baseUrl,
      path: '/api/notes/delete',
      body: {'i': session.accessToken, 'noteId': noteId},
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

  String _buildReportComment({
    required String? noteUrl,
    required String localNoteUrl,
    required String category,
    required String userComment,
  }) {
    final lines = <String>[
      if (noteUrl != null) 'Note: $noteUrl',
      'Local Note: $localNoteUrl',
      '-----',
      'Category: ${_categoryLabel(category)}',
      '-----',
    ];
    final normalizedComment = userComment.trim();
    if (normalizedComment.isNotEmpty) {
      lines.add(normalizedComment);
    }
    return lines.join('\n');
  }

  String _categoryLabel(String category) {
    return switch (category) {
      'spam' => 'スパム・宣伝',
      'phishing' => 'フィッシング',
      'explicit' => '露骨な性的コンテンツ（NSFW含む）',
      'personalInfoLeak' => '個人情報の漏洩',
      'selfHarm' => '自傷・自殺をほのめかす投稿',
      'violationRights' => '権利侵害',
      'other' => 'その他',
      _ => category,
    };
  }

  String _buildNoteUrlFromBase(String baseUrl, String noteId) {
    final base = Uri.parse(baseUrl.trim());
    final segments = base.pathSegments
        .where((s) => s.isNotEmpty)
        .toList(growable: true)
      ..add('notes')
      ..add(noteId);
    return base
        .replace(pathSegments: segments, query: null, fragment: null)
        .toString();
  }
}
