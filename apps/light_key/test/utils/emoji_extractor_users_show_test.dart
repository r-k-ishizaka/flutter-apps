import 'package:flutter_test/flutter_test.dart';
import 'package:light_key/utils/emoji_extractor.dart';

void main() {
  group('EmojiExtractor - /api/users/show response', () {
    test('Extract emojis from synthetic users/show response', () {
      // 匿名化済みの合成 /api/users/show レスポンスサンプル
      final userShowResponse = {
        "id": "user-remote-1",
        "name": ":emoji_alpha:display-name:emoji_beta:",
        "username": "remote_user",
        "host": "remote.example.test",
        "emojis": {
          "emoji_alpha":
              "https://cdn.remote.example.test/media/emoji_alpha.png",
          "emoji_beta":
              "https://cdn.remote.example.test/media/emoji_beta.gif",
          "emoji_gamma":
              "https://cdn.remote.example.test/media/emoji_gamma.gif"
        },
        "pinnedNotes": [
          {
            "id": "note-1",
            "createdAt": "2026-01-12T07:52:27.659Z",
            "text": "synthetic pinned note",
            "reactionCount": 16,
            "reactions": {
              "🆗": 2,
              ":local_alpha@.:": 1,
              ":local_beta@.:": 1,
              ":remote_emoji_a@remote.example.test:": 1,
              ":local_gamma@.:": 2,
              ":cross_server_emoji@federated.example.test:": 1,
              ":local_beta@remote.example.test:": 5,
              ":remote_emoji_b@another.example.test:": 1,
              ":remote_emoji_c@remote.example.test:": 1,
              ":remote_emoji_d@remote.example.test:": 1
            },
            "reactionEmojis": {
              "remote_emoji_a@remote.example.test":
                  "https://cdn.remote.example.test/media/remote_emoji_a.png",
              "cross_server_emoji@federated.example.test":
                  "https://cdn.federated.example.test/storage/cross_server_emoji.png",
              "local_beta@remote.example.test":
                  "https://cdn.remote.example.test/media/local_beta.png",
              "remote_emoji_b@another.example.test":
                  "https://cdn.another.example.test/media/remote_emoji_b.png",
              "remote_emoji_c@remote.example.test":
                  "https://cdn.remote.example.test/media/remote_emoji_c.gif",
              "remote_emoji_d@remote.example.test":
                  "https://cdn.remote.example.test/media/remote_emoji_d.gif"
            },
            "emojis": {}
          },
          {
            "id": "note-2",
            "createdAt": "2026-01-08T20:42:56.539Z",
            "text": "another synthetic pinned note",
            "reactionCount": 4,
            "reactions": {
              ":local_delta@.:": 1,
              ":local_epsilon@.:": 1,
              ":remote_emoji_e@remote.example.test:": 1,
              ":remote_emoji_f@remote.example.test:": 1
            },
            "reactionEmojis": {
              "remote_emoji_e@remote.example.test":
                  "https://cdn.remote.example.test/media/remote_emoji_e.gif",
              "remote_emoji_f@remote.example.test":
                  "https://cdn.remote.example.test/media/remote_emoji_f.gif"
            },
            "emojis": {},
            "myReaction": ":local_epsilon@.:"
          }
        ]
      };

      final result =
          EmojiExtractor.extractFromResponse(userShowResponse);

      // ユーザーの emojis フィールドから抽出されるべき
      expect(result.emojisToCache,
          containsPair('emoji_alpha@remote.example.test',
              'https://cdn.remote.example.test/media/emoji_alpha.png'));
      expect(result.emojisToCache,
          containsPair('emoji_beta@remote.example.test',
              'https://cdn.remote.example.test/media/emoji_beta.gif'));
      expect(result.emojisToCache,
          containsPair('emoji_gamma@remote.example.test',
              'https://cdn.remote.example.test/media/emoji_gamma.gif'));

      // pinnedNotes の reactionEmojis から抽出されるべき（リモート絵文字）
      expect(result.emojisToCache,
          containsPair('remote_emoji_a@remote.example.test',
              'https://cdn.remote.example.test/media/remote_emoji_a.png'));
      expect(result.emojisToCache,
          containsPair('cross_server_emoji@federated.example.test',
              'https://cdn.federated.example.test/storage/cross_server_emoji.png'));
      expect(result.emojisToCache,
          containsPair('remote_emoji_b@another.example.test',
              'https://cdn.another.example.test/media/remote_emoji_b.png'));
      expect(result.emojisToCache,
          containsPair('remote_emoji_e@remote.example.test',
              'https://cdn.remote.example.test/media/remote_emoji_e.gif'));

      // reactions から抽出されるべき（自鯖絵文字）
      expect(result.localNames, contains('local_alpha'));
      expect(result.localNames, contains('local_beta'));
      expect(result.localNames, contains('local_gamma'));
      expect(result.localNames, contains('local_delta'));
      expect(result.localNames, contains('local_epsilon'));
    });

    test('Verify no duplicate keys', () {
      final userShowResponse = {
        "id": "user-remote-2",
        "name": ":emoji_alpha:display-name",
        "username": "remote_user_2",
        "emojis": {
          "emoji_alpha":
              "https://cdn.remote.example.test/media/emoji_alpha.png",
        },
        "pinnedNotes": [
          {
            "id": "note1",
            "reactions": {
              ":emoji_alpha@.:": 1,
            },
            "reactionEmojis": {
              "emoji_alpha":
                  "https://cdn.remote.example.test/media/emoji_alpha.png",
            }
          }
        ]
      };

      final result =
          EmojiExtractor.extractFromResponse(userShowResponse);

      // emoji_alpha は複数のフィールドから見つかる可能性があるが、
      // キャッシュには1つのエントリとしてのみ存在してる必要がある
      expect(result.emojisToCache.keys.toList().where((k) => k.contains('emoji_alpha')).length, 1);
    });
  });
}
