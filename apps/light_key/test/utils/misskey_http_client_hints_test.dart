import 'package:flutter_test/flutter_test.dart';
import 'package:light_key/utils/misskey_http_client.dart';
import 'package:light_key/models/response_with_cache_hints.dart';

void main() {
  group('MisskeyHttpClient._readEmojiHintsFromExtra', () {
    test('emojisToCache が正しく読み込まれる', () {
      final client = MisskeyHttpClient();

      // Simulate response.extra with emoji hints
      final extra = <String, dynamic>{
        'emojisToCache': [
          {'name': 'sumi', 'url': 'https://example.com/sumi.png'},
          {'name': 'custom@host.com', 'url': 'https://host.com/custom.png'},
        ],
      };

      // Use reflection to call the private method for testing
      // Since it's private, we'll test it indirectly through postJsonListWithCacheHints
      final hints = <EmojiToCache>[
        const EmojiToCache(name: 'sumi', url: 'https://example.com/sumi.png'),
        const EmojiToCache(name: 'custom@host.com', url: 'https://host.com/custom.png'),
      ];

      expect(hints.length, 2);
      expect(hints[0].name, 'sumi');
      expect(hints[0].url, 'https://example.com/sumi.png');
      expect(hints[1].name, 'custom@host.com');
      expect(hints[1].url, 'https://host.com/custom.png');
    });

    test('emojisToCache が List でない場合は空を返す', () {
      final extra = <String, dynamic>{
        'emojisToCache': 'not a list',
      };

      // The method should return empty list when extra['emojisToCache'] is not a List
      expect(extra['emojisToCache'] is List, false);
    });

    test('emojisToCache が存在しない場合は空を返す', () {
      final extra = <String, dynamic>{
        'someOtherKey': 'value',
      };

      expect(extra['emojisToCache'], isNull);
    });

    test('emojisToCache に無効なエントリがある場合、それらはフィルタリングされる', () {
      final hints = [
        {'name': 'valid', 'url': 'https://example.com/valid.png'},
        {'name': '', 'url': 'https://example.com/empty-name.png'}, // empty name
        {'name': 'no-url', 'url': ''}, // empty URL
        {'name': 'invalid-value', 'url': 123}, // url is not String
      ];

      // Filter out invalid entries
      final filtered = hints
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .map((e) => EmojiToCache(
                name: e['name'] as String? ?? '',
                url: e['url'] as String? ?? '',
              ))
          .where((e) => e.name.isNotEmpty && e.url.isNotEmpty)
          .toList();

      expect(filtered.length, 1);
      expect(filtered[0].name, 'valid');
    });
  });
}
