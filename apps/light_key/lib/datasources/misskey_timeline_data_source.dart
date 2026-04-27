import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/auth_session.dart';
import '../models/note.dart';
import '../utils/misskey_http_client.dart';
import 'timeline_data_source.dart';
import 'timeline_stream_event.dart';

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

  @override
  Stream<TimelineStreamEvent> watchTimeline(AuthSession session) {
    final controller = StreamController<TimelineStreamEvent>();
    final channelId = DateTime.now().microsecondsSinceEpoch.toString();
    StreamSubscription<dynamic>? socketSubscription;
    WebSocketChannel? channel;

    controller.onListen = () {
      try {
        final wsUrl = _buildStreamingUrl(session);
        channel = WebSocketChannel.connect(Uri.parse(wsUrl));

        channel!.sink.add(
          jsonEncode({
            'type': 'connect',
            'body': {'channel': 'homeTimeline', 'id': channelId},
          }),
        );

        socketSubscription = channel!.stream.listen(
          (message) {
            final event = _parseTimelineEvent(message, channelId);
            if (event != null) {
              controller.add(event);
            }
          },
          onError: controller.addError,
          onDone: () {
            if (!controller.isClosed) {
              controller.close();
            }
          },
        );
      } on Exception catch (e, st) {
        controller.addError(e, st);
        unawaited(controller.close());
      }
    };

    controller.onCancel = () async {
      if (channel != null) {
        channel!.sink.add(
          jsonEncode({
            'type': 'disconnect',
            'body': {'id': channelId},
          }),
        );
      }
      await socketSubscription?.cancel();
      await channel?.sink.close();
      channel = null;
    };

    return controller.stream;
  }

  TimelineStreamEvent? _parseTimelineEvent(dynamic message, String channelId) {
    final decoded = _decodeMessage(message);
    if (decoded is! Map) {
      return null;
    }

    final root = Map<String, dynamic>.from(decoded);

    // Misskey generally wraps channel payloads in {type: channel, body: {...}}.
    // Some devtools views expose only the inner payload, so both shapes are handled.
    if (root['type'] == 'channel') {
      final channelBody = Map<String, dynamic>.from(root['body'] as Map? ?? const {});
      if (channelBody['id'] != channelId) {
        return null;
      }
      return _parseChannelEvent(channelBody);
    }

    return _parseChannelEvent(root);
  }

  TimelineStreamEvent? _parseChannelEvent(Map<String, dynamic> payload) {
    final type = payload['type'] as String?;

    if (type == 'note') {
      final noteJson = Map<String, dynamic>.from(payload['body'] as Map? ?? const {});
      return TimelineNoteReceived(Note.fromJson(noteJson));
    }

    if (type != 'noteUpdated') {
      return null;
    }

    final body = Map<String, dynamic>.from(payload['body'] as Map? ?? const {});
    final noteId = body['id'] as String? ?? '';
    if (noteId.isEmpty) {
      return null;
    }

    final updateType = body['type'] as String?;
    if (updateType == 'reacted' || updateType == 'unreacted') {
      final updateBody = Map<String, dynamic>.from(body['body'] as Map? ?? const {});
      final reaction = updateBody['reaction'] as String? ?? '';
      if (reaction.isEmpty) {
        return null;
      }

      return TimelineReactionUpdated(
        noteId: noteId,
        reaction: reaction,
        delta: updateType == 'reacted' ? 1 : -1,
      );
    }

    return null;
  }

  dynamic _decodeMessage(dynamic message) {
    if (message is String) {
      return jsonDecode(message);
    }
    if (message is List<int>) {
      return jsonDecode(utf8.decode(message));
    }
    return null;
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
