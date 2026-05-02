/// 絵文字データソースの抽象インターフェース。
abstract interface class EmojiDataSource {
  /// サーバーから絵文字の一覧を取得する。
  /// [baseUrl] は接続先 Misskey サーバーの URL。
  Future<List<EmojiDto>> fetchEmojis({required String baseUrl});

  /// 絵文字画像の縦横サイズを取得する。
  ///
  /// 画像ヘッダのみを取得して解析するため、フルダウンロード不要。
  /// 取得失敗・不明フォーマット時は null を返す。
  Future<({int width, int height})?> fetchEmojiImageSize({
    required String imageUrl,
  });
}

/// API から受け取る絵文字の DTO。
class EmojiDto {
  const EmojiDto({
    required this.name,
    required this.url,
    this.category,
    this.aliases = const [],
    this.width,
    this.height,
  });

  final String name;
  final String url;
  final String? category;
  final List<String> aliases;

  /// 画像の元サイズ（px）。未取得の場合は null。
  final int? width;
  final int? height;
}
