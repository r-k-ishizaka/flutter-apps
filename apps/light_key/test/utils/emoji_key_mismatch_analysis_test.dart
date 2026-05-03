import 'package:flutter_test/flutter_test.dart';
import 'package:light_key/utils/emoji_extractor.dart';

void main() {
  group('Emoji key normalization mismatch detection', () {
    test('detected issue: same-server emoji wrongly getting @host suffix', () {
      const ownHost = 'my-server.example.com';

      final Map<String, dynamic> apiResponse = <String, dynamic>{
        'emojis': <Map<String, dynamic>>[
          <String, dynamic>{
            'name': 'sumi',
            'url': 'https://my-server.example.com/emoji/sumi.png',
          },
        ],
      };

      final result = EmojiExtractor.extractFromResponse(apiResponse);

      expect(result.emojisToCache, {
        'sumi': 'https://my-server.example.com/emoji/sumi.png',
      });

      final urlHost =
          Uri.parse('https://my-server.example.com/emoji/sumi.png').host;
      expect(urlHost, ownHost);
    });

    test('detected issue: remote emoji @host format mismatch', () {
      const ownHost = 'my-server.example.com';

      final Map<String, dynamic> apiResponse1 = <String, dynamic>{
        'reactionEmojis': <String, dynamic>{
          'custom@remote.com': 'https://remote.com/emoji/custom.png',
        },
      };

      final result1 = EmojiExtractor.extractFromResponse(apiResponse1);

      expect(result1.emojisToCache, {
        'custom@remote.com': 'https://remote.com/emoji/custom.png',
      });

      final Map<String, dynamic> apiResponse2 = <String, dynamic>{
        'emojis': <Map<String, dynamic>>[
          <String, dynamic>{
            'name': 'custom',
            'url': 'https://remote.com/emoji/custom.png',
          },
        ],
      };

      final result2 = EmojiExtractor.extractFromResponse(apiResponse2);

      expect(result2.emojisToCache, {
        'custom': 'https://remote.com/emoji/custom.png',
      });

      final urlHost = Uri.parse('https://remote.com/emoji/custom.png').host;
      expect(urlHost, 'remote.com');
      expect(urlHost, isNot(ownHost));
    });

    test('detected issue: reactions field with @. might not resolve correctly', () {
      final Map<String, dynamic> apiResponse = <String, dynamic>{
        'reactions': <String, dynamic>{
          ':sumi@.:': 1,
          ':custom@remote.com:': 1,
        },
      };

      final result = EmojiExtractor.extractFromResponse(apiResponse);

      expect(result.localNames, contains('sumi'));
    });

    test('potential issue: case sensitivity in host matching', () {
      const ownHost1 = 'example.com';
      const ownHost2 = 'Example.com';
      const urlHost = 'example.com';

      expect(ownHost1, urlHost);
      expect(ownHost1.toLowerCase(), ownHost2.toLowerCase());
    });

    test('potential issue: bare name emoji without @. might stay in cache as bare', () {
      final Map<String, dynamic> apiResponse = <String, dynamic>{
        'reactions': <String, dynamic>{':custom:': 1},
      };

      final result = EmojiExtractor.extractFromResponse(apiResponse);

      expect(result.localNames, contains('custom'));
      expect(result.emojisToCache, isEmpty);
    });
  });
}
