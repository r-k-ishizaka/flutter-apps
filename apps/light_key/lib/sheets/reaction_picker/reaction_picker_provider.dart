import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../di/di.dart';
import '../../services/app_database.dart';
import 'custom_emoji_item.dart';

/// よく使われる絵文字リアクションの一覧（仮）。
const _kFrequentReactions = <String>[];

/// リアクションピッカーのUI状態とビジネスロジックを管理する ChangeNotifier。
class ReactionPickerProvider extends ChangeNotifier {
  ReactionPickerProvider() {
    _loadEmojis();
  }

  // ── State ──────────────────────────────────────────────────────────────────

  List<String> _categoryPath = const [];
  String _query = '';
  Map<String, List<CustomEmojiItem>> _emojisByCategory = const {};
  bool _isLoading = true;
  Object? _loadError;

  List<String> get categoryPath => _categoryPath;
  String get query => _query;
  Map<String, List<CustomEmojiItem>> get emojisByCategory => _emojisByCategory;
  bool get isLoading => _isLoading;
  Object? get loadError => _loadError;

  // ── Navigation ─────────────────────────────────────────────────────────────

  void navigateToCategory(List<String> path) {
    _categoryPath = List.unmodifiable(path);
    _query = '';
    notifyListeners();
  }

  /// 1段階上のカテゴリへ戻る。
  void navigateBack() {
    if (_categoryPath.isEmpty) return;
    _categoryPath = List.unmodifiable(
      _categoryPath.sublist(0, _categoryPath.length - 1),
    );
    _query = '';
    notifyListeners();
  }

  void updateQuery(String q) {
    if (_query == q) return;
    _query = q;
    notifyListeners();
  }

  void clearQuery() {
    if (_query.isEmpty) return;
    _query = '';
    notifyListeners();
  }

  // ── Computed ────────────────────────────────────────────────────────────────

  /// よく使う絵文字のフィルタリング済み一覧。
  List<String> get filteredFrequent {
    if (_query.isEmpty) return _kFrequentReactions;
    return _kFrequentReactions
        .where((e) => e.contains(_query))
        .toList(growable: false);
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
    final map = <String, int>{};
    for (final entry in _emojisByCategory.entries) {
      final parts = _splitCategoryPath(entry.key);
      if (parts.isEmpty) continue;
      final top = parts[0];
      map[top] = (map[top] ?? 0) + entry.value.length;
    }
    return map.entries.toList(growable: false)
      ..sort((a, b) => a.key.compareTo(b.key));
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

    return (
      subCategoryNames: (subCatNames.toList()..sort()),
      emojis: emojis,
    );
  }

  Future<void> _loadEmojis() async {
    try {
      final db = getIt<AppDatabase>();
      final rows = await db.getEmojisForPicker();

      final grouped = <String, List<CustomEmojiItem>>{};
      for (final row in rows) {
        if (row.url.isEmpty) continue;
        final category = _normalizeCategoryPath(row.category ?? '');
        grouped.putIfAbsent(category, () => []).add(
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
      _isLoading = false;
    } catch (e) {
      _loadError = e;
      _isLoading = false;
    }
    notifyListeners();
  }
}
