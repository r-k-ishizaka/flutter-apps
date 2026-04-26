/// 絵文字名 → 画像 URL のインメモリキャッシュ。
///
/// 起動時の同期処理完了後に [populate] で一括ロードし、
/// [EmojiText] ウィジェットが同期的に参照する。
class EmojiCache {
  final Map<String, String> _cache = {};

  /// キャッシュを絵文字リストで初期化（既存エントリは上書き）。
  void populate(Map<String, String> nameToUrl) {
    _cache
      ..clear()
      ..addAll(nameToUrl);
  }

  /// 絵文字名から画像 URL を返す。未登録なら null。
  String? getUrl(String name) => _cache[name];

  /// キャッシュが空かどうか。
  bool get isEmpty => _cache.isEmpty;

  /// キャッシュに登録されている絵文字数。
  int get length => _cache.length;
}
