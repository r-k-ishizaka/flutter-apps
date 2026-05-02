import '../models/auth_session.dart';
import '../models/misskey_notification.dart';
import '../utils/misskey_http_client.dart';
import 'notification_data_source.dart';
class MisskeyNotificationDataSource implements NotificationDataSource {
  MisskeyNotificationDataSource(this._client);
  final MisskeyHttpClient _client;
  @override
  Future<List<MisskeyNotification>> fetchGroupedNotifications(
    AuthSession session, {
    int limit = 20,
    String? untilId,
  }) async {
    final body = <String, dynamic>{
      'i': session.accessToken,
      'limit': limit,
      'allowPartial': true,
    };
    if (untilId != null) {
      body['untilId'] = untilId;
    }
    final list = await _client.postJsonList(
      baseUrl: session.baseUrl,
      path: '/api/i/notifications-grouped',
      body: body,
    );
    return list
        .map(MisskeyNotification.fromJson)
        .toList(growable: false);
  }
}
