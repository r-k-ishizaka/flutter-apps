import 'package:core/models/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:light_key/datasources/timeline_connection.dart';
import 'package:light_key/datasources/timeline_data_source.dart';
import 'package:light_key/models/auth_session.dart';
import 'package:light_key/models/misskey_notification.dart';
import 'package:light_key/models/note.dart';
import 'package:light_key/models/response_with_cache_hints.dart';
import 'package:light_key/models/user.dart';
import 'package:light_key/repositories/auth_repository.dart';
import 'package:light_key/repositories/notification_repository.dart';
import 'package:light_key/repositories/timeline_repository.dart';
import 'package:light_key/screens/notifications/notifications_provider.dart';
import 'package:light_key/screens/notifications/notifications_screen_state.dart';

void main() {
  const session = AuthSession(
    baseUrl: 'https://misskey.example',
    accessToken: 'token-123',
  );

  group('NotificationsProvider.createReaction / createRenote', () {
    test('リアクションを送信し、通知内ノートの myReaction も更新する', () async {
      final authRepository = _FakeAuthRepository([
        const Success(session),
        const Success(session),
      ]);
      final notificationRepository = _FakeNotificationRepository([
        Success(<MisskeyNotification>[
          ReplyNotification(
            id: 'n1',
            createdAt: DateTime(2026, 5, 8, 12),
            user: const User(id: 'user-2', username: 'alice'),
            note: _note(id: 'note-1'),
          ),
        ]),
      ]);
      final timelineDataSource = _FakeTimelineDataSource();
      final provider = NotificationsProvider(
        authRepository: authRepository,
        notificationRepository: notificationRepository,
        timelineRepository: TimelineRepository(timelineDataSource),
      );

      await provider.fetch();
      final message = await provider.createReaction(_note(id: 'note-1'), '👍');

      expect(message, isNull);
      expect(timelineDataSource.reactionCalls, [('note-1', '👍')]);
      final loaded = _loadedState(provider);
      final notification = loaded.notifications.single as ReplyNotification;
      expect(notification.note.myReaction, '👍');
      expect(notification.note.reactions['👍'], 1);
    });

    test('純粋リノートでは元ノートにリアクションを送信する', () async {
      final pureRenote = Note(
        id: 'wrapper',
        text: '',
        createdAt: DateTime(2026, 5, 8, 12),
        user: const User(id: 'user-2', username: 'alice'),
        renote: _note(id: 'renoted-1'),
      );

      final timelineDataSource = _FakeTimelineDataSource();
      final provider2 = NotificationsProvider(
        authRepository: _FakeAuthRepository([const Success(session)]),
        notificationRepository: _FakeNotificationRepository(const []),
        timelineRepository: TimelineRepository(timelineDataSource),
      );

      final message = await provider2.createReaction(pureRenote, ':custom:');

      expect(message, isNull);
      expect(timelineDataSource.reactionCalls, [('renoted-1', ':custom:')]);
    });

    test('リノートを送信する', () async {
      final timelineDataSource = _FakeTimelineDataSource();
      final provider = NotificationsProvider(
        authRepository: _FakeAuthRepository([const Success(session)]),
        notificationRepository: _FakeNotificationRepository(const []),
        timelineRepository: TimelineRepository(timelineDataSource),
      );

      final message = await provider.createRenote(_note(id: 'note-1'));

      expect(message, isNull);
      expect(timelineDataSource.renoteCalls, ['note-1']);
    });

    test('未認証時はエラーメッセージを返す', () async {
      final timelineDataSource = _FakeTimelineDataSource();
      final provider = NotificationsProvider(
        authRepository: _FakeAuthRepository(const [
          Success<AuthSession?>(null),
        ]),
        notificationRepository: _FakeNotificationRepository(const []),
        timelineRepository: TimelineRepository(timelineDataSource),
      );

      final reactionMessage = await provider.createReaction(
        _note(id: 'note-1'),
        '👍',
      );
      final renoteMessage = await provider.createRenote(_note(id: 'note-1'));

      expect(reactionMessage, '先に認証してください。');
      expect(renoteMessage, '先に認証してください。');
      expect(timelineDataSource.reactionCalls, isEmpty);
      expect(timelineDataSource.renoteCalls, isEmpty);
    });
  });

  group('NotificationsProvider.fetchMore', () {
    test('初回取得が20件未満でも追加読み込みできる', () async {
      final authRepository = _FakeAuthRepository([
        const Success(session),
        const Success(session),
        const Success(session),
      ]);
      final notificationRepository = _FakeNotificationRepository([
        Success(<MisskeyNotification>[_notification('n1')]),
        Success(<MisskeyNotification>[_notification('n2')]),
        const Success(<MisskeyNotification>[]),
      ]);
      final provider = NotificationsProvider(
        authRepository: authRepository,
        notificationRepository: notificationRepository,
        timelineRepository: TimelineRepository(_FakeTimelineDataSource()),
      );

      await provider.fetch();
      var loaded = _loadedState(provider);
      expect(loaded.notifications.map((e) => e.id), ['n1']);
      expect(loaded.hasMore, isTrue);

      await provider.fetchMore();
      loaded = _loadedState(provider);
      expect(loaded.notifications.map((e) => e.id), ['n1', 'n2']);
      expect(loaded.hasMore, isTrue);

      await provider.fetchMore();
      loaded = _loadedState(provider);
      expect(loaded.notifications.map((e) => e.id), ['n1', 'n2']);
      expect(loaded.hasMore, isFalse);
      expect(notificationRepository.untilIds, [null, 'n1', 'n2']);
    });

    test('追加取得で重複した通知はマージ時に除外する', () async {
      final authRepository = _FakeAuthRepository([
        const Success(session),
        const Success(session),
      ]);
      final notificationRepository = _FakeNotificationRepository([
        Success(<MisskeyNotification>[_notification('n1')]),
        Success(<MisskeyNotification>[
          _notification('n1'),
          _notification('n2'),
        ]),
      ]);
      final provider = NotificationsProvider(
        authRepository: authRepository,
        notificationRepository: notificationRepository,
        timelineRepository: TimelineRepository(_FakeTimelineDataSource()),
      );

      await provider.fetch();
      await provider.fetchMore();

      final loaded = _loadedState(provider);
      expect(loaded.notifications.map((e) => e.id), ['n1', 'n2']);
      expect(loaded.hasMore, isTrue);
    });

    test('追加読み込み中にセッションが切れても loading 状態に残らない', () async {
      final authRepository = _FakeAuthRepository([
        const Success(session),
        const Success<AuthSession?>(null),
      ]);
      final notificationRepository = _FakeNotificationRepository([
        Success(<MisskeyNotification>[_notification('n1')]),
      ]);
      final provider = NotificationsProvider(
        authRepository: authRepository,
        notificationRepository: notificationRepository,
        timelineRepository: TimelineRepository(_FakeTimelineDataSource()),
      );

      await provider.fetch();
      await provider.fetchMore();

      final loaded = _loadedState(provider);
      expect(loaded.isLoadingMore, isFalse);
      expect(loaded.message, '先に認証してください。');
      expect(loaded.notifications.map((e) => e.id), ['n1']);
    });
  });

  group('NotificationsProvider.deleteNote', () {
    test('削除成功時に対象ノートを含む通知が一覧から除外される', () async {
      final authRepository = _FakeAuthRepository([
        const Success(session), // fetch
        const Success(session), // deleteNote
      ]);
      final notificationRepository = _FakeNotificationRepository([
        Success(<MisskeyNotification>[
          ReplyNotification(
            id: 'n1',
            createdAt: DateTime(2026, 5, 8, 12),
            user: const User(id: 'user-2', username: 'alice'),
            note: _note(id: 'note-1'),
          ),
          ReplyNotification(
            id: 'n2',
            createdAt: DateTime(2026, 5, 8, 12),
            user: const User(id: 'user-2', username: 'alice'),
            note: _note(id: 'note-2'),
          ),
        ]),
      ]);
      final timelineDataSource = _FakeTimelineDataSource();
      final provider = NotificationsProvider(
        authRepository: authRepository,
        notificationRepository: notificationRepository,
        timelineRepository: TimelineRepository(timelineDataSource),
      );

      await provider.fetch();
      final message = await provider.deleteNote(_note(id: 'note-1'));

      expect(message, isNull);
      expect(timelineDataSource.deleteCalls, ['note-1']);
      final loaded = _loadedState(provider);
      expect(loaded.notifications.map((e) => e.id), ['n2']);
    });
  });
}

