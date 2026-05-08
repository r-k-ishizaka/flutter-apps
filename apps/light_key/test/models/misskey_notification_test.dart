import 'package:flutter_test/flutter_test.dart';
import 'package:light_key/models/misskey_notification.dart';

void main() {
  group('MisskeyNotification.fromJson', () {
    test('type ごとに対応する通知クラスを生成できる', () {
      final createdAt = DateTime(2026, 5, 8, 12).toIso8601String();
      final baseUser = <String, dynamic>{'id': 'u1', 'username': 'alice'};
      final baseNote = <String, dynamic>{
        'id': 'n1',
        'text': 'hello',
        'createdAt': createdAt,
        'user': baseUser,
      };

      final samples = <String, Type>{
        'follow': FollowNotification,
        'reply': ReplyNotification,
        'mention': MentionNotification,
        'renote': RenoteNotification,
        'quote': QuoteNotification,
        'reaction': ReactionNotification,
        'reaction:grouped': ReactionGroupedNotification,
        'followRequestAccepted': FollowRequestAcceptedNotification,
        'pollEnded': PollEndedNotification,
        'login': LoginNotification,
      };

      for (final entry in samples.entries) {
        final type = entry.key;
        final expectedType = entry.value;
        final json = <String, dynamic>{
          'id': 'id-$type',
          'createdAt': createdAt,
          'type': type,
          'user': baseUser,
          'note': baseNote,
          'reaction': ':like:',
          'reactions': [
            {'user': baseUser, 'reaction': ':like:'},
          ],
          'message': 'ok',
          'body': 'ok',
        };

        final notification = MisskeyNotification.fromJson(json);
        expect(notification.runtimeType, expectedType, reason: 'type=$type');
      }
    });

    test('未知 type は UnknownNotification へフォールバックする', () {
      final notification = MisskeyNotification.fromJson({
        'id': 'id-unknown',
        'createdAt': DateTime(2026, 5, 8, 12).toIso8601String(),
        'type': 'not-supported-yet',
      });

      expect(notification, isA<UnknownNotification>());
      expect(notification.type, 'not-supported-yet');
    });

    test('user/note 欠損でも例外を投げずに生成できる', () {
      final notification = MisskeyNotification.fromJson({
        'id': 'id-reply',
        'createdAt': DateTime(2026, 5, 8, 12).toIso8601String(),
        'type': 'reply',
      });

      expect(notification, isA<ReplyNotification>());
      final reply = notification as ReplyNotification;
      expect(reply.user.id, isEmpty);
      expect(reply.note.id, isEmpty);
    });
  });
}
