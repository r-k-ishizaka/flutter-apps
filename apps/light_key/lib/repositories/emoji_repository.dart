import 'dart:convert';
import 'dart:developer' as developer;

import 'package:drift/drift.dart';

import '../datasources/emoji_data_source.dart';
import '../models/auth_session.dart';
import '../services/app_database.dart';
import '../services/emoji_cache.dart';

/// 絵文字の同期・参照を担うリポジトリ。
///
/// - [syncEmojis]: API から取得して DB に保存し、[EmojiCache] を更新する。
/// - [loadToCache]: DB から読み込んで [EmojiCache] に展開する（起動時オフライン復元用）。
class EmojiRepository {
  EmojiRepository({
    required this.dataSource,
    required this.database,
    required this.cache,
  });

  final EmojiDataSource dataSource;
  final AppDatabase database;
  final EmojiCache cache;

  /// API から絵文字を取得して DB に保存し、キャッシュを更新する。
  /// 失敗した場合でも既存キャッシュは維持される（非致命エラーとして呼び出し元で扱う）。
  Future<void> syncEmojis(AuthSession session) async {
    developer.log(
      'Emoji sync started for ${session.baseUrl}',
      name: 'EmojiRepository',
    );

    try {
      final dtos = await dataSource.fetchEmojis(baseUrl: session.baseUrl);
      developer.log(
        'Fetched ${dtos.length} emojis from API',
        name: 'EmojiRepository',
      );

      final companions = dtos
          .map(
            (e) => EmojiTableCompanion(
              name: Value(e.name),
              url: Value(e.url),
              category: Value(e.category),
              aliases: Value(jsonEncode(e.aliases)),
            ),
          )
          .toList(growable: false);

      await database.replaceAllEmojis(companions);
      developer.log(
        'Saved ${companions.length} emojis to Drift DB',
        name: 'EmojiRepository',
      );

      await loadToCache();
      developer.log(
        'Loaded ${cache.length} emojis to EmojiCache',
        name: 'EmojiRepository',
      );
    } catch (e, st) {
      developer.log(
        'Emoji sync failed: $e',
        name: 'EmojiRepository',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// DB の全絵文字を [EmojiCache] に展開する。
  /// 起動時にオフライン状態でも既存 DB からキャッシュを復元する際に使用する。
  Future<void> loadToCache() async {
    developer.log(
      'Loading emojis from Drift to cache...',
      name: 'EmojiRepository',
    );

    final rows = await database.getAllEmojis();
    developer.log(
      'Found ${rows.length} emojis in Drift DB',
      name: 'EmojiRepository',
    );

    final map = {for (final r in rows) r.name: r.url};
    cache.populate(map);

    developer.log(
      'EmojiCache populated with ${cache.length} entries',
      name: 'EmojiRepository',
    );
  }
}
