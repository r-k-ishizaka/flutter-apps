import 'dart:convert';
import 'dart:developer' as developer;

import 'package:drift/drift.dart';

import '../datasources/auth_data_source.dart';
import '../datasources/emoji_data_source.dart';
import '../models/auth_session.dart';
import '../models/response_with_cache_hints.dart';
import '../services/app_database.dart';
import '../services/emoji_cache.dart';
import '../utils/emoji_extractor.dart';

/// 絵文字の同期・参照を担うリポジトリ。
///
/// - [syncEmojis]: API から取得した絵文字のメタ情報（名前/URL/サイズ等）を
///   DB に保存し、[EmojiCache] を更新する（画像バイナリは保存しない）。
/// - [loadToCache]: DB から読み込んで [EmojiCache] に展開する（起動時オフライン復元用）。
/// - [cacheFromResponse]: 抽出済みレスポンス情報を元にサイズを保存する。
class EmojiRepository {
  EmojiRepository({
    required this.dataSource,
    required this.authDataSource,
    required this.database,
    required this.cache,
  });

  final EmojiDataSource dataSource;
  final AuthDataSource authDataSource;
  final AppDatabase database;
  final EmojiCache cache;

  static const int _imageSizeFetchConcurrency = 20;
  static const String _syncLogName = 'EmojiSync';

  static const double _fetchListWeight = 0.1;
  static const double _fetchSizeWeight = 0.75;
  static const double _saveWeight = 0.1;
  static const double _loadCacheWeight = 0.05;

  /// API から絵文字のメタ情報を取得して DB に保存し、キャッシュを更新する。
  /// 画像バイナリ本体は保存せず、URL/サイズ情報のみを保持する。
  /// 失敗した場合でも既存キャッシュは維持される（非致命エラーとして呼び出し元で扱う）。
  Future<void> syncEmojis(
    AuthSession session, {
    void Function(double progress, String message)? onProgress,
  }) async {
    final totalStopwatch = Stopwatch()..start();
    final listFetchStopwatch = Stopwatch();
    final sizeFetchStopwatch = Stopwatch();
    final saveStopwatch = Stopwatch();
    final cacheStopwatch = Stopwatch();
    var sizeFetchCount = 0;
    var sizeReusedCount = 0;
    var sizeFromApiCount = 0;

    try {
      onProgress?.call(0, '絵文字一覧を取得中...');
      listFetchStopwatch.start();
      final dtos = await dataSource.fetchEmojis(baseUrl: session.baseUrl);
      listFetchStopwatch.stop();
      onProgress?.call(_fetchListWeight, '絵文字一覧を取得しました。');

      if (dtos.isEmpty) {
        await loadToCache();
        onProgress?.call(1, '同期完了');
        return;
      }

      // URL が変わっていない絵文字は既存のサイズ情報を再利用する
      final existingRows = await database.getAllEmojis();
      final existingByName = {for (final row in existingRows) row.name: row};

      var completed = 0;
      final total = dtos.length;
      onProgress?.call(_fetchListWeight, '絵文字サイズを取得中... 0/$total');

      sizeFetchStopwatch.start();
      final companions =
          await _mapWithConcurrency<EmojiDto, EmojiTableCompanion>(
            dtos,
            concurrency: _imageSizeFetchConcurrency,
            task: (dto) async {
              final existing = existingByName[dto.name];
              if (existing != null &&
                  existing.url == dto.url &&
                  existing.width != null &&
                  existing.height != null) {
                // URLが同じで既にサイズが保存済みなら再取得しない
                sizeReusedCount++;
                return _toCompanion(
                  dto,
                  width: existing.width,
                  height: existing.height,
                );
              }

              if (dto.width != null && dto.height != null) {
                // API がサイズを返している場合はネットワーク再取得しない
                sizeFromApiCount++;
                return _toCompanion(dto, width: dto.width, height: dto.height);
              }

              sizeFetchCount++;
              final size = await dataSource.fetchEmojiImageSize(
                imageUrl: dto.url,
              );
              return _toCompanion(
                dto,
                width: size?.width,
                height: size?.height,
              );
            },
            onItemCompleted: () {
              completed++;
              if (completed == total || completed % 20 == 0) {
                final ratio = completed / total;
                final progress = _fetchListWeight + (ratio * _fetchSizeWeight);
                onProgress?.call(progress, '絵文字サイズを取得中... $completed/$total');
              }
            },
          );
      sizeFetchStopwatch.stop();

      onProgress?.call(_fetchListWeight + _fetchSizeWeight, '絵文字データを保存中...');
      final keepNames = companions.map((c) => c.name.value).toSet();
      saveStopwatch.start();
      await database.applyEmojiDiff(upserts: companions, keepNames: keepNames);
      saveStopwatch.stop();
      onProgress?.call(
        _fetchListWeight + _fetchSizeWeight + _saveWeight,
        'キャッシュを更新中...',
      );

      cacheStopwatch.start();
      cache.populate(_toCacheMapFromCompanions(companions));
      cacheStopwatch.stop();
      onProgress?.call(
        _fetchListWeight + _fetchSizeWeight + _saveWeight + _loadCacheWeight,
        '同期完了',
      );

      totalStopwatch.stop();
      developer.log(
        'sync complete totalMs=${totalStopwatch.elapsedMilliseconds} '
        'listMs=${listFetchStopwatch.elapsedMilliseconds} '
        'sizeMs=${sizeFetchStopwatch.elapsedMilliseconds} '
        'saveMs=${saveStopwatch.elapsedMilliseconds} '
        'cacheMs=${cacheStopwatch.elapsedMilliseconds} '
        'emojiCount=${dtos.length} '
        'sizeFetched=$sizeFetchCount '
        'sizeReused=$sizeReusedCount '
        'sizeFromApi=$sizeFromApiCount',
        name: _syncLogName,
      );
    } catch (_) {
      if (totalStopwatch.isRunning) {
        totalStopwatch.stop();
      }
      if (listFetchStopwatch.isRunning) {
        listFetchStopwatch.stop();
      }
      if (sizeFetchStopwatch.isRunning) {
        sizeFetchStopwatch.stop();
      }
      if (saveStopwatch.isRunning) {
        saveStopwatch.stop();
      }
      if (cacheStopwatch.isRunning) {
        cacheStopwatch.stop();
      }
      developer.log(
        'sync failed totalMs=${totalStopwatch.elapsedMilliseconds} '
        'listMs=${listFetchStopwatch.elapsedMilliseconds} '
        'sizeMs=${sizeFetchStopwatch.elapsedMilliseconds} '
        'saveMs=${saveStopwatch.elapsedMilliseconds} '
        'cacheMs=${cacheStopwatch.elapsedMilliseconds} '
        'sizeFetched=$sizeFetchCount '
        'sizeReused=$sizeReusedCount '
        'sizeFromApi=$sizeFromApiCount',
        name: _syncLogName,
      );
      rethrow;
    }
  }

