import 'dart:developer' as developer;

import 'package:dio/dio.dart';

class MisskeyHttpClient {
  MisskeyHttpClient([Dio? dio])
    : _dio = dio ??
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
    // 全リクエスト・レスポンスをログ
    _dio.interceptors.add(
      LoggingInterceptor(),
    );
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
    final response = await _post(
      baseUrl: baseUrl,
      path: path,
      body: body,
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
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
    final response = await _post(
      baseUrl: baseUrl,
      path: path,
      body: body,
    );
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(growable: false);
    }
    throw Exception('Unexpected response format');
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
      throw Exception('Misskey API request failed: ${error.message ?? error.toString()}');
    }
  }

  String _normalizeBaseUrl(String baseUrl) {
    final trimmed = baseUrl.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
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

/// Dio の全リクエスト・レスポンスをコンソールにログ出力するインターセプター。
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log(
      '→ REQUEST: ${options.method} ${options.uri}',
      name: 'Dio',
    );
    if (options.data != null) {
      developer.log(
        '  Body: ${options.data}',
        name: 'Dio',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer.log(
      '← RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
      name: 'Dio',
    );
    if (response.data != null) {
      developer.log(
        '  Data: ${response.data}',
        name: 'Dio',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '⚠ ERROR: ${err.type} ${err.requestOptions.uri}',
      name: 'Dio',
    );
    developer.log(
      '  Message: ${err.message}',
      name: 'Dio',
    );
    handler.next(err);
  }
}
