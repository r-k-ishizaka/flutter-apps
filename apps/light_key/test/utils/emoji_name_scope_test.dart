import 'package:flutter_test/flutter_test.dart';
import 'package:light_key/utils/emoji_name_scope.dart';

void main() {
  group('isEmojiAvailableForHost', () {
    test('bare name is always allowed', () {
      expect(isEmojiAvailableForHost('smile', sessionHost: 'example.com'), isTrue);
      expect(isEmojiAvailableForHost('smile'), isTrue);
    });

    test('@. format is treated as own-server emoji', () {
      expect(isEmojiAvailableForHost('smile@.', sessionHost: 'example.com'), isTrue);
    });

    test('emoji with own host suffix is allowed', () {
      expect(
        isEmojiAvailableForHost('smile@example.com', sessionHost: 'example.com'),
        isTrue,
      );
      expect(
        isEmojiAvailableForHost('smile@EXAMPLE.COM', sessionHost: 'example.com'),
        isTrue,
      );
    });

    test('emoji with other host suffix is rejected', () {
      expect(
        isEmojiAvailableForHost('smile@remote.example', sessionHost: 'example.com'),
        isFalse,
      );
    });

    test('host suffix is rejected when session host is unknown', () {
      expect(isEmojiAvailableForHost('smile@example.com'), isFalse);
      expect(isEmojiAvailableForHost('smile@example.com', sessionHost: ''), isFalse);
    });

    test('invalid name@ format is rejected', () {
      expect(isEmojiAvailableForHost('smile@', sessionHost: 'example.com'), isFalse);
    });
  });
}
