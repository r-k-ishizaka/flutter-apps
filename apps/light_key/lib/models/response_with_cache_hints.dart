/// レスポンス本体に、キャッシュ対象ヒントを付与するラッパー。
///
/// Interceptor はヒントの抽出・付与のみを担当し、
/// 実際のキャッシュ実行は repository 側で行う。
class ResponseWithCacheHints<T> {
  const ResponseWithCacheHints({
    required this.data,
    this.emojisToCache = const <EmojiToCache>[],
  });

  final T data;
  final List<EmojiToCache> emojisToCache;
}

/// 絵文字キャッシュ対象の 1 件分のヒント。
class EmojiToCache {
  const EmojiToCache({required this.name, required this.url});

  final String name;
  final String url;
}
