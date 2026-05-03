abstract interface class NotificationConnection {
  Stream<dynamic> get messages;

  void connectMainChannel(String channelId);

  void disconnectChannel(String channelId);

  Future<void> close();
}