NotificationsScreenStateLoaded _loadedState(NotificationsProvider provider) {
  final state = provider.state;
  expect(state, isA<NotificationsScreenStateLoaded>());
  return state as NotificationsScreenStateLoaded;
}

MisskeyNotification _notification(String id) {
  return UnknownNotification(
    id: id,
    createdAt: DateTime(2026, 5, 8, 12),
    type: 'test',
  );
}

Note _note({required String id, String text = 'hello'}) {
  return Note(
    id: id,
    text: text,
    createdAt: DateTime(2026, 5, 8, 12),
    user: const User(
      id: 'user-1',
      username: 'sample_user',
      name: 'Sample User',
    ),
  );
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(List<Result<AuthSession?>> restoreSessionResults)
    : _restoreSessionResults = List<Result<AuthSession?>>.from(
        restoreSessionResults,
      );

  final List<Result<AuthSession?>> _restoreSessionResults;

  @override
  Future<Result<AuthSession?>> restoreSession() async {
    if (_restoreSessionResults.isEmpty) {
      return const Success(null);
    }
    return _restoreSessionResults.removeAt(0);
  }

  @override
  Future<Result<AuthSession?>> restoreSessionWithUserRefresh() async {
    return restoreSession();
  }

  @override
  Future<Result<void>> signOut() async {
    return const Success(null);
  }

  @override
  Future<Result<User>> signInWithOAuth(
    String baseUrl,
    String clientId,
    String code,
    String redirectUri, {
    String? codeVerifier,
  }) async {
    throw UnimplementedError();
  }
}

