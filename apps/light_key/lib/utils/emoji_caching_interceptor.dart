import 'package:dio/dio.dart';

import 'emoji_extractor.dart';

/// Misskey API のレスポンスから絵文字参照を抽出し、レスポンスextraに付与するインターセプター。
///
/// 本クラスの責務は以下のみ：
/// - レスポンスから [EmojiExtractionResult] を生成する
/// - `response.extra['emojisToCache']` にキャッシュヒントを追加する
class EmojiCachingInterceptor extends Interceptor {
  static const String extraKeyEmojisToCache = 'emojisToCache';

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    // 正常なレスポンスのみ処理
    final statusCode = response.statusCode ?? 0;
    if (statusCode < 200 || statusCode >= 300) {
      return handler.next(response);
    }

    try {
      _attachEmojiHints(response);
    } catch (_) {
      // エラーは無視してレスポンス処理を続行（非致命エラー）
    }

    handler.next(response);
  }

  void _attachEmojiHints(Response<dynamic> response) {
    final responseData = response.data;

    final result = EmojiExtractor.extractFromResponse(responseData);

    if (result.isEmpty) {
      return;
    }

    final hints = <Map<String, String>>[
      for (final entry in result.emojisToCache.entries)
        {'name': entry.key, 'url': entry.value},
    ];
    if (hints.isEmpty) {
      return;
    }

    response.extra[extraKeyEmojisToCache] = hints;
  }
}
