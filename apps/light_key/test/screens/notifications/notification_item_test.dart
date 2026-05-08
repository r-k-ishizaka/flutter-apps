import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:light_key/models/misskey_notification.dart';
import 'package:light_key/models/note.dart';
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

  group('NotificationItem note tap', () {
    testWidgets('ノートIDがある本文をタップするとコールバックが呼ばれる', (tester) async {
      String? tappedNoteId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationItem(
              notification: ReactionNotification(
                id: 'notification-1',
                createdAt: DateTime(2026, 5, 3, 12),
                user: const User(id: 'user-42', username: 'alice', name: 'Alice'),
                note: Note(
                  id: 'note-99',
                  text: 'ノート本文',
                  createdAt: DateTime(2026, 5, 1, 10),
                  user: const User(id: 'author-1', username: 'bob', name: 'Bob'),
                ),
                reaction: ':like:',
              ),
              emojis: const <String, EmojiCacheEntry>{},
              onNoteTap: (noteId) => tappedNoteId = noteId,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('ノート本文'));
      await tester.pumpAndSettle();

      expect(tappedNoteId, 'note-99');
    });

    testWidgets('ノートIDが空の本文はタップしてもコールバックが呼ばれない', (tester) async {
      String? tappedNoteId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationItem(
              notification: ReactionNotification(
                id: 'notification-1',
                createdAt: DateTime(2026, 5, 3, 12),
                user: const User(id: 'user-42', username: 'alice', name: 'Alice'),
                note: Note(
                  text: 'ノート本文',
                  createdAt: DateTime(2026, 5, 1, 10),
                  user: const User(id: 'author-1', username: 'bob', name: 'Bob'),
                ),
                reaction: ':like:',
              ),
              emojis: const <String, EmojiCacheEntry>{},
              onNoteTap: (noteId) => tappedNoteId = noteId,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('ノート本文'));
      await tester.pumpAndSettle();

      expect(tappedNoteId, isNull);
    });

    testWidgets('ノートIDがある本文でも右アイコンは表示されない', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationItem(
              notification: ReactionNotification(
                id: 'notification-1',
                createdAt: DateTime(2026, 5, 3, 12),
                user: const User(id: 'user-42', username: 'alice', name: 'Alice'),
                note: Note(
                  id: 'note-99',
                  text: 'ノート本文',
                  createdAt: DateTime(2026, 5, 1, 10),
                  user: const User(id: 'author-1', username: 'bob', name: 'Bob'),
                ),
                reaction: ':like:',
              ),
              emojis: const <String, EmojiCacheEntry>{},
              onNoteTap: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.open_in_new), findsNothing);
    });

    testWidgets('ノートIDが空の本文でも右アイコンは表示されない', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationItem(
              notification: ReactionNotification(
                id: 'notification-1',
                createdAt: DateTime(2026, 5, 3, 12),
                user: const User(id: 'user-42', username: 'alice', name: 'Alice'),
                note: Note(
                  text: 'ノート本文',
                  createdAt: DateTime(2026, 5, 1, 10),
                  user: const User(id: 'author-1', username: 'bob', name: 'Bob'),
                ),
                reaction: ':like:',
              ),
              emojis: const <String, EmojiCacheEntry>{},
              onNoteTap: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.open_in_new), findsNothing);
    });
  });
}