class _FakeNotificationRepository implements NotificationRepository {
  _FakeNotificationRepository(this._results);

  final List<Result<List<MisskeyNotification>>> _results;
  final List<String?> untilIds = [];

  @override
  Future<Result<List<MisskeyNotification>>> fetchGroupedNotifications(
    AuthSession session, {
    int limit = 20,
    String? untilId,
  }) async {
    untilIds.add(untilId);
    if (_results.isEmpty) {
      return const Success(<MisskeyNotification>[]);
    }
    return _results.removeAt(0);
  }
}

class _FakeTimelineDataSource implements TimelineDataSource {
  final List<(String noteId, String reaction)> reactionCalls = [];
  final List<String> renoteCalls = [];
  final List<String> favoriteCalls = [];
  final List<String> pinCalls = [];
  final List<String> deleteCalls = [];

  @override
  Future<void> createReaction(
    AuthSession session, {
    required String noteId,
    required String reaction,
  }) async {
    reactionCalls.add((noteId, reaction));
  }

  @override
  Future<void> createRenote(
    AuthSession session, {
    required String noteId,
  }) async {
    renoteCalls.add(noteId);
  }

  @override
  Future<void> createFavorite(
    AuthSession session, {
    required String noteId,
  }) async {
    favoriteCalls.add(noteId);
  }

  @override
  Future<void> createPin(
    AuthSession session, {
    required String noteId,
  }) async {
    pinCalls.add(noteId);
  }

  @override
  Future<void> deleteNote(
    AuthSession session, {
    required String noteId,
  }) async {
    deleteCalls.add(noteId);
  }

  @override
  Future<ResponseWithCacheHints<Note>> fetchNote(
    AuthSession session,
    String noteId,
  ) async => ResponseWithCacheHints(
    data: Note(
      id: noteId,
      text: '',
      createdAt: DateTime(2026, 5, 8, 12),
      user: const User(id: 'user-1', username: 'user1'),
    ),
  );

  @override
  Future<ResponseWithCacheHints<List<Note>>> fetchTimeline(
    AuthSession session, {
    int limit = 20,
  }) async => const ResponseWithCacheHints(data: <Note>[]);

  @override
  TimelineConnection openConnection(AuthSession session) =>
      _FakeTimelineConnection();
}

class _FakeTimelineConnection implements TimelineConnection {
  @override
  Future<void> close() async {}

  @override
  void connectChannel(String channelId) {}

  @override
  void disconnectChannel(String channelId) {}

  @override
  Stream<dynamic> get messages => const Stream<dynamic>.empty();

  @override
  void subscribeNote(String noteId) {}

  @override
  void unsubscribeNote(String noteId) {}
}
