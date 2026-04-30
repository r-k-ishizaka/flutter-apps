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
  static const int _imageFetchConcurrency = 12;

  static const double _fetchListWeight = 0.1;
  static const double _fetchImageWeight = 0.8;
  static const double _saveWeight = 0.05;
  static const double _loadCacheWeight = 0.05;

  /// API から絵文字を取得して DB に保存し、キャッシュを更新する。
  /// 失敗した場合でも既存キャッシュは維持される（非致命エラーとして呼び出し元で扱う）。
  Future<void> syncEmojis(
    AuthSession session, {
    void Function(double progress, String message)? onProgress,
  }) async {
    developer.log(
      'Emoji sync started for ${session.baseUrl}',
      name: 'EmojiRepository',
    );

    try {
      onProgress?.call(0, '絵文字一覧を取得中...');
      final dtos = await dataSource.fetchEmojis(baseUrl: session.baseUrl);
      onProgress?.call(_fetchListWeight, '絵文字一覧を取得しました。');
      developer.log(
        'Fetched ${dtos.length} emojis from API',
        name: 'EmojiRepository',
      );

      if (dtos.isEmpty) {
        developer.log(
          'Skipping replaceAllEmojis because API returned empty list',
          name: 'EmojiRepository',
        );
        await loadToCache();
        onProgress?.call(1, '同期完了');
        return;
      }

      final existingRows = await database.getAllEmojis();
      final existingByName = {for (final row in existingRows) row.name: row};

      var completed = 0;
      final total = dtos.length;
      onProgress?.call(_fetchListWeight, '絵文字画像を取得中... 0/$total');

      final companions =
          await _mapWithConcurrency<EmojiDto, EmojiTableCompanion>(
            dtos,
            concurrency: _imageFetchConcurrency,
            task: (dto) {
              final existing = existingByName[dto.name];
              final reusableBytes =
                  existing != null &&
                      existing.url == dto.url &&
                      existing.imageBytes != null &&
                      existing.imageBytes!.isNotEmpty
                  ? existing.imageBytes
                  : null;
              return _toCompanion(dto, imageBytes: reusableBytes);
            },
            onItemCompleted: () {
              completed++;
              if (completed == total || completed % 20 == 0) {
                final ratio = completed / total;
                final progress = _fetchListWeight + (ratio * _fetchImageWeight);
                onProgress?.call(progress, '絵文字画像を取得中... $completed/$total');
              }
            },
          );

      onProgress?.call(_fetchListWeight + _fetchImageWeight, '絵文字データを保存中...');
      await database.replaceAllEmojis(companions);
      onProgress?.call(
        _fetchListWeight + _fetchImageWeight + _saveWeight,
        'キャッシュを更新中...',
      );
      developer.log(
        'Saved ${companions.length} emojis to Drift DB',
        name: 'EmojiRepository',
      );

      await loadToCache();
      onProgress?.call(
        _fetchListWeight + _fetchImageWeight + _saveWeight + _loadCacheWeight,
        '同期完了',
      );
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

    final map = {
      for (final r in rows)
        r.name: EmojiCacheEntry(url: r.url, imageBytes: r.imageBytes),
    };
    cache.populate(map);

    developer.log(
      'EmojiCache populated with ${cache.length} entries',
      name: 'EmojiRepository',
    );
  }

  Future<EmojiTableCompanion> _toCompanion(
    EmojiDto dto, {
    Uint8List? imageBytes,
  }) async {
    if (imageBytes == null || imageBytes.isEmpty) {
      try {
        final bytes = await dataSource.fetchEmojiImageBytes(imageUrl: dto.url);
        if (bytes.isNotEmpty) {
          imageBytes = Uint8List.fromList(bytes);
        }
      } catch (e, st) {
        developer.log(
          'Failed to fetch emoji image bytes: ${dto.name} -> ${dto.url}',
          name: 'EmojiRepository',
          error: e,
          stackTrace: st,
        );
      }
    }

    return EmojiTableCompanion(
      name: Value(dto.name),
      url: Value(dto.url),
      category: Value(dto.category),
      aliases: Value(jsonEncode(dto.aliases)),
      imageBytes: Value(imageBytes),
    );
  }

  Future<List<R>> _mapWithConcurrency<T, R>(
    List<T> items, {
    required int concurrency,
    required Future<R> Function(T item) task,
    void Function()? onItemCompleted,
  }) async {
    if (items.isEmpty) return <R>[];

    final results = List<R?>.filled(items.length, null, growable: false);
    var index = 0;

    Future<void> worker() async {
      while (true) {
        final current = index;
        if (current >= items.length) return;
        index++;
        results[current] = await task(items[current]);
        onItemCompleted?.call();
      }
    }

    final workerCount = concurrency.clamp(1, items.length);
    await Future.wait(List.generate(workerCount, (_) => worker()));
    return results.cast<R>();
  }
}
