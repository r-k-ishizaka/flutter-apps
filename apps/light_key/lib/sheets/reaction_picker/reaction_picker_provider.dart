import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:light_key/utils/emoji_name_scope.dart';

import '../../datasources/auth_data_source.dart';
import '../../di/di.dart';
import '../../services/app_database.dart';
import 'custom_emoji_item.dart';

/// リアクションピッカーのUI状態とビジネスロジックを管理する ChangeNotifier。
class ReactionPickerProvider extends ChangeNotifier {
  ReactionPickerProvider({AppDatabase? database})
    : _database = database ?? getIt<AppDatabase>();

  final AppDatabase _database;

  // ── State ──────────────────────────────────────────────────────────────────

  List<String> _categoryPath = const [];
  String _query = '';
  final Map<String, EmojiPickerRow> _loadedRowsByName = {};
  final Set<String> _loadedTopCategories = {};
  bool _allEmojisLoaded = false;
  Map<String, int> _topCategoryCounts = const {};
  Map<String, List<CustomEmojiItem>> _emojisByCategory = const {};
  Map<String, String> _representativeUrlByCategoryPath = const {};
  Map<String, String> _representativeUrlByTopCategory = const {};
  bool _isLoading = true;
  Object? _loadError;
  bool _disposed = false;
  String? _sessionHost;
  Future<void>? _sessionHostLoadTask;
  Future<void>? _initialLoadTask;
  List<String> _frequentReactions = const [];
  static final RegExp _customEmojiPattern = RegExp(r'^:([^:]+):$');

  List<String> get categoryPath => _categoryPath;

  String get query => _query;

  Map<String, List<CustomEmojiItem>> get emojisByCategory => _emojisByCategory;

  bool get isLoading => _isLoading;

  Object? get loadError => _loadError;

