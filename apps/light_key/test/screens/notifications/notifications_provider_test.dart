import 'package:core/models/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:light_key/models/auth_session.dart';
import 'package:light_key/models/misskey_notification.dart';
import 'package:light_key/models/user.dart';
import 'package:light_key/repositories/auth_repository.dart';
import 'package:light_key/repositories/notification_repository.dart';
import 'package:light_key/screens/notifications/notifications_provider.dart';
import 'package:light_key/screens/notifications/notifications_screen_state.dart';

void main() {
  const session = AuthSession(
    baseUrl: 'https://misskey.example',
    accessToken: 'token-123',
  );

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
      expect(
        notificationRepository.untilIds,
        [null, 'n1', 'n2'],
      );
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
      );

      await provider.fetch();
      await provider.fetchMore();

      final loaded = _loadedState(provider);
      expect(loaded.isLoadingMore, isFalse);
      expect(loaded.message, '先に認証してください。');
      expect(loaded.notifications.map((e) => e.id), ['n1']);
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

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this._restoreSessionResults);

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
