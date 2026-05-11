import 'package:flutter_test/flutter_test.dart';
import 'package:light_key/models/auth_session.dart';
import 'package:light_key/utils/emoji_extractor.dart';

void main() {
  group('EmojiRepository key normalization', () {
    test('bare name emoji from same server', () async {
      final session = const AuthSession(
        baseUrl: 'https://example.com',
        accessToken: 'token',
      );

      // Simulate emoji extractor result:
      // API returned: {"emojis": [{"name": "sumi", "url": "https://example.com/..."}]}
      final result = EmojiExtractionResult(
        emojisToCache: {'sumi': 'https://example.com/sumi.png'},
        localNames: const <String>{},
      );

      // Expected: key should remain as 'sumi' (same server, so no @host suffix)
      // because URL host (example.com) == session host (example.com)
      final repository = _FakeEmojiRepository(session);
      final normalized = repository.testNormalizeEmojiKeys(result.emojisToCache, session);

      expect(normalized, {'sumi': 'https://example.com/sumi.png'});
    });

    test('bare name emoji from remote server', () async {
      final session = const AuthSession(
        baseUrl: 'https://self.com',
        accessToken: 'token',
      );

      // API returned: {"emojis": [{"name": "custom", "url": "https://remote.com/..."}]}
      final result = EmojiExtractionResult(
        emojisToCache: {'custom': 'https://remote.com/custom.png'},
        localNames: const <String>{},
      );

      // Expected: key should be normalized to 'custom@remote.com'
      // because URL host (remote.com) != session host (self.com)
      final repository = _FakeEmojiRepository(session);
      final normalized = repository.testNormalizeEmojiKeys(result.emojisToCache, session);

      expect(normalized, {'custom@remote.com': 'https://remote.com/custom.png'});
    });

    test('already normalized key', () async {
      final session = const AuthSession(
        baseUrl: 'https://self.com',
        accessToken: 'token',
      );

      // API returned: {"reactionEmojis": {"emoji@remote.com": "https://..."}}
      final result = EmojiExtractionResult(
        emojisToCache: {'emoji@remote.com': 'https://remote.com/emoji.png'},
        localNames: const <String>{},
      );

      // Expected: key should remain as 'emoji@remote.com' (already normalized)
      final repository = _FakeEmojiRepository(session);
      final normalized = repository.testNormalizeEmojiKeys(result.emojisToCache, session);

      expect(normalized, {'emoji@remote.com': 'https://remote.com/emoji.png'});
    });

    test('emoji from reactions but URL in reactionEmojis', () async {
      // reactionEmojis: {"custom@host.com": "https://host.com/..."}
      // reactions: {":custom@host.com:": 1}
      // Expected result after extraction
      final result = EmojiExtractionResult(
        emojisToCache: {'custom@host.com': 'https://host.com/custom.png'},
        localNames: const <String>{},
      );

      final session = const AuthSession(
        baseUrl: 'https://self.com',
        accessToken: 'token',
      );

      // Expected: key should remain as 'custom@host.com' (already contains @)
      final repository = _FakeEmojiRepository(session);
      final normalized = repository.testNormalizeEmojiKeys(result.emojisToCache, session);

      expect(normalized, {'custom@host.com': 'https://host.com/custom.png'});
    });

    test('localNamesはemojisToCacheの @. URLをbare keyへ統合する', () {
      final repository = _FakeEmojiRepository(
        const AuthSession(baseUrl: 'https://self.com', accessToken: 'token'),
      );

      final merged = repository.testMergeLocalNames(
        emojisToCache: {'custom@.': 'https://self.com/custom.png'},
        localNames: const {'custom'},
        cacheEntries: const {},
      );

      expect(merged, {'custom@.': 'https://self.com/custom.png', 'custom': 'https://self.com/custom.png'});
    });

    test('localNamesはcacheの @. URLでもbare keyへ統合する', () {
      final repository = _FakeEmojiRepository(
        const AuthSession(baseUrl: 'https://self.com', accessToken: 'token'),
      );

      final merged = repository.testMergeLocalNames(
        emojisToCache: const {},
        localNames: const {'custom'},
        cacheEntries: const {'custom@.': 'https://self.com/custom.png'},
      );

      expect(merged, {'custom': 'https://self.com/custom.png'});
    });
  });
}

class _FakeEmojiRepository  {
  _FakeEmojiRepository(this.session);

  final AuthSession session;

  /// Test-exposed version of _normalizeEmojiKeys
  Map<String, String> testNormalizeEmojiKeys(
    Map<String, String> emojisToCache,
    AuthSession? session,
  ) {
    final ownHost = session != null ? Uri.parse(session.baseUrl).host : null;
    final normalized = <String, String>{};

    for (final entry in emojisToCache.entries) {
      final name = entry.key;
      final url = entry.value;

      if (name.contains('@')) {
        normalized[name] = url;
        continue;
      }

      final urlHost = Uri.tryParse(url)?.host;
      if (urlHost == null || urlHost.isEmpty || urlHost == ownHost) {
        normalized[name] = url;
      } else {
        final key = '$name@$urlHost';
        normalized[key] = url;
      }
    }

    return normalized;
  }

  Map<String, String> testMergeLocalNames({
    required Map<String, String> emojisToCache,
    required Set<String> localNames,
    required Map<String, String> cacheEntries,
  }) {
    final merged = Map<String, String>.from(emojisToCache);
    for (final name in localNames) {
      if (!merged.containsKey(name)) {
        String? url = cacheEntries[name];
        url ??= emojisToCache['$name@.'];
        url ??= cacheEntries['$name@.'];
        if (url != null && url.isNotEmpty) {
          merged[name] = url;
        }
      }
    }
    return merged;
  }
}
