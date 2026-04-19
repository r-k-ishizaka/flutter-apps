import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';

final _logger = Logger();

Future<void> requestNotificationPermission() async {
  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  _logger.i('User granted permission: ${settings.authorizationStatus}');
}
