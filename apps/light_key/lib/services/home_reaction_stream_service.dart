import 'dart:async';
import 'dart:convert';

import '../datasources/misskey_notification_connection.dart';
import '../datasources/notification_connection.dart';
import '../models/auth_session.dart';

class HomeReactionStreamEvent {
  const HomeReactionStreamEvent({required this.reaction, this.avatarUrl});

  final String reaction;
  final String? avatarUrl;
}

class HomeReactionStreamService {
  HomeReactionStreamService({
    NotificationConnection Function(Uri url)? connectionFactory,
  }) : _connectionFactory = connectionFactory ??
            ((url) => MisskeyNotificationConnection.connect(url));

  final NotificationConnection Function(Uri url) _connectionFactory;

  NotificationConnection? _connection;
  StreamSubscription<dynamic>? _subscription;
  String? _channelId;
  String? _sessionKey;
  bool _isConnecting = false;
  bool _isDisposed = false;

  AuthSession? _session;
  bool _isParticleEnabledTab = false;
  Future<void> Function(HomeReactionStreamEvent event)? _onReactionEvent;

  void configure({
    required AuthSession? session,
    required bool isParticleEnabledTab,
    required Future<void> Function(HomeReactionStreamEvent event) onReactionEvent,
  }) {
    _session = session;
    _isParticleEnabledTab = isParticleEnabledTab;
    _onReactionEvent = onReactionEvent;
    unawaited(_syncSessionAndConnection());
  }

  Future<void> onHide() => disconnect();

  Future<void> onResume() => _connectIfNeeded();

  Future<void> dispose() async {
    _isDisposed = true;
    await disconnect();
  }

  Future<void> _syncSessionAndConnection() async {
    final nextSessionKey = _sessionKeyFor(_session);
    if (_sessionKey == nextSessionKey) return;

    _sessionKey = nextSessionKey;
    await disconnect();
    await _connectIfNeeded();
  }

  Future<void> _connectIfNeeded() async {
    if (_isDisposed || _isConnecting || _subscription != null) return;

    final session = _session;
    if (session == null) return;

    _isConnecting = true;
    try {
      final connection = _connectionFactory(Uri.parse(_buildStreamingUrl(session)));
      final channelId = DateTime.now().microsecondsSinceEpoch.toString();

      connection.connectMainChannel(channelId);

      _connection = connection;
      _channelId = channelId;
      _subscription = connection.messages.listen(
        _handleMessage,
        onError: (_, _) => unawaited(disconnect()),
        onDone: () => unawaited(disconnect()),
        cancelOnError: true,
      );
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> disconnect() async {
    final subscription = _subscription;
    _subscription = null;
    await subscription?.cancel();

    final connection = _connection;
    final channelId = _channelId;
    _connection = null;
    _channelId = null;

    if (connection == null) return;

    try {
      if (channelId != null) {
        connection.disconnectChannel(channelId);
      }
    } on Exception {
      // Ignore disconnect errors when socket is already closed.
    }

    await connection.close();
  }

  void _handleMessage(dynamic message) {
    final event = _extractReactionEvent(message, expectedChannelId: _channelId);
    if (event == null || !_isParticleEnabledTab || _onReactionEvent == null) {
      return;
    }
    unawaited(_onReactionEvent!(event));
  }

  static HomeReactionStreamEvent? _extractReactionEvent(
    dynamic message, {
    String? expectedChannelId,
  }) {
    final decoded = _decodeMessage(message);
    if (decoded is! Map) return null;

    final root = Map<String, dynamic>.from(decoded);
    if (root['type'] != 'channel') return null;

    final channelBody = _asMap(root['body']);
    if (expectedChannelId != null && channelBody['id'] != expectedChannelId) {
      return null;
    }
    if (channelBody['type'] != 'notification') return null;

    final notification = _asMap(channelBody['body']);
    if (notification['type'] != 'reaction') return null;

    final reaction = (notification['reaction'] as String?)?.trim() ?? '';
    if (reaction.isEmpty) return null;

    final avatarUrl = _asMap(notification['user'])['avatarUrl'] as String?;
    return HomeReactionStreamEvent(reaction: reaction, avatarUrl: avatarUrl);
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const <String, dynamic>{};
  }

  static dynamic _decodeMessage(dynamic message) {
    if (message is Map<String, dynamic>) return message;
    if (message is Map) return Map<String, dynamic>.from(message);
    if (message is String) return jsonDecode(message);
    if (message is List<int>) return jsonDecode(utf8.decode(message));
    return null;
  }

  static String _buildStreamingUrl(AuthSession session) {
    final base = Uri.parse(session.baseUrl.trim());
    final scheme = switch (base.scheme) {
      'https' => 'wss',
      'http' => 'ws',
      _ => throw Exception('Unsupported base URL scheme: ${base.scheme}'),
    };

    final normalizedPath = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
    final path = normalizedPath.isEmpty ? '/streaming' : '$normalizedPath/streaming';

    return base
        .replace(
          scheme: scheme,
          path: path,
          queryParameters: {'i': session.accessToken},
        )
        .toString();
  }

  static String? _sessionKeyFor(AuthSession? session) {
    if (session == null) return null;
    return '${session.baseUrl}|${session.accessToken}';
  }
}
