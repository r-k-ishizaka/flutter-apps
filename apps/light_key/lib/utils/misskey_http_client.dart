import 'package:dio/dio.dart';

import '../models/response_with_cache_hints.dart';
import 'emoji_caching_interceptor.dart';

class MisskeyHttpClient {
  MisskeyHttpClient([Dio? dio])
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              headers: const {'Content-Type': 'application/json'},
              connectTimeout: const Duration(seconds: 10),
              // 大型レスポンス（絵文字一覧など）の受信に対応
              receiveTimeout: const Duration(seconds: 60),
              sendTimeout: const Duration(seconds: 15),
              responseType: ResponseType.json,
              validateStatus: (_) => true,
            ),
          ) {
    // 絵文字をレスポンスから自動抽出してキャッシュ
    _dio.interceptors.add(EmojiCachingInterceptor());
  }

  final Dio _dio;

  /// GET リクエストを送り、レスポンスを Map で返す。
  Future<Map<String, dynamic>> getJson({
    required String baseUrl,
    required String path,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        _normalizeBaseUrl(baseUrl) + path,
        queryParameters: queryParameters,
      );
      final statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300) {
        throw Exception('Misskey API error: $statusCode ${response.data}');
      }
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      throw Exception('Unexpected response format');
    } on DioException catch (error) {
      throw Exception(
        'Misskey API request failed: ${error.message ?? error.toString()}',
      );
    }
  }

  Future<Map<String, dynamic>> postJson({
    required String baseUrl,
    required String path,
    required Map<String, dynamic> body,
  }) async {
    final response = await _post(baseUrl: baseUrl, path: path, body: body);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw Exception('Unexpected response format');
  }

  Future<ResponseWithCacheHints<Map<String, dynamic>>> postJsonWithCacheHints({
    required String baseUrl,
    required String path,
    required Map<String, dynamic> body,
  }) async {
    final response = await _post(baseUrl: baseUrl, path: path, body: body);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return ResponseWithCacheHints(
        data: data,
        emojisToCache: _readEmojiHintsFromExtra(response.extra),
      );
    }
    if (data is Map) {
      return ResponseWithCacheHints(
        data: Map<String, dynamic>.from(data),
        emojisToCache: _readEmojiHintsFromExtra(response.extra),
      );
    }
    throw Exception('Unexpected response format');
  }

  /// POST リクエストを送り、レスポンスボディを無視する（204 No Content など）。
  Future<void> postVoid({
    required String baseUrl,
    required String path,
    required Map<String, dynamic> body,
  }) async {
    await _post(baseUrl: baseUrl, path: path, body: body);
  }

  Future<List<Map<String, dynamic>>> postJsonList({
    required String baseUrl,
    required String path,
    required Map<String, dynamic> body,
  }) async {
    final response = await _post(baseUrl: baseUrl, path: path, body: body);
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(growable: false);
    }
    throw Exception('Unexpected response format');
  }

  Future<ResponseWithCacheHints<List<Map<String, dynamic>>>>
  postJsonListWithCacheHints({
    required String baseUrl,
    required String path,
    required Map<String, dynamic> body,
  }) async {
    final response = await _post(baseUrl: baseUrl, path: path, body: body);
    final data = response.data;
    if (data is! List) {
      throw Exception('Unexpected response format');
    }

    final list = data
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
    return ResponseWithCacheHints(
      data: list,
      emojisToCache: _readEmojiHintsFromExtra(response.extra),
    );
  }

  Future<Response<dynamic>> _post({
    required String baseUrl,
    required String path,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        _normalizeBaseUrl(baseUrl) + path,
        data: body,
      );
      final statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300) {
        throw Exception('Misskey API error: $statusCode ${response.data}');
      }
      return response;
    } on DioException catch (error) {
      throw Exception(
        'Misskey API request failed: ${error.message ?? error.toString()}',
      );
    }
  }

  String _normalizeBaseUrl(String baseUrl) {
    final trimmed = baseUrl.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  List<EmojiToCache> _readEmojiHintsFromExtra(Map<String, dynamic> extra) {
    final raw = extra[EmojiCachingInterceptor.extraKeyEmojisToCache];
    if (raw is! List) {
      return const <EmojiToCache>[];
    }
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .map((e) => EmojiToCache(
              name: e['name'] as String? ?? '',
              url: e['url'] as String? ?? '',
            ))
        .where((e) => e.name.isNotEmpty && e.url.isNotEmpty)
        .toList(growable: false);
  }

  /// Range リクエストで先頭 [maxBytes] バイトだけ取得する（画像サイズ判定用）。
  ///
  /// サーバーが Range 非対応の場合（200 応答）はそのままデータを返す。
  Future<List<int>> getPartialBytes({
    required String url,
    int maxBytes = 4096,
  }) async {
    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Range': 'bytes=0-${maxBytes - 1}'},
          validateStatus: (status) =>
              status != null &&
              (status == 206 || (status >= 200 && status < 300)),
        ),
      );
      return response.data ?? const <int>[];
    } on DioException catch (error) {
      throw Exception(
        'Misskey asset request failed: ${error.message ?? error.toString()}',
      );
    }
  }

  /// 任意 URL からバイト配列を取得する（絵文字画像用）。
  Future<List<int>> getBytes({required String url}) async {
    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300) {
        throw Exception('Misskey asset request failed: $statusCode');
      }
      return response.data ?? const <int>[];
    } on DioException catch (error) {
      throw Exception(
        'Misskey asset request failed: ${error.message ?? error.toString()}',
      );
    }
  }
}
