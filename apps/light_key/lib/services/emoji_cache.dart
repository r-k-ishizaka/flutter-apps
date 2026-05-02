/// 絵文字のキャッシュエントリ。
class EmojiCacheEntry {
  const EmojiCacheEntry({required this.url, this.width, this.height});

  final String url;

  /// 画像の元サイズ（px）。未取得の場合は null。
  final int? width;
  final int? height;

  /// アスペクト比（width / height）。不明な場合は 1.0 を返す。
  double get aspectRatio =>
      (width != null && height != null && height! > 0)
          ? width! / height!
          : 1.0;
}

/// 絵文字名 → 画像URLのインメモリキャッシュ。
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

  /// 差分エントリを追加・更新する。
  void upsertAll(Map<String, EmojiCacheEntry> entries) {
    _cache.addAll(entries);
  }

  /// 絵文字名から画像 URL を返す。未登録なら null。
  String? getUrl(String name) => _cache[name]?.url;

  /// 絵文字名からエントリを返す。未登録なら null。
  EmojiCacheEntry? getEntry(String name) => _cache[name];

  /// キャッシュが空かどうか。
  bool get isEmpty => _cache.isEmpty;

  /// キャッシュに登録されている絵文字数。
  int get length => _cache.length;

  /// 登録済みの絵文字マップを読み取り専用で返す。
  Map<String, EmojiCacheEntry> get entries => Map.unmodifiable(_cache);
}