  /// トップカテゴリの初期ロードを必要時に1回だけ開始する。
  Future<void> ensureInitialCategoriesLoaded() {
    return _initialLoadTask ??= _loadInitialCategories();
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void navigateToCategory(List<String> path) {
    _categoryPath = List.unmodifiable(path);
    _query = '';
    _safeNotifyListeners();
    unawaited(_ensureDataForPath(path));
  }

  /// 1段階上のカテゴリへ戻る。
  void navigateBack() {
    if (_categoryPath.isEmpty) return;
    _categoryPath = List.unmodifiable(
      _categoryPath.sublist(0, _categoryPath.length - 1),
    );
    _query = '';
    _safeNotifyListeners();
  }

  void updateQuery(String q) {
    if (_query == q) return;
    _query = q;
    _safeNotifyListeners();
    if (_query.isNotEmpty && !_allEmojisLoaded) {
      unawaited(_ensureAllEmojisLoaded());
    }
  }

  void clearQuery() {
    if (_query.isEmpty) return;
    _query = '';
    _safeNotifyListeners();
  }

  // ── Computed ────────────────────────────────────────────────────────────────

  /// よく使う絵文字のフィルタリング済み一覧。
  List<String> get filteredFrequent {
    if (_query.isEmpty) return _frequentReactions;
    return _frequentReactions
        .where((e) => e.contains(_query))
        .toList(growable: false);
  }

  /// 「:name:」形式のカスタム絵文字なら画像URLを返す。
  String? getFrequentCustomEmojiUrl(String emoji) {
    final match = _customEmojiPattern.firstMatch(emoji);
    if (match == null) {
      return null;
    }
    final shortcode = match.group(1);
    if (shortcode == null || shortcode.isEmpty) {
      return null;
    }
    return _loadedRowsByName[shortcode]?.url;
  }

  /// 「:name:」形式のカスタム絵文字なら name を返す。
  String? getFrequentCustomEmojiName(String emoji) {
    final match = _customEmojiPattern.firstMatch(emoji);
    return match?.group(1);
  }

  /// 絵文字選択回数を記録し、よく使う絵文字を更新する。
  Future<void> recordEmojiSelected(String emoji) async {
    if (emoji.isEmpty) {
      return;
    }
    await _database.incrementEmojiUsage(emoji);
    await _reloadFrequentReactions();
    _safeNotifyListeners();
  }

  /// 現在のカテゴリパス配下での検索結果。
  List<CustomEmojiItem> searchEmojisForCurrentPath() {
    return _searchEmojisForPath(_emojisByCategory, _categoryPath, _query);
  }

  /// 現在のカテゴリパス直下にあるサブカテゴリ名と絵文字を返す。
  ({List<String> subCategoryNames, List<CustomEmojiItem> emojis})
  getSubItemsForCurrentPath() {
    return _getSubItemsForPath(_emojisByCategory, _categoryPath);
  }

  /// トップレベルのカテゴリ一覧（カテゴリ名 → アイテム数）。
  List<MapEntry<String, int>> get topLevelCategories {
    return _topCategoryCounts.entries.toList(growable: false)
      ..sort((a, b) => a.key.compareTo(b.key));
  }

  /// 指定されたカテゴリの代表絵文字URLを取得。なければnull。
  String? getRepresentativeEmojiUrlForCategory(String categoryPath) {
    return _representativeUrlByCategoryPath[categoryPath];
  }

  /// トップレベルカテゴリの代表絵文字URLを取得。なければnull。
  String? getRepresentativeEmojiUrlByTopCategory(String topCategory) {
    return _representativeUrlByTopCategory[topCategory];
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  List<String> _splitCategoryPath(String path) {
    return path
        .split('/')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
  }

  String _normalizeCategoryPath(String path) {
    final segments = _splitCategoryPath(path);
    return segments.isEmpty ? 'その他' : segments.join('/');
  }

  List<String> _decodeAliases(String? rawAliases) {
    if (rawAliases == null || rawAliases.isEmpty) return const [];
    try {
      final decoded = jsonDecode(rawAliases);
      if (decoded is! List) return const [];
      return decoded
          .whereType<String>()
          .map((a) => a.trim())
          .where((a) => a.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  String _normalizeSearchQuery(String query) {
    return query.trim().toLowerCase().replaceAll(':', '');
  }

  bool _matchesCategoryPath(
    List<String> fullPathParts,
    List<String> currentPath,
  ) {
    if (fullPathParts.length < currentPath.length) return false;
    for (var i = 0; i < currentPath.length; i++) {
      if (fullPathParts[i] != currentPath[i]) return false;
    }
    return true;
  }

  bool _matchesEmojiQuery(CustomEmojiItem item, String normalizedQuery) {
    if (normalizedQuery.isEmpty) return true;
    return item.name.toLowerCase().contains(normalizedQuery) ||
        item.aliases.any(
          (alias) => alias.toLowerCase().contains(normalizedQuery),
        );
  }

  int _searchPriority(CustomEmojiItem item, String normalizedQuery) {
    final name = item.name.toLowerCase();
    if (name == normalizedQuery) return 0;
    if (item.aliases.any((a) => a.toLowerCase() == normalizedQuery)) return 1;
    if (name.startsWith(normalizedQuery)) return 2;
    if (item.aliases.any((a) => a.toLowerCase().startsWith(normalizedQuery))) {
      return 3;
    }
    return 4;
  }

  List<CustomEmojiItem> _searchEmojisForPath(
    Map<String, List<CustomEmojiItem>> allCategories,
    List<String> currentPath,
    String query,
  ) {
    final normalized = _normalizeSearchQuery(query);
    if (normalized.isEmpty) return const [];

    final results = <CustomEmojiItem>[];
    for (final entry in allCategories.entries) {
      final fullPathParts = _splitCategoryPath(entry.key);
      if (!_matchesCategoryPath(fullPathParts, currentPath)) continue;
      results.addAll(
        entry.value.where((item) => _matchesEmojiQuery(item, normalized)),
      );
    }

    results.sort((a, b) {
      final diff =
          _searchPriority(a, normalized) - _searchPriority(b, normalized);
      return diff != 0 ? diff : a.name.compareTo(b.name);
    });
    return List<CustomEmojiItem>.unmodifiable(results);
  }

  ({List<String> subCategoryNames, List<CustomEmojiItem> emojis})
  _getSubItemsForPath(
    Map<String, List<CustomEmojiItem>> allCategories,
    List<String> currentPath,
  ) {
    final subCatNames = <String>{};
    final emojis = <CustomEmojiItem>[];

    for (final entry in allCategories.entries) {
      final fullPathParts = _splitCategoryPath(entry.key);
      if (!_matchesCategoryPath(fullPathParts, currentPath)) continue;
      if (fullPathParts.length == currentPath.length) {
        emojis.addAll(entry.value);
      } else {
        subCatNames.add(fullPathParts[currentPath.length]);
      }
    }

    return (subCategoryNames: (subCatNames.toList()..sort()), emojis: emojis);
  }

  Future<void> _loadInitialCategories() async {
    try {
      await _ensureSessionHostLoaded();
      final rows = await _database.getEmojisForPicker();

      final counts = <String, int>{};
      for (final row in rows) {
        if (!isEmojiAvailableForHost(row.name, sessionHost: _sessionHost)) {
          continue;
        }
        final normalized = _normalizeCategoryPath(row.category ?? '');
        final parts = _splitCategoryPath(normalized);
        if (parts.isEmpty) continue;
        final top = parts[0];
        counts[top] = (counts[top] ?? 0) + 1;
      }

      _topCategoryCounts = Map.unmodifiable(counts);

      // 初期表示で代表アイコンを出せるよう、カテゴリデータも同時に構築する。
      _mergeRows(rows);
      await _reloadFrequentReactions();

      _isLoading = false;
      _loadError = null;
    } catch (e) {
      _loadError = e;
      _isLoading = false;
    }
    _safeNotifyListeners();
  }

  Future<void> _ensureDataForPath(List<String> path) async {
    if (path.isEmpty) return;

    final top = path.first;
    if (_loadedTopCategories.contains(top) || _allEmojisLoaded) {
      return;
    }

    _isLoading = true;
    _safeNotifyListeners();

    try {
      await _ensureSessionHostLoaded();
      final rows = await _database.getEmojisForPickerByTopCategory(top);
      _mergeRows(rows, topCategoryFilter: top);
      _loadedTopCategories.add(top);
      _isLoading = false;
      _loadError = null;
    } catch (e) {
      _loadError = e;
      _isLoading = false;
    }
    _safeNotifyListeners();
  }

  Future<void> _ensureAllEmojisLoaded() async {
    if (_allEmojisLoaded) return;

    _isLoading = true;
    _safeNotifyListeners();

    try {
      await _ensureSessionHostLoaded();
      final rows = await _database.getEmojisForPicker();
      _mergeRows(rows);
      _allEmojisLoaded = true;
      _loadedTopCategories
        ..clear()
        ..addAll(_topCategoryCounts.keys);
      _isLoading = false;
      _loadError = null;
    } catch (e) {
      _loadError = e;
      _isLoading = false;
    }
    _safeNotifyListeners();
  }

  Future<void> _reloadFrequentReactions() async {
    final top = await _database.getTopUsedEmojis(limit: 16);
    _frequentReactions = top
        .where(_isFrequentEmojiDisplayable)
        .toList(growable: false);
  }

  bool _isFrequentEmojiDisplayable(String emoji) {
    final match = _customEmojiPattern.firstMatch(emoji);
    if (match == null) {
      return true;
    }
    final shortcode = match.group(1);
    if (shortcode == null || shortcode.isEmpty) {
      return false;
    }
    return _loadedRowsByName.containsKey(shortcode);
  }

  void _mergeRows(List<EmojiPickerRow> rows, {String? topCategoryFilter}) {
    for (final row in rows) {
      if (row.url.isEmpty) continue;
      if (!isEmojiAvailableForHost(row.name, sessionHost: _sessionHost)) {
        continue;
      }
      final category = _normalizeCategoryPath(row.category ?? '');
      final parts = _splitCategoryPath(category);
      if (parts.isEmpty) continue;
      if (topCategoryFilter != null && parts.first != topCategoryFilter) {
        continue;
      }

      _loadedRowsByName[row.name] = EmojiPickerRow(
        name: row.name,
        category: category,
        url: row.url,
        aliases: row.aliases,
      );
    }

    _rebuildEmojiMapFromLoadedRows();
  }

  int _stableIndexForKey(String key, int length) {
    if (length <= 1) return 0;
    var hash = 0;
    for (final unit in key.codeUnits) {
      hash = ((hash * 31) + unit) & 0x7fffffff;
    }
    return hash % length;
  }

  Future<void> _ensureSessionHostLoaded() {
    return _sessionHostLoadTask ??= _loadSessionHost();
  }

  Future<void> _loadSessionHost() async {
    try {
      final session = await getIt<AuthDataSource>().loadSession();
      final parsedHost = Uri.tryParse(session?.baseUrl ?? '')?.host;
      _sessionHost = (parsedHost == null || parsedHost.isEmpty)
          ? null
          : parsedHost.toLowerCase();
    } catch (_) {
      _sessionHost = null;
    }
  }

  void _rebuildEmojiMapFromLoadedRows() {
    final grouped = <String, List<CustomEmojiItem>>{};
    for (final row in _loadedRowsByName.values) {
      final category = row.category ?? 'その他';
      grouped
          .putIfAbsent(category, () => [])
          .add(
            CustomEmojiItem(
              name: row.name,
              url: row.url,
              aliases: _decodeAliases(row.aliases),
              categoryPath: category,
            ),
          );
    }

    for (final list in grouped.values) {
      list.sort((a, b) => a.name.compareTo(b.name));
    }

    final sortedKeys = grouped.keys.toList()..sort();
    _emojisByCategory = {
      for (final key in sortedKeys)
        key: List<CustomEmojiItem>.unmodifiable(grouped[key]!),
    };

    final representativeByCategory = <String, String>{};
    final representativeByTop = <String, String>{};
    final topItems = <String, List<CustomEmojiItem>>{};

    for (final categoryPath in sortedKeys) {
      final items = _emojisByCategory[categoryPath]!;
      if (items.isEmpty) continue;
      final idx = _stableIndexForKey(categoryPath, items.length);
      representativeByCategory[categoryPath] = items[idx].url;

      final parts = _splitCategoryPath(categoryPath);
      if (parts.isEmpty) continue;
      topItems.putIfAbsent(parts.first, () => []).addAll(items);
    }

    final sortedTop = topItems.keys.toList()..sort();
    for (final top in sortedTop) {
      final items = topItems[top]!;
      if (items.isEmpty) continue;
      final idx = _stableIndexForKey(top, items.length);
      representativeByTop[top] = items[idx].url;
    }

    _representativeUrlByCategoryPath = Map.unmodifiable(
      representativeByCategory,
    );
    _representativeUrlByTopCategory = Map.unmodifiable(representativeByTop);
  }

  void _safeNotifyListeners() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
