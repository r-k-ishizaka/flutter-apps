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
                user: const User(
                  id: 'user-42',
                  username: 'alice',
                  name: 'Alice',
                ),
                note: Note(
                  id: 'note-99',
                  text: 'ノート本文',
                  createdAt: DateTime(2026, 5, 1, 10),
                  user: const User(
                    id: 'author-1',
                    username: 'bob',
                    name: 'Bob',
                  ),
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
                user: const User(
                  id: 'user-42',
                  username: 'alice',
                  name: 'Alice',
                ),
                note: Note(
                  text: 'ノート本文',
                  createdAt: DateTime(2026, 5, 1, 10),
                  user: const User(
                    id: 'author-1',
                    username: 'bob',
                    name: 'Bob',
                  ),
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
                user: const User(
                  id: 'user-42',
                  username: 'alice',
                  name: 'Alice',
                ),
                note: Note(
                  id: 'note-99',
                  text: 'ノート本文',
                  createdAt: DateTime(2026, 5, 1, 10),
                  user: const User(
                    id: 'author-1',
                    username: 'bob',
                    name: 'Bob',
                  ),
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
                user: const User(
                  id: 'user-42',
                  username: 'alice',
                  name: 'Alice',
                ),
                note: Note(
                  text: 'ノート本文',
                  createdAt: DateTime(2026, 5, 1, 10),
                  user: const User(
                    id: 'author-1',
                    username: 'bob',
                    name: 'Bob',
                  ),
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

  group('NotificationItem new notification types', () {
    testWidgets('reply 通知の本文が表示される', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationItem(
              notification: ReplyNotification(
                id: 'notification-reply',
                createdAt: DateTime(2026, 5, 3, 12),
                user: const User(
                  id: 'user-1',
                  username: 'alice',
                  name: 'Alice',
                ),
                note: Note(
                  id: 'note-reply',
                  text: '返信本文',
                  createdAt: DateTime(2026, 5, 1, 10),
                  user: const User(
                    id: 'author-1',
                    username: 'bob',
                    name: 'Bob',
                  ),
                ),
              ),
              emojis: const <String, EmojiCacheEntry>{},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('返信本文'), findsOneWidget);
      expect(find.text('@bob'), findsOneWidget);
    });

    testWidgets('mention 通知の本文が表示される', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationItem(
              notification: MentionNotification(
                id: 'notification-mention',
                createdAt: DateTime(2026, 5, 3, 12),
                user: const User(
                  id: 'user-1',
                  username: 'alice',
                  name: 'Alice',
                ),
                note: Note(
                  id: 'note-mention',
                  text: 'メンション本文',
                  createdAt: DateTime(2026, 5, 1, 10),
                  user: const User(
                    id: 'author-1',
                    username: 'bob',
                    name: 'Bob',
                  ),
                ),
              ),
              emojis: const <String, EmojiCacheEntry>{},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('メンション本文'), findsOneWidget);
      expect(find.text('@bob'), findsOneWidget);
    });

    testWidgets('renote 通知の本文タップでノートコールバックが呼ばれる', (tester) async {
      String? tappedNoteId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationItem(
              notification: RenoteNotification(
                id: 'notification-renote',
                createdAt: DateTime(2026, 5, 3, 12),
                user: const User(
                  id: 'user-1',
                  username: 'alice',
                  name: 'Alice',
                ),
                note: Note(
                  id: 'note-renote',
                  text: 'リノート本文',
                  createdAt: DateTime(2026, 5, 1, 10),
                  user: const User(
                    id: 'author-1',
                    username: 'bob',
                    name: 'Bob',
                  ),
                ),
              ),
              emojis: const <String, EmojiCacheEntry>{},
              onNoteTap: (noteId) => tappedNoteId = noteId,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('リノートしました'), findsOneWidget);
      await tester.tap(find.text('リノート本文'));
      await tester.pumpAndSettle();
      expect(tappedNoteId, 'note-renote');
    });

    testWidgets('renote 通知が純粋リノートでも元ノート本文を表示できる', (tester) async {
      String? tappedNoteId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationItem(
              notification: RenoteNotification(
                id: 'notification-renote-pure',
                createdAt: DateTime(2026, 5, 3, 12),
                user: const User(
                  id: 'renoter-1',
                  username: 'alice',
                  name: 'Alice',
                ),
                note: Note(
                  id: 'note-wrapper',
                  text: '',
                  createdAt: DateTime(2026, 5, 3, 12),
                  user: const User(
                    id: 'renoter-1',
                    username: 'alice',
                    name: 'Alice',
                  ),
                  renote: Note(
                    id: 'note-origin',
                    text: '元ノート本文',
                    createdAt: DateTime(2026, 5, 1, 10),
                    user: const User(
                      id: 'author-1',
                      username: 'bob',
                      name: 'Bob',
                    ),
                  ),
                ),
              ),
              emojis: const <String, EmojiCacheEntry>{},
              onNoteTap: (noteId) => tappedNoteId = noteId,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('元ノート本文'), findsOneWidget);
      await tester.tap(find.text('元ノート本文'));
      await tester.pumpAndSettle();
      expect(tappedNoteId, 'note-origin');
    });

    testWidgets('quote 通知で本文と引用元が表示される', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationItem(
              notification: QuoteNotification(
                id: 'notification-quote',
                createdAt: DateTime(2026, 5, 3, 12),
                user: const User(
                  id: 'user-1',
                  username: 'alice',
                  name: 'Alice',
                ),
                note: Note(
                  id: 'note-quote-body',
                  text: '引用コメント本文',
                  createdAt: DateTime(2026, 5, 1, 10),
                  user: const User(
                    id: 'author-1',
                    username: 'bob',
                    name: 'Bob',
                  ),
                  renote: Note(
                    id: 'note-quote-origin',
                    text: '引用元本文',
                    createdAt: DateTime(2026, 4, 30, 21),
                    user: const User(
                      id: 'author-2',
                      username: 'carol',
                      name: 'Carol',
                    ),
                  ),
                ),
              ),
              emojis: const <String, EmojiCacheEntry>{},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('引用しました'), findsNothing);
      expect(find.text('引用コメント本文'), findsOneWidget);
      expect(find.text('引用元本文'), findsOneWidget);
    });

    testWidgets('pollEnded 通知の本文タップでノートコールバックが呼ばれる', (tester) async {
      String? tappedNoteId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationItem(
              notification: PollEndedNotification(
                id: 'notification-poll-ended',
                createdAt: DateTime(2026, 5, 3, 12),
                note: Note(
                  id: 'note-poll',
                  text: '投票対象ノート',
                  createdAt: DateTime(2026, 5, 1, 10),
                  user: const User(
                    id: 'author-1',
                    username: 'bob',
                    name: 'Bob',
                  ),
                ),
              ),
              emojis: const <String, EmojiCacheEntry>{},
              onNoteTap: (noteId) => tappedNoteId = noteId,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('投票が終了しました'), findsOneWidget);
      await tester.tap(find.text('投票対象ノート'));
      await tester.pumpAndSettle();
      expect(tappedNoteId, 'note-poll');
    });

    testWidgets('login 通知を描画できる', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationItem(
              notification: LoginNotification(
                id: 'notification-login',
                createdAt: DateTime(2026, 5, 3, 12),
                message: '新しい端末からログインしました',
              ),
              emojis: const <String, EmojiCacheEntry>{},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ログイン通知'), findsOneWidget);
      expect(find.text('新しい端末からログインしました'), findsOneWidget);
    });
  });
}
