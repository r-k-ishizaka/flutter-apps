import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'notification_connection.dart';

class MisskeyNotificationConnection implements NotificationConnection {
  MisskeyNotificationConnection(this._channel);

  factory MisskeyNotificationConnection.connect(Uri url) {
    return MisskeyNotificationConnection(WebSocketChannel.connect(url));
  }

  final WebSocketChannel _channel;

  @override
  Stream<dynamic> get messages => _channel.stream;

  @override
  void connectMainChannel(String channelId) {
    _channel.sink.add(
      jsonEncode({
        'type': 'connect',
        'body': {'channel': 'main', 'id': channelId},
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
  Future<void> close() => _channel.sink.close();
}
