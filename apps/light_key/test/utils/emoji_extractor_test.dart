import 'package:flutter_test/flutter_test.dart';
import 'package:light_key/utils/emoji_extractor.dart';

void main() {
  group('EmojiExtractor.extractFromResponse', () {
    test('emojis 配列形式から絵文字を抽出', () {
      final response = {
        'emojis': [
          {'name': 'sumi', 'url': 'https://example.com/emoji.png'},
          {'name': 'custom', 'url': 'https://example.com/custom.png'},
        ],
      };

      final result = EmojiExtractor.extractFromResponse(response);

      expect(result.emojisToCache, {
        'sumi': 'https://example.com/emoji.png',
        'custom': 'https://example.com/custom.png',
      });
    });

    test('emojis Map形式から絵文字を抽出', () {
      final response = {
        'emojis': {
          'sumi': 'https://example.com/emoji.png',
          'custom': 'https://example.com/custom.png',
        },
      };

      final result = EmojiExtractor.extractFromResponse(response);

      expect(result.emojisToCache, {
        'sumi': 'https://example.com/emoji.png',
        'custom': 'https://example.com/custom.png',
      });
    });

    test('reactionEmojis から絵文字を抽出', () {
      final response = {
        'reactionEmojis': {
          'custom@example.com': 'https://example.com/custom.png',
          'sumi@other.com': 'https://other.com/sumi.png',
        },
      };

      final result = EmojiExtractor.extractFromResponse(response);

      expect(result.emojisToCache, {
        'custom@example.com': 'https://example.com/custom.png',
        'sumi@other.com': 'https://other.com/sumi.png',
      });
    });

    test('reactions キーから絵文字を抽出', () {
      final response = {
        'reactions': {
          ':custom:.': 1,
          ':sumi@example.com:': 2,
          '👍': 1,
        },
      };

      final result = EmojiExtractor.extractFromResponse(response);

      expect(result.localNames, contains('custom'));
      expect(result.emojisToCache, isEmpty);
    });

    test('ネストされたリアクションから絵文字を抽出', () {
      final response = {
        'notes': [
          {
            'reactions': {
              ':custom:.': 1,
            },
          },
          {
            'note': {
              'reactions': {
                ':another:.': 2,
              },
            },
          },
        ],
      };

      final result = EmojiExtractor.extractFromResponse(response);

      expect(result.localNames, containsAll(['custom', 'another']));
    });

    test('複合形式から正しく抽出', () {
      final response = {
        'emojis': [
          {'name': 'sumi', 'url': 'https://example.com/sumi.png'},
        ],
        'reactionEmojis': {
          'custom@other.com': 'https://other.com/custom.png',
        },
        'reactions': {
          ':local:.': 1,
          ':remote@example.com:': 1,
        },
      };

      final result = EmojiExtractor.extractFromResponse(response);

      expect(result.emojisToCache, {
        'sumi': 'https://example.com/sumi.png',
        'custom@other.com': 'https://other.com/custom.png',
      });
      expect(result.localNames, contains('local'));
    });

    test('空のレスポンスは isEmpty を返す', () {
      final response = {};
      final result = EmojiExtractor.extractFromResponse(response);
      expect(result.isEmpty, isTrue);
    });

    test('null/empty URL は無視される', () {
      final response = {
        'emojis': [
          {'name': 'valid', 'url': 'https://example.com/valid.png'},
          {'name': 'empty', 'url': ''},
          {'name': 'null', 'url': null},
        ],
      };

      final result = EmojiExtractor.extractFromResponse(response);

      expect(result.emojisToCache, {
        'valid': 'https://example.com/valid.png',
      });
    });
  });
}