  /// レスポンスから抽出した絵文字を DB とキャッシュに保存する（インターセプター用）。
  ///
  /// 他鯖のノートに含まれる `emojis` は bare name（`sumi` など）で渡されるが、
  /// URL のホストと自鯖を比較して `sumi@jakten.mis.st` 形式に正規化します。
  /// 既にサイズがキャッシュ済みの絵文字はスキップします。
  Future<void> cacheFromResponse(EmojiExtractionResult result) async {
    final emojisToCache = result.emojisToCache;
    final localNames = result.localNames;

    final session = await authDataSource.loadSession();

    // URL のホストを使って名前を正規化する
    // 例: {"sumi": "https://jakten.mis.st/..."} → {"sumi@jakten.mis.st": "https://..."}
    final normalizedWithUrls = _normalizeEmojiKeys(emojisToCache, session);

    // localNames の URL を解決する
    // reactions から抽出された自鯖絵文字（bare name）の URL は以下の優先順で検索：
    // 1. EmojiCache（bare name）
    // 2. emojisToCache から @. 形式で検索
    // 3. EmojiCache から @. 形式で検索
    final merged = Map<String, String>.from(normalizedWithUrls);

    for (final name in localNames) {
      if (!merged.containsKey(name)) {
        String? url = cache.getUrl(name);

        if (url == null) {
          // Try finding in emojisToCache with @. suffix
          final localSuffixKey = '$name@.';
          url = emojisToCache[localSuffixKey];
        }

        url ??= cache.getUrl('$name@.');

        if (url != null && url.isNotEmpty) {
          // Store with bare name key for consistency
          merged[name] = url;
        }
      }
    }

    if (merged.isEmpty) return;

    // 既にサイズがキャッシュ済みのものはスキップ（不要なリクエストを防ぐ）
    final toFetch = Map<String, String>.fromEntries(
      merged.entries.where((e) {
        final entry = cache.getEntry(e.key);
        final needsFetch =
            entry == null || entry.width == null || entry.height == null;
        return needsFetch;
      }),
    );

    if (toFetch.isEmpty) {
      return;
    }

    // キーがすでに正規化済みなので fetchAndCacheSizes に直接渡す
    // host パラメータを渡さず、キー名をそのまま使わせる
    await _fetchAndCacheSizesByKey(toFetch);
  }

  /// DataSource から渡されたキャッシュヒントを保存する。
  Future<void> cacheEmojiHints(List<EmojiToCache> emojisToCache) async {
    if (emojisToCache.isEmpty) {
      return;
    }
    final mapped = <String, String>{
      for (final item in emojisToCache) item.name: item.url,
    };
    await cacheFromResponse(
      EmojiExtractionResult(
        emojisToCache: mapped,
        localNames: const <String>{},
      ),
    );
  }

