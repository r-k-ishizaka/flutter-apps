import 'package:flutter_test/flutter_test.dart';
import 'package:light_key/utils/emoji_extractor.dart';

void main() {
  group('EmojiExtractor - Remote Reactions Detection', () {
    test('Extract emoji from reactions with remote host', () {
      // Simulates a note with reactions from remote server emojis
      // This is the case where blobcat_poke_ is reacted by another server user
      final noteResponse = {
        'id': 'note-1',
        'text': 'Hello world',
        'user': {
          'id': 'user-1',
          'username': 'alice',
        },
        'reactions': {
          ':blobcat_poke_@user.server:': 1,
          ':custom@.:': 1,
          '👍': 2,
        },
      };

      final result = EmojiExtractor.extractFromResponse(noteResponse);

      // Local emoji from this server
      expect(result.localNames, contains('custom'));

      // Remote emoji should NOT be in emojisToCache (no URL provided)
      // It's just marked for URL lookup in reactionEmojis
      expect(result.emojisToCache.containsKey('blobcat_poke_@user.server'), false);
    });

    test('Extract emoji from reactionEmojis with URL', () {
      // This is when reactionEmojis field contains the URL
      final noteResponse = {
        'id': 'note-1',
        'text': 'Hello world',
        'user': {
          'id': 'user-1',
          'username': 'alice',
        },
        'reactions': {
          ':blobcat_poke_@user.server:': 1,
          ':custom:.': 1,
          '👍': 2,
        },
        'reactionEmojis': {
          'blobcat_poke_@user.server': 'https://user.server/emoji/blobcat_poke_.png',
          'custom': 'https://my.server/emoji/custom.png',
        },
      };

      final result = EmojiExtractor.extractFromResponse(noteResponse);

      // Remote emoji URL should be extracted from reactionEmojis
      expect(result.emojisToCache, containsPair('blobcat_poke_@user.server', 'https://user.server/emoji/blobcat_poke_.png'));

      // Custom emoji from this server should be in emojisToCache if URL in reactionEmojis
      expect(result.emojisToCache, containsPair('custom', 'https://my.server/emoji/custom.png'));
    });

    test('API response with mixed emoji sources', () {
      // Realistic timeline response with multiple emoji sources
      final timelineResponse = [
        {
          'id': 'note-1',
          'text': ':sumi: :custom: Hello',
          'user': {
            'id': 'user-1',
            'username': 'bob',
            'emojis': [
              {'name': 'sumi', 'url': 'https://bob.server/emoji/sumi.png'},
            ],
          },
          'emojis': [
            {'name': 'custom', 'url': 'https://my.server/emoji/custom.png'},
          ],
          'reactions': {
            ':blobcat_poke_@otter.server:': 2,
            ':yatta@.:': 1,
            '👍': 3,
          },
          'reactionEmojis': {
            'blobcat_poke_@otter.server': 'https://otter.server/emoji/blobcat_poke_.png',
          },
        },
      ];

      final result = EmojiExtractor.extractFromResponse(timelineResponse);

      // Should have:
      // 1. Custom from text emojis
      expect(result.emojisToCache, containsPair('custom', 'https://my.server/emoji/custom.png'));

      // 2. Sumi from user emojis
      expect(result.emojisToCache, containsPair('sumi', 'https://bob.server/emoji/sumi.png'));

      // 3. blobcat_poke_ from reactionEmojis
      expect(result.emojisToCache, containsPair('blobcat_poke_@otter.server', 'https://otter.server/emoji/blobcat_poke_.png'));

      // 4. yatta should be in localNames (local emoji, URL to be resolved from cache)
      expect(result.localNames, contains('yatta'));
    });

    test('reactionEmojis with complex nested structure', () {
      // Some Misskey instances might return more complex emoji objects
      final noteResponse = {
        'id': 'note-1',
        'reactions': {
          ':emoji1@host1:': 1,
          ':emoji2@.:': 1,
        },
        'reactionEmojis': {
          'emoji1@host1': {
            'url': 'https://host1.com/emoji1.png',
            'uri': 'https://host1.com/emoji1',
            'type': 'image/png',
            'width': 64,
            'height': 64,
          },
          'emoji2': {
            'url': 'https://myserver.com/emoji2.png',
          },
        },
      };

      final result = EmojiExtractor.extractFromResponse(noteResponse);


      // Should extract URL from nested map
      expect(result.emojisToCache, containsPair('emoji1@host1', 'https://host1.com/emoji1.png'));
      expect(result.emojisToCache, containsPair('emoji2', 'https://myserver.com/emoji2.png'));

      // emoji2 should NOT be in localNames because URL is provided in reactionEmojis
      expect(result.localNames.contains('emoji2'), false);
    });
  });
}
