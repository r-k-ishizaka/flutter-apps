/// 絵文字データソースの抽象インターフェース。
abstract interface class EmojiDataSource {
  /// サーバーから絵文字の一覧を取得する。
  /// [baseUrl] は接続先 Misskey サーバーの URL。
  Future<List<EmojiDto>> fetchEmojis({required String baseUrl});
}

/// API から受け取る絵文字の DTO。
class EmojiDto {
  const EmojiDto({
    required this.name,
    required this.url,
    this.category,
    this.aliases = const [],
  });

  final String name;
  final String url;
  final String? category;
  final List<String> aliases;
}
