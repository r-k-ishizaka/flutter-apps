import 'dart:developer' as developer;

import '../utils/misskey_http_client.dart';
import 'emoji_data_source.dart';

/// Misskey の `/api/emojis` エンドポイントから絵文字を取得する実装。
class MisskeyEmojiDataSource implements EmojiDataSource {
  const MisskeyEmojiDataSource({required this.client});

  final MisskeyHttpClient client;

  @override
  Future<List<EmojiDto>> fetchEmojis({required String baseUrl}) async {
    developer.log('Fetching emojis from $baseUrl/api/emojis', name: 'EmojiDataSource');

    try {
      final json = await client.getJson(
        baseUrl: baseUrl,
        path: '/api/emojis',
      );

      developer.log(
        'Response keys: ${json.keys.toList()}',
        name: 'EmojiDataSource',
      );

      final rawList = json['emojis'];
      if (rawList is! List<dynamic>) {
        developer.log(
          'emojis is not a list, got: ${rawList.runtimeType}',
          name: 'EmojiDataSource',
        );
        return const [];
      }

      developer.log(
        'Raw emoji list length: ${rawList.length}',
        name: 'EmojiDataSource',
      );

      final result = rawList
          .whereType<Map>()
          .map((e) {
            final aliases = (e['aliases'] as List?)
                    ?.whereType<String>()
                    .where((a) => a.isNotEmpty)
                    .toList() ??
                const [];
            return EmojiDto(
              name: e['name'] as String? ?? '',
              url: e['url'] as String? ?? '',
              category: e['category'] as String?,
              aliases: aliases,
            );
          })
          .where((e) => e.name.isNotEmpty && e.url.isNotEmpty)
          .toList(growable: false);

      developer.log(
        'Parsed ${result.length} valid emojis (with name and url)',
        name: 'EmojiDataSource',
      );
      if (result.isNotEmpty) {
        developer.log(
          'Sample: ${result.first.name} -> ${result.first.url}',
          name: 'EmojiDataSource',
        );
      }

      return result;
    } catch (e, st) {
      developer.log(
        'Failed to fetch emojis: $e',
        name: 'EmojiDataSource',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<List<int>> fetchEmojiImageBytes({required String imageUrl}) {
    return client.getBytes(url: imageUrl);
  }
}
