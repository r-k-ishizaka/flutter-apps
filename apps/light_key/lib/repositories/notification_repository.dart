import 'package:core/models/result.dart';

import '../datasources/notification_data_source.dart';
import '../models/auth_session.dart';
import '../models/misskey_notification.dart';

class NotificationRepository {
  NotificationRepository(this._dataSource);

  final NotificationDataSource _dataSource;

  Future<Result<List<MisskeyNotification>>> fetchGroupedNotifications(
    AuthSession session, {
    int limit = 20,
    String? untilId,
  }) async {
    try {
      final items = await _dataSource.fetchGroupedNotifications(
        session,
        limit: limit,
        untilId: untilId,
      );
      return Success(items);
    } on Exception catch (e, st) {
      return Failure(e, st);
    }
  }
}
