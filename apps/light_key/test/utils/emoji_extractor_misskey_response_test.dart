import 'package:flutter_test/flutter_test.dart';
import 'package:light_key/utils/emoji_extractor.dart';

void main() {
  group('EmojiExtractor with simulated Misskey API responses', () {
    test('timeline response with custom emojis', () {
      // Simulated Misskey timeline API response structure for a note with custom emoji
      final timelineResponse = [
        {
          'id': 'note-1',
          'text': ':sumi: こんにちは',
          'user': {
            'id': 'user-1',
            'username': 'admin',
            'name': ':admin: Admin',
          },
          'emojis': [
            {'name': 'sumi', 'url': 'https://example.com/sumi.png'},
            {'name': 'admin', 'url': 'https://example.com/admin.png'},
          ],
          'reactions': {
            ':custom:.': 1,
            ':remote@example.com:': 1,
            '👍': 2,
          },
          'reactionEmojis': {
            'remote@example.com': 'https://example.com/remote.png',
          },
        },
      ];

      final result = EmojiExtractor.extractFromResponse(timelineResponse);

      expect(result.emojisToCache, containsPair('sumi', 'https://example.com/sumi.png'));
      expect(result.emojisToCache, containsPair('admin', 'https://example.com/admin.png'));
      expect(result.emojisToCache, containsPair('remote@example.com', 'https://example.com/remote.png'));
      expect(result.localNames, contains('custom'));
    });

    test('note response with nested emoji references', () {
      final noteResponse = {
        'id': 'note-1',
        'text': ':sumi: グッモーニング',
        'user': {
          'id': 'user-1',
          'username': 'user',
          'name': ':sumi: User',
          'emojis': [
            {'name': 'sumi', 'url': 'https://example.com/sumi.png'},
          ],
        },
        'renote': {
          'id': 'renote-1',
          'text': ':custom: original post',
          'emojis': [
            {'name': 'custom', 'url': 'https://example.com/custom.png'},
          ],
        },
      };

      final result = EmojiExtractor.extractFromResponse(noteResponse);

      expect(result.emojisToCache, containsPair('sumi', 'https://example.com/sumi.png'));
      expect(result.emojisToCache, containsPair('custom', 'https://example.com/custom.png'));
    });

    test('response without any emojis', () {
      final response = {
        'id': 'note-1',
        'text': 'no emojis here',
        'user': {'id': 'user-1', 'username': 'admin'},
      };

      final result = EmojiExtractor.extractFromResponse(response);

      expect(result.isEmpty, isTrue);
    });

    test('reactionEmojis at top level', () {
      // Some API responses might have reactionEmojis at the top level
      final response = {
        'reactionEmojis': {
          'emoji1@host.com': 'https://host.com/emoji1.png',
          'emoji2': 'https://self.com/emoji2.png',
        },
      };

      final result = EmojiExtractor.extractFromResponse(response);

      expect(result.emojisToCache, containsPair('emoji1@host.com', 'https://host.com/emoji1.png'));
      expect(result.emojisToCache, containsPair('emoji2', 'https://self.com/emoji2.png'));
    });
  });
}
