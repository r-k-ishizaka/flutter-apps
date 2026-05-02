import '../models/auth_session.dart';
import '../models/misskey_notification.dart';
abstract interface class NotificationDataSource {
  Future<List<MisskeyNotification>> fetchGroupedNotifications(
    AuthSession session, {
    int limit = 20,
    String? untilId,
  });
}
