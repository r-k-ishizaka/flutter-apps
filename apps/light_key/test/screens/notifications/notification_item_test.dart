import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:light_key/models/misskey_notification.dart';
import 'package:light_key/models/user.dart';
import 'package:light_key/screens/notifications/notification_item.dart';
import 'package:light_key/services/emoji_cache.dart';

void main() {
  group('NotificationItem avatar tap', () {
    testWidgets('ユーザIDがある通知アバターをタップするとコールバックが呼ばれる', (tester) async {
      User? tappedUser;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationItem(
              notification: FollowNotification(
                id: 'notification-1',
                createdAt: DateTime(2026, 5, 3, 12),
                user: const User(
                  id: 'user-42',
                  username: 'alice',
                  name: 'Alice',
                ),
              ),
              emojis: const <String, EmojiCacheEntry>{},
              onUserTap: (user) => tappedUser = user,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(tappedUser?.id, 'user-42');
      expect(tappedUser?.username, 'alice');
    });

    testWidgets('ユーザIDがない通知アバターはタップ可能にならない', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationItem(
              notification: FollowNotification(
                id: 'notification-1',
                createdAt: DateTime(2026, 5, 3, 12),
                user: const User(username: 'alice', name: 'Alice'),
              ),
              emojis: const <String, EmojiCacheEntry>{},
              onUserTap: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('コールバック未指定の通知アバターはタップ可能にならない', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationItem(
              notification: FollowNotification(
                id: 'notification-1',
                createdAt: DateTime(2026, 5, 3, 12),
                user: const User(
                  id: 'user-42',
                  username: 'alice',
                  name: 'Alice',
                ),
              ),
              emojis: const <String, EmojiCacheEntry>{},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(InkWell), findsNothing);
    });
  });
}
