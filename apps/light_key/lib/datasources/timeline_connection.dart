/// A low-level WebSocket connection to a Misskey-compatible streaming API.
///
/// Exposes only primitive send/receive operations.
/// All parsing and subscription lifecycle management are the responsibility
/// of the caller (typically a repository).
abstract interface class TimelineConnection {
  /// Raw messages received from the server.
  Stream<dynamic> get messages;

  /// Sends a `connect` message to subscribe to a channel.
  void connectChannel(String channelId);

  /// Sends a `disconnect` message to unsubscribe from a channel.
  void disconnectChannel(String channelId);

  /// Sends a `subNote` message to subscribe to reaction updates for a note.
  void subscribeNote(String noteId);

  /// Sends an `unsubNote` message to unsubscribe from reaction updates for a note.
  void unsubscribeNote(String noteId);

  /// Closes the underlying WebSocket connection.
  Future<void> close();
}
