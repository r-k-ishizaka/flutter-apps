import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'timeline_connection.dart';

class MisskeyTimelineConnection implements TimelineConnection {
  MisskeyTimelineConnection(this._channel);

  final WebSocketChannel _channel;

  @override
  Stream<dynamic> get messages => _channel.stream;

  @override
  void connectChannel(String channelId) {
    _channel.sink.add(
      jsonEncode({
        'type': 'connect',
        'body': {'channel': 'homeTimeline', 'id': channelId},
      }),
    );
  }

  @override
  void disconnectChannel(String channelId) {
    _channel.sink.add(
      jsonEncode({
        'type': 'disconnect',
        'body': {'id': channelId},
      }),
    );
  }

  @override
  void subscribeNote(String noteId) {
    _channel.sink.add(
      jsonEncode({
        'type': 'subNote',
        'body': {'id': noteId},
      }),
    );
  }

  @override
  void unsubscribeNote(String noteId) {
    _channel.sink.add(
      jsonEncode({
        'type': 'unsubNote',
        'body': {'id': noteId},
      }),
    );
  }

  @override
  Future<void> close() => _channel.sink.close();
}
