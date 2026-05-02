/// [EmojiExtractor.extractFromResponse] の結果。
class EmojiExtractionResult {
  const EmojiExtractionResult({
    required this.emojisToCache,
    required this.localNames,
  });

  /// キャッシュ対象の絵文字。`名前` または `名前@host` → URL のマップ。
  final Map<String, String> emojisToCache;

  /// `@.`（自鯖）記法の絵文字の名前一覧。
  /// URL は [EmojiCache] から解決する必要がある。
  final Set<String> localNames;

  bool get isEmpty => emojisToCache.isEmpty && localNames.isEmpty;
}

/// Misskey API のレスポンスから絵文字参照を抽出するユーティリティ。
///
/// JSON レスポンスを再帰的に走査して、リアクションやカスタム絵文字の参照を抽出する。
/// 以下のケースに対応：
/// 1. emojis - 配列（`[{name, url, ...}]`）または オブジェクト（`{name: url}`）形式
/// 2. reactionEmojis - オブジェクト形式（`{name@host: url}`）
/// 3. reactions キーから抽出（`:emoji_name@.:` → localNames、`:emoji_name@host:` → emojisToCache の URL 解決待ち）
abstract final class EmojiExtractor {
  static final _emojiPattern = RegExp(
    r':([a-zA-Z0-9_]+)(?:@([a-zA-Z0-9._-]+))?:',
  );
  static const String _emojiKey = 'emojis';
  static const String _reactionEmojisKey = 'reactionEmojis';
  static const String _reactionsKey = 'reactions';

  /// JSON レスポンスから絵文字参照を抽出する。
  ///
  /// [data] は API レスポンス（Map または List）。
  ///
  /// 対応するフォーマット：
  /// - `emojis: [{name, url, ...}]` - 配列形式
  /// - `emojis: {name: url}` - Map 形式
  /// - `emojis: {name@host: url}` - Map 形式（リモート絵文字）
  /// - `reactionEmojis: {name@host: url}` - Map 形式
  /// - `reactions: {':emoji_name@.:': count}` → [EmojiExtractionResult.localNames] に追加
  static EmojiExtractionResult extractFromResponse(dynamic data) {
    final emojisToCache = <String, String>{};
    final localNames = <String>{};
    _collectEmojis(data, emojisToCache, localNames);
    return EmojiExtractionResult(
      emojisToCache: emojisToCache,
      localNames: localNames,
    );
  }

  static void _collectEmojis(
    dynamic data,
    Map<String, String> withUrls,
    Set<String> localNames,
  ) {
    if (data is Map<String, dynamic>) {
      // Case 1: emojis フィールド（配列または Map 形式）から直接取得
      if (data.containsKey(_emojiKey)) {
        final emojis = data[_emojiKey];
        if (emojis is List) {
          for (final e in emojis.whereType<Map<String, dynamic>>()) {
            _addEmoji(e, withUrls);
          }
        } else if (emojis is Map<String, dynamic>) {
          // user オブジェクトに host フィールドがある場合は他鯖ユーザーの絵文字
          // → `name@host` 形式でキャッシュし、自鯖絵文字との衝突を防ぐ
          final userHost = data['host'] as String?;
          for (final entry in emojis.entries) {
            final name = entry.key;
            final url = entry.value;
            if (name.isNotEmpty && url is String && url.isNotEmpty) {
              final key = (userHost != null && userHost.isNotEmpty)
                  ? '$name@$userHost'
                  : name;
              withUrls[key] = url;
            }
          }
        }
      }

      // Case 2: reactionEmojis フィールド（Map 形式）から直接取得
      if (data.containsKey(_reactionEmojisKey)) {
        final reactionEmojis = data[_reactionEmojisKey];
        if (reactionEmojis is Map<String, dynamic>) {
          for (final entry in reactionEmojis.entries) {
            final name = entry.key;
            final url = entry.value;

            // reactionEmojis の値は { url: '...', ... } オブジェクトの可能性がある
            if (url is String && url.isNotEmpty) {
              withUrls[name] = url;
            } else if (url is Map<String, dynamic> && url.containsKey('url')) {
              final urlString = url['url'];
              if (urlString is String && urlString.isNotEmpty) {
                withUrls[name] = urlString;
              }
            }
          }
        }
      }

      // Case 3: reactions キー（リアクション）から抽出
      if (data.containsKey(_reactionsKey)) {
        final reactions = data[_reactionsKey];
        if (reactions is Map<String, dynamic>) {
          for (final key in reactions.keys) {
            _extractEmojiFromReactionKey(key, withUrls, localNames);
          }
        }
      }

      // Case 4: その他のすべてのフィールドを再帰的に探索
      for (final value in data.values) {
        _collectEmojis(value, withUrls, localNames);
      }
    } else if (data is List) {
      for (final item in data) {
        _collectEmojis(item, withUrls, localNames);
      }
    }
  }

  /// 絵文字オブジェクト（`{name, url, width, height, ...}` 形式）から情報を抽出。
  static void _addEmoji(
    Map<String, dynamic> emojiObject,
    Map<String, String> withUrls,
  ) {
    final name = emojiObject['name'] as String?;
    final url = emojiObject['url'] as String?;

    if (name != null && name.isNotEmpty && url != null && url.isNotEmpty) {
      withUrls[name] = url;
    }
  }

   /// リアクションキーから絵文字参照を抽出。
   ///
   /// - `@.` または host なし → [localNames] に追加（URL は EmojiCache から解決）
   ///   ただし、既に [withUrls] に URL がある場合は追加しない
   /// - `@host` → [emojisToCache] から URL が別途取得される（reactionEmojis 経由）
   /// - Unicode 絵文字 → スキップ
   static void _extractEmojiFromReactionKey(
     String key,
     Map<String, String> withUrls,
     Set<String> localNames,
   ) {
     final match = _emojiPattern.firstMatch(key);
     if (match == null) return;

     final name = match.group(1)!;
     final host = match.group(2);

     if (host == null || host == '.') {
       // 自鯖絵文字：URL は EmojiCache から解決する
       // ただし、既に reactionEmojis で URL が見つかっている場合は追加しない
       if (!withUrls.containsKey(name)) {
         localNames.add(name);
       }
     } else if (_isValidHost(host)) {
       // 他鯖絵文字：URL は reactionEmojis フィールドに含まれているはず
     }
   }

  /// ホスト名が有効かチェック（基本的な検証）。
  static bool _isValidHost(String host) {
    return RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(host);
  }
}
