import '../../models/misskey_notification.dart';

sealed class NotificationsScreenState {
  const NotificationsScreenState();
}

class NotificationsScreenStateIdle extends NotificationsScreenState {
  const NotificationsScreenStateIdle();
}

class NotificationsScreenStateLoading extends NotificationsScreenState {
  const NotificationsScreenStateLoading();
}

class NotificationsScreenStateLoaded extends NotificationsScreenState {
  const NotificationsScreenStateLoaded({
    required this.notifications,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.message,
  });

  final List<MisskeyNotification> notifications;
  final bool isLoadingMore;
  final bool hasMore;
  final String? message;
}

class NotificationsScreenStateError extends NotificationsScreenState {
  const NotificationsScreenStateError({this.message});

  final String? message;
}
