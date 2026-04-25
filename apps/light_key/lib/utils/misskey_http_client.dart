import 'package:dio/dio.dart';

class MisskeyHttpClient {
  MisskeyHttpClient([Dio? dio])
    : _dio = dio ??
          Dio(
            BaseOptions(
              headers: const {'Content-Type': 'application/json'},
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 15),
              responseType: ResponseType.json,
              validateStatus: (_) => true,
            ),
          );

  final Dio _dio;

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
}
