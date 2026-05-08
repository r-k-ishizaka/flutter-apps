import 'package:flutter/foundation.dart';

import '../../models/misskey_notification.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/notification_repository.dart';
import 'notifications_screen_state.dart';

class NotificationsProvider extends ChangeNotifier {
  NotificationsProvider({
    required AuthRepository authRepository,
    required NotificationRepository notificationRepository,
  })  : _authRepository = authRepository,
        _notificationRepository = notificationRepository;

  final AuthRepository _authRepository;
  final NotificationRepository _notificationRepository;

  NotificationsScreenState _state = const NotificationsScreenStateIdle();

  NotificationsScreenState get state => _state;

  NotificationsScreenStateLoaded? get _loadedState => switch (_state) {
        final NotificationsScreenStateLoaded loaded => loaded,
        _ => null,
      };

  List<MisskeyNotification> get _loadedNotifications => switch (_state) {
        NotificationsScreenStateLoaded(:final notifications) => notifications,
        _ => const <MisskeyNotification>[],
      };

  Future<void> fetch({bool showLoading = true}) async {
    final previousLoaded = _loadedState;
    final previous = _loadedNotifications;
    if (showLoading || previous.isEmpty) {
      _state = const NotificationsScreenStateLoading();
      notifyListeners();
    }

    final sessionResult = await _authRepository.restoreSession();
    await sessionResult.when(
      success: (session) async {
        if (session == null) {
          _state = const NotificationsScreenStateError(
            message: '先に認証してください。',
          );
          notifyListeners();
          return;
        }

        final result =
            await _notificationRepository.fetchGroupedNotifications(session);
        result.when(
          success: (notifications) {
            _state = NotificationsScreenStateLoaded(
              notifications: List.unmodifiable(notifications),
              hasMore: notifications.isNotEmpty,
            );
          },
          failure: (error, _) {
            if (previous.isNotEmpty) {
              _state = NotificationsScreenStateLoaded(
                notifications: previous,
                hasMore: previousLoaded?.hasMore ?? true,
                message: '通知の取得に失敗しました: $error',
              );
            } else {
              _state = NotificationsScreenStateError(
                message: '通知の取得に失敗しました: $error',
              );
            }
          },
        );
        notifyListeners();
      },
      failure: (error, _) async {
        _state = NotificationsScreenStateError(
          message: 'セッション取得に失敗しました: $error',
        );
        notifyListeners();
      },
    );
  }

  Future<void> fetchMore() async {
    final loaded = switch (_state) {
      NotificationsScreenStateLoaded() =>
        _state as NotificationsScreenStateLoaded,
      _ => null,
    };
    if (loaded == null || loaded.isLoadingMore || !loaded.hasMore) return;

    final lastId =
        loaded.notifications.isEmpty ? null : loaded.notifications.last.id;

    _state = NotificationsScreenStateLoaded(
      notifications: loaded.notifications,
      isLoadingMore: true,
      hasMore: loaded.hasMore,
    );
    notifyListeners();

    final sessionResult = await _authRepository.restoreSession();
    await sessionResult.when(
      success: (session) async {
        if (session == null) {
          _state = NotificationsScreenStateLoaded(
            notifications: loaded.notifications,
            hasMore: loaded.hasMore,
            message: '先に認証してください。',
          );
          notifyListeners();
          return;
        }

        final result = await _notificationRepository.fetchGroupedNotifications(
          session,
          untilId: lastId,
        );
        result.when(
          success: (more) {
            final merged = _mergeNotifications(loaded.notifications, more);
            final appendedCount = merged.length - loaded.notifications.length;
            _state = NotificationsScreenStateLoaded(
              notifications: merged,
              hasMore: appendedCount > 0,
            );
          },
          failure: (error, _) {
            _state = NotificationsScreenStateLoaded(
              notifications: loaded.notifications,
              hasMore: loaded.hasMore,
              message: '追加読み込みに失敗しました: $error',
            );
          },
        );
        notifyListeners();
      },
      failure: (error, _) async {
        _state = NotificationsScreenStateLoaded(
          notifications: loaded.notifications,
          hasMore: loaded.hasMore,
          message: 'セッション取得に失敗しました: $error',
        );
        notifyListeners();
      },
    );
  }

  List<MisskeyNotification> _mergeNotifications(
    List<MisskeyNotification> current,
    List<MisskeyNotification> incoming,
  ) {
    final merged = <MisskeyNotification>[];
    final seenIds = <String>{};

    for (final item in [...current, ...incoming]) {
      final id = item.id;
      if (id.isNotEmpty && !seenIds.add(id)) {
        continue;
      }
      merged.add(item);
    }

    return List.unmodifiable(merged);
  }
}
