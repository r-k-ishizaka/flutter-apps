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

  List<MisskeyNotification> get _loadedNotifications => switch (_state) {
        NotificationsScreenStateLoaded(:final notifications) => notifications,
        _ => const <MisskeyNotification>[],
      };

  Future<void> fetch({bool showLoading = true}) async {
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
              notifications: notifications,
              hasMore: notifications.length >= 20,
            );
          },
          failure: (error, _) {
            if (previous.isNotEmpty) {
              _state = NotificationsScreenStateLoaded(
                notifications: previous,
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
        if (session == null) return;

        final result = await _notificationRepository.fetchGroupedNotifications(
          session,
          untilId: lastId,
        );
        result.when(
          success: (more) {
            final merged = [...loaded.notifications, ...more];
            _state = NotificationsScreenStateLoaded(
              notifications: List.unmodifiable(merged),
              hasMore: more.length >= 20,
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
}
