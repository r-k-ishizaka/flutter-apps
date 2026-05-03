import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:light_key/utils/misskey_http_client.dart';

void main() {
  group('MisskeyHttpClient hints', () {
    Future<MisskeyHttpClient> buildClientWithExtra(
      Object responseData,
      Map<String, dynamic> extra,
    ) async {
      final dio = Dio(
        BaseOptions(
          headers: const {'Content-Type': 'application/json'},
          validateStatus: (_) => true,
        ),
      );

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: responseData,
                extra: extra,
              ),
            );
          },
        ),
      );

      return MisskeyHttpClient(dio);
    }

    test('postJsonWithCacheHints: emojisToCache が正しく読み込まれる', () async {
      final client = await buildClientWithExtra(
        <String, dynamic>{'ok': true},
        <String, dynamic>{
          'emojisToCache': <Map<String, String>>[
            <String, String>{
              'name': 'sumi',
              'url': 'https://example.com/sumi.png',
            },
            <String, String>{
              'name': 'custom@host.com',
              'url': 'https://host.com/custom.png',
            },
          ],
        },
      );

      final response = await client.postJsonWithCacheHints(
        baseUrl: 'https://example.com',
        path: '/api/test',
        body: const <String, dynamic>{'x': 1},
      );

      expect(response.emojisToCache.length, 2);
      expect(response.emojisToCache[0].name, 'sumi');
      expect(response.emojisToCache[0].url, 'https://example.com/sumi.png');
      expect(response.emojisToCache[1].name, 'custom@host.com');
      expect(response.emojisToCache[1].url, 'https://host.com/custom.png');
    });

    test('postJsonWithCacheHints: emojisToCache が List でない場合は空を返す', () async {
      final client = await buildClientWithExtra(
        <String, dynamic>{'ok': true},
        <String, dynamic>{'emojisToCache': 'not a list'},
      );

      final response = await client.postJsonWithCacheHints(
        baseUrl: 'https://example.com',
        path: '/api/test',
        body: const <String, dynamic>{'x': 1},
      );

      expect(response.emojisToCache, isEmpty);
    });

    test('postJsonWithCacheHints: emojisToCache が無い場合は空を返す', () async {
      final client = await buildClientWithExtra(
        <String, dynamic>{'ok': true},
        <String, dynamic>{'someOtherKey': 'value'},
      );

      final response = await client.postJsonWithCacheHints(
        baseUrl: 'https://example.com',
        path: '/api/test',
        body: const <String, dynamic>{'x': 1},
      );

      expect(response.emojisToCache, isEmpty);
    });

    test('postJsonWithCacheHints: 無効エントリはフィルタされる', () async {
      final client = await buildClientWithExtra(
        <String, dynamic>{'ok': true},
        <String, dynamic>{
          'emojisToCache': <Map<String, dynamic>>[
            <String, dynamic>{
              'name': 'valid',
              'url': 'https://example.com/valid.png',
            },
            <String, dynamic>{
              'name': '',
              'url': 'https://example.com/empty-name.png',
            },
            <String, dynamic>{'name': 'no-url', 'url': ''},
            <String, dynamic>{'name': 'missing-url'},
            <String, dynamic>{'url': 'https://example.com/missing-name.png'},
          ],
        },
      );

      final response = await client.postJsonWithCacheHints(
        baseUrl: 'https://example.com',
        path: '/api/test',
        body: const <String, dynamic>{'x': 1},
      );

      expect(response.emojisToCache.length, 1);
      expect(response.emojisToCache[0].name, 'valid');
      expect(response.emojisToCache[0].url, 'https://example.com/valid.png');
    });
  });
}
