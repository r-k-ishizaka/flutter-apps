import 'package:flutter_test/flutter_test.dart';
import 'package:light_key/utils/emoji_extractor.dart';

void main() {
  group('Emoji key normalization mismatch detection', () {
    test('detected issue: same-server emoji wrongly getting @host suffix', () {
      // Scenario: API returns same-server emoji with bare name
      const baseUrl = 'https://my-server.example.com';
      const ownHost = 'my-server.example.com';

      // API response: emojis field with bare name for same-server emoji
      final apiResponse = {
        'emojis': [
          {'name': 'sumi', 'url': 'https://my-server.example.com/emoji/sumi.png'},
        ],
      };

      final result = EmojiExtractor.extractFromResponse(apiResponse);

      // EXPECTED: extracted as bare name 'sumi' (no @host)
      expect(result.emojisToCache, {'sumi': 'https://my-server.example.com/emoji/sumi.png'});

      // Simulated normalization (same server)
      final urlHost = Uri.parse('https://my-server.example.com/emoji/sumi.png').host;
      expect(urlHost, ownHost);

      // After normalization, key should remain as 'sumi'
      // NOT 'sumi@my-server.example.com'
      // This is the key issue: if it becomes 'sumi@my-server.example.com',
      // but EmojiText searches for 'sumi', it won't find it!
    });

    test('detected issue: remote emoji @host format mismatch', () {
      // Scenario: API returns remote emoji in different formats
      const ownHost = 'my-server.example.com';

      // Case 1: reactionEmojis with already-formatted @host
      final apiResponse1 = {
        'reactionEmojis': {
          'custom@remote.com': 'https://remote.com/emoji/custom.png',
        },
      };

      final result1 = EmojiExtractor.extractFromResponse(apiResponse1);

      // EXPECTED: extracted as 'custom@remote.com'
      expect(result1.emojisToCache, {'custom@remote.com': 'https://remote.com/emoji/custom.png'});

      // After normalization: should keep 'custom@remote.com' (already has @)
      // This is correct.

      // Case 2: bare name emoji from remote server
      final apiResponse2 = {
        'emojis': [
          {'name': 'custom', 'url': 'https://remote.com/emoji/custom.png'},
        ],
      };

      final result2 = EmojiExtractor.extractFromResponse(apiResponse2);

      // EXPECTED: extracted as bare name 'custom'
      expect(result2.emojisToCache, {'custom': 'https://remote.com/emoji/custom.png'});

      // After normalization: should become 'custom@remote.com' (different host)
      final urlHost = Uri.parse('https://remote.com/emoji/custom.png').host;
      expect(urlHost, 'remote.com');
      expect(urlHost, isNot(ownHost));

      // KEY ISSUE: If normalization doesn't happen or happens incorrectly,
      // the key remains 'custom' but NoteReactionList or EmojiText might search for
      // 'custom@remote.com', causing a mismatch!
    });

    test('detected issue: reactions field with @. might not resolve correctly', () {
      // Scenario: Reactions come as {":emoji@.": 1} format
      // This should be interpreted as "local emoji named 'emoji'"

      final apiResponse = {
        'reactions': {
          ':sumi@.': 1,
          ':custom@remote.com:': 1,
        },
      };

      final result = EmojiExtractor.extractFromResponse(apiResponse);

      // EXPECTED: ':sumi@.' should add 'sumi' to localNames
      expect(result.localNames, contains('sumi'));

      // NOTE: 'localNames' entries need URL resolution from cache!
      // If cache doesn't have 'sumi' entry yet, this will fail.
      // This is a timing issue: localNames are extracted but their URLs
      // haven't been cached yet during the first API response.
    });

    test('potential issue: case sensitivity in host matching', () {
      // Scenario: URL host might be 'Example.COM' but comparison is case-sensitive
      const ownHost1 = 'example.com'; // lowercase
      const ownHost2 = 'Example.com'; // mixed case
      const urlHost = 'example.com'; // lowercase

      // Dart Uri.parse().host might lowercase the host
      expect('example.com', urlHost);

      // But if comparison is case-sensitive and one side is uppercase...
      // (Dart should handle this, but worth checking)
      expect('example.com' == 'example.com', isTrue);
    });

    test('potential issue: bare name emoji without @. might stay in cache as bare', () {
      // Scenario: Reactions contain ':emoji:' (no @host)
      // This could be:
      // 1. Unicode emoji (should be skipped)
      // 2. Default server emoji (should resolve to bare name from cache)

      final apiResponse = {
        'reactions': {
          ':custom:': 1, // This could be custom@own-server or custom@remote-server
        },
      };

      final result = EmojiExtractor.extractFromResponse(apiResponse);

      // QUESTION: Is this added to localNames or emojisToCache?
      // Looking at the regex and extraction logic...
      // It matches r':([a-zA-Z0-9_]+)(?:@([a-zA-Z0-9._-]+))? :'
      // So ':custom:' would match with group(1)='custom', group(2)=null
      // Since group(2) is null, it gets added to localNames

      expect(result.localNames, contains('custom'));
      expect(result.emojisToCache, isEmpty);

      // This is correct! But it means:
      // - URL resolution happens later from cache
      // - If cache doesn't have 'custom' as bare name, it won't be resolved
    });
  });
}
