import 'dart:typed_data';

/// 絵文字のキャッシュエントリ。
class EmojiCacheEntry {
  const EmojiCacheEntry({required this.url, this.imageBytes});

  final String url;
  final Uint8List? imageBytes;
}

/// 絵文字名 → 画像情報（URL/バイナリ）のインメモリキャッシュ。
///
/// 起動時の同期処理完了後に [populate] で一括ロードし、
/// [EmojiText] ウィジェットが同期的に参照する。
class EmojiCache {
  final Map<String, EmojiCacheEntry> _cache = {};

  /// キャッシュを絵文字リストで初期化（既存エントリは上書き）。
  void populate(Map<String, EmojiCacheEntry> entries) {
    _cache
      ..clear()
      ..addAll(entries);
  }

  /// 絵文字名から画像 URL を返す。未登録なら null。
  String? getUrl(String name) => _cache[name]?.url;

  /// 絵文字名から画像バイナリを返す。未登録または未取得なら null。
  Uint8List? getImageBytes(String name) => _cache[name]?.imageBytes;

  /// キャッシュが空かどうか。
  bool get isEmpty => _cache.isEmpty;

  /// キャッシュに登録されている絵文字数。
  int get length => _cache.length;

  /// 登録済みの絵文字マップを読み取り専用で返す。
  Map<String, EmojiCacheEntry> get entries => Map.unmodifiable(_cache);
}