  /// 絵文字キーをすでに正規化済みの前提でサイズを取得し DB/キャッシュを更新する。
  ///
  /// [fetchAndCacheSizes] は内部でキーの再生成を行うため直接使えない。
  /// こちらは [nameToUrl] のキーをそのまま DB のキーとして使用する。
  Future<void> _fetchAndCacheSizesByKey(Map<String, String> nameToUrl) async {
    if (nameToUrl.isEmpty) {
      return;
    }

    final companions =
        await _mapWithConcurrency<
          MapEntry<String, String>,
          EmojiTableCompanion?
        >(
          nameToUrl.entries.toList(),
          concurrency: _imageSizeFetchConcurrency,
          task: (entry) async {
            try {
              final size = await dataSource.fetchEmojiImageSize(
                imageUrl: entry.value,
              );
              if (size == null) {
                return null;
              }
              return EmojiTableCompanion(
                name: Value(entry.key),
                url: Value(entry.value),
                width: Value(size.width),
                height: Value(size.height),
              );
            } catch (_) {
              return null;
            }
          },
        );

    final updates = companions.whereType<EmojiTableCompanion>().toList();

    if (updates.isNotEmpty) {
      await database.upsertEmojiSizes(updates);
      cache.upsertAll(_toCacheMapFromCompanions(updates));
    }
  }

  /// emoji の bare name を URL のホストを使って正規化する。
  ///
  /// - キーが既に `name@host` 形式なら変更なし
  /// - キーが bare name の場合、URL のホストが自鯖と一致すればそのまま、
  ///   他鯖なら `name@host` 形式に変換
  Map<String, String> _normalizeEmojiKeys(
    Map<String, String> emojisToCache,
    AuthSession? session,
  ) {
    final baseUrl = session?.baseUrl ?? '';
    final ownHost = session != null ? Uri.parse(baseUrl).host : null;

    final normalized = <String, String>{};

    for (final entry in emojisToCache.entries) {
      final name = entry.key;
      final url = entry.value;

      // 既に `name@host` 形式ならそのまま
      if (name.contains('@')) {
        normalized[name] = url;
        continue;
      }

      // URL からホストを抽出
      final urlHost = Uri.tryParse(url)?.host;

      if (urlHost == null || urlHost.isEmpty || urlHost == ownHost) {
        // 自鯖 or 不明 → bare name のまま
        normalized[name] = url;
      } else {
        // 他鯖 → `name@host` に変換
        final key = '$name@$urlHost';
        normalized[key] = url;
      }
    }

    return normalized;
  }

  /// 絵文字名 → URL のマップからサイズを取得し、DB とキャッシュを更新する。
  ///
  /// [EmojiCache] に存在しない絵文字を渡すことを想定。
  /// サイズ取得に失敗した絵文字はスキップし、取得できたものだけ保存する。
  ///
  /// [host] にサーバの baseUrl を指定する。
  /// null の場合は現在ログイン中のサーバを使用する。
  Future<void> fetchAndCacheSizes(
    Map<String, String> nameToUrl, {
    String? host,
  }) async {
    if (nameToUrl.isEmpty) return;

    final session = await authDataSource.loadSession();
    final resolvedHost = host ?? session?.baseUrl;
    if (resolvedHost == null) return;

    // 自鯖かどうかを判定し、他鯖なら "@hostname" サフィックスを付与する
    final isOwnServer = session != null && resolvedHost == session.baseUrl;
    final hostname = Uri.parse(resolvedHost).host;

    String keyFor(String name) => isOwnServer ? name : '$name@$hostname';

    final entries = nameToUrl.entries.toList();
    final companions =
        await _mapWithConcurrency<
          MapEntry<String, String>,
          EmojiTableCompanion?
        >(
          entries,
          concurrency: _imageSizeFetchConcurrency,
          task: (entry) async {
            try {
              final size = await dataSource.fetchEmojiImageSize(
                imageUrl: entry.value,
              );
              if (size == null) return null;
              return EmojiTableCompanion(
                name: Value(keyFor(entry.key)),
                url: Value(entry.value),
                width: Value(size.width),
                height: Value(size.height),
              );
            } catch (_) {
              return null;
            }
          },
        );

    final updates = companions.whereType<EmojiTableCompanion>().toList();
    if (updates.isNotEmpty) {
      await database.upsertEmojiSizes(updates);
      cache.upsertAll(_toCacheMapFromCompanions(updates));
    }
  }

  /// DB の全絵文字を [EmojiCache] に展開する。
  Future<void> loadToCache() async {
    final rows = await database.getAllEmojis();
    final map = {
      for (final r in rows)
        r.name: EmojiCacheEntry(url: r.url, width: r.width, height: r.height),
    };
    cache.populate(map);
  }

  EmojiTableCompanion _toCompanion(EmojiDto dto, {int? width, int? height}) {
    return EmojiTableCompanion(
      name: Value(dto.name),
      url: Value(dto.url),
      category: Value(dto.category),
      aliases: Value(jsonEncode(dto.aliases)),
      width: Value(width ?? dto.width),
      height: Value(height ?? dto.height),
    );
  }

  Map<String, EmojiCacheEntry> _toCacheMapFromCompanions(
    List<EmojiTableCompanion> companions,
  ) {
    final result = <String, EmojiCacheEntry>{};
    for (final c in companions) {
      result[c.name.value] = EmojiCacheEntry(
        url: c.url.value,
        width: c.width.present ? c.width.value : null,
        height: c.height.present ? c.height.value : null,
      );
    }
    return result;
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
