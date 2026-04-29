import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../di/di.dart';
import '../services/app_database.dart';
import '../services/emoji_cache.dart';

/// よく使われる絵文字リアクションの一覧（仮）。
const _kFrequentReactions = <String>[];

/// リアクション選択ボトムシート。
///
/// [showReactionPickerSheet] を呼び出して表示する。
/// ユーザーが絵文字を選択すると [onSelected] が呼ばれる。
class ReactionPickerSheet extends HookWidget {
  const ReactionPickerSheet({required this.onSelected, super.key});

  final ValueChanged<String> onSelected;

  List<String> _filterFrequent(String query) {
    if (query.isEmpty) return _kFrequentReactions;
    return _kFrequentReactions
        .where((e) => e.contains(query))
        .toList(growable: false);
  }

  List<String> _splitCategoryPath(String path) {
    return path
        .split('/')
        .map((segment) => segment.trim())
        .where((segment) => segment.isNotEmpty)
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
          .map((alias) => alias.trim())
          .where((alias) => alias.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  String _normalizeSearchQuery(String query) {
    return query.trim().toLowerCase().replaceAll(':', '');
  }

  bool _matchesCategoryPath(List<String> fullPathParts, List<String> currentPath) {
    if (fullPathParts.length < currentPath.length) {
      return false;
    }

    for (var i = 0; i < currentPath.length; i++) {
      if (fullPathParts[i] != currentPath[i]) {
        return false;
      }
    }

    return true;
  }

  bool _matchesEmojiQuery(_CustomEmojiItem item, String query) {
    if (query.isEmpty) return true;

    return item.name.toLowerCase().contains(query) ||
        item.aliases.any((alias) => alias.toLowerCase().contains(query));
  }

  int _searchPriority(_CustomEmojiItem item, String normalizedQuery) {
    final normalizedName = item.name.toLowerCase();
    final hasExactName = item.name.toLowerCase() == normalizedQuery;
    final hasExactAlias = item.aliases.any(
      (alias) => alias.toLowerCase() == normalizedQuery,
    );
    final hasNamePrefix = normalizedName.startsWith(normalizedQuery);
    final hasAliasPrefix = item.aliases.any(
      (alias) => alias.toLowerCase().startsWith(normalizedQuery),
    );

    if (hasExactName) return 0;
    if (hasExactAlias) return 1;
    if (hasNamePrefix) return 2;
    if (hasAliasPrefix) return 3;
    return 4;
  }

  List<_CustomEmojiItem> _searchEmojisForPath(
    Map<String, List<_CustomEmojiItem>> allCategories,
    List<String> currentPath,
    String query,
  ) {
    final normalized = _normalizeSearchQuery(query);
    if (normalized.isEmpty) return const [];

    final results = <_CustomEmojiItem>[];
    for (final entry in allCategories.entries) {
      final fullPathParts = _splitCategoryPath(entry.key);
      if (!_matchesCategoryPath(fullPathParts, currentPath)) {
        continue;
      }

      results.addAll(
        entry.value.where((item) => _matchesEmojiQuery(item, normalized)),
      );
    }

    results.sort((a, b) {
      final rankDiff = _searchPriority(a, normalized) - _searchPriority(b, normalized);
      if (rankDiff != 0) return rankDiff;
      return a.name.compareTo(b.name);
    });
    return List<_CustomEmojiItem>.unmodifiable(results);
  }

  Future<Map<String, List<_CustomEmojiItem>>>
  _loadCustomEmojisByCategory() async {
    final db = getIt<AppDatabase>();
    final cache = getIt<EmojiCache>();
    final rows = await db.getAllEmojis();

    final grouped = <String, List<_CustomEmojiItem>>{};
    for (final row in rows) {
      final url = cache.getUrl(row.name);
      if (url == null || url.isEmpty) continue;

      final category = _normalizeCategoryPath(row.category ?? '');
      grouped
          .putIfAbsent(category, () => [])
          .add(
            _CustomEmojiItem(
              name: row.name,
              url: url,
              aliases: _decodeAliases(row.aliases),
              categoryPath: category,
            ),
          );
    }

    for (final list in grouped.values) {
      list.sort((a, b) => a.name.compareTo(b.name));
    }

    final sortedKeys = grouped.keys.toList()..sort();
    return {
      for (final key in sortedKeys)
        key: List<_CustomEmojiItem>.unmodifiable(grouped[key]!),
    };
  }

  /// 現在のパスの直下にあるサブカテゴリと絵文字を取得
  Map<String, dynamic> _getSubItemsForPath(
    Map<String, List<_CustomEmojiItem>> allCategories,
    List<String> currentPath,
  ) {
    final subCategories = <String, List<_CustomEmojiItem>>{};
    final emojis = <_CustomEmojiItem>[];

    for (final entry in allCategories.entries) {
      final fullPathParts = _splitCategoryPath(entry.key);

      // 現在パスと共通プレフィックスが一致しないカテゴリは対象外。
      if (!_matchesCategoryPath(fullPathParts, currentPath)) {
        continue;
      }

      if (fullPathParts.length == currentPath.length) {
        // 現在のカテゴリ自身に紐づく絵文字。
        emojis.addAll(entry.value);
      } else {
        // 1階層下のカテゴリ名だけを抽出して一覧化。
        final subCatName = fullPathParts[currentPath.length];
        subCategories.putIfAbsent(subCatName, () => const <_CustomEmojiItem>[]);
      }
    }

    return {'subCategories': subCategories, 'emojis': emojis};
  }

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final searchFocusNode = useFocusNode();
    final sheetController = useMemoized(DraggableScrollableController.new);
    final latestScrollController = useRef<ScrollController?>(null);
    final wasSearchFocused = useState(false);
    final query = useState('');
    final categoryPath = useState<List<String>>([]);
    final customByCategoryFuture = useMemoized(
      () => _loadCustomEmojisByCategory(),
    );
    final colorScheme = Theme.of(context).colorScheme;

    void handleBackToParentCategory() {
      if (categoryPath.value.isEmpty) return;
      categoryPath.value = categoryPath.value.sublist(
        0,
        categoryPath.value.length - 1,
      );
      searchController.clear();
      query.value = '';
    }

    useEffect(() {
      void handleSearchFocusChanged() {
        final focused = searchFocusNode.hasFocus;
        if (focused == wasSearchFocused.value) {
          return;
        }
        wasSearchFocused.value = focused;

        if (!focused) {
          return;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (sheetController.isAttached) {
            sheetController.animateTo(
              1.0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
            );
          }

          final scrollController = latestScrollController.value;
          if (scrollController != null && scrollController.hasClients) {
            scrollController.jumpTo(0);
          }
        });
      }

      searchFocusNode.addListener(handleSearchFocusChanged);
      return () => searchFocusNode.removeListener(handleSearchFocusChanged);
    }, [searchFocusNode, sheetController, wasSearchFocused]);

    return PopScope(
      canPop: categoryPath.value.isEmpty,
      onPopInvokedWithResult: (_, _) {
        if (categoryPath.value.isNotEmpty) {
          handleBackToParentCategory();
        }
      },
      child: DraggableScrollableSheet(
        controller: sheetController,
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 1.0,
        expand: false,
        builder: (context, scrollController) {
          latestScrollController.value = scrollController;

          Widget buildSearchResultsSliver(List<_CustomEmojiItem> emojis) {
            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = emojis[index];
                return _CustomEmojiSearchResultTile(
                  name: item.name,
                  url: item.url,
                  aliases: item.aliases,
                  categoryPath: item.categoryPath,
                  onTap: () => onSelected(':${item.name}:'),
                );
              }, childCount: emojis.length),
            );
          }

          final frequent = _filterFrequent(query.value);
          return FutureBuilder<Map<String, List<_CustomEmojiItem>>>(
            future: customByCategoryFuture,
            builder: (context, snapshot) {
              final slivers = <Widget>[
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PinnedSheetHeaderDelegate(
                    colorScheme: colorScheme,
                    categoryPath: categoryPath.value,
                    query: query.value,
                    searchController: searchController,
                    searchFocusNode: searchFocusNode,
                    onBack: categoryPath.value.isEmpty
                        ? null
                        : handleBackToParentCategory,
                    onClear: query.value.isEmpty
                        ? null
                        : () {
                            searchController.clear();
                            query.value = '';
                          },
                    onClose: () => Navigator.of(context).pop(),
                    onQueryChanged: (value) => query.value = value,
                  ),
                ),
              ];

              if (categoryPath.value.isEmpty && query.value.isEmpty) {
                slivers.add(
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: Text(
                        'よく使う絵文字',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ),
                );

                if (frequent.isEmpty) {
                  slivers.add(
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Text('該当する絵文字がありません'),
                      ),
                    ),
                  );
                } else {
                  slivers.add(
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 8,
                              childAspectRatio: 1,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final emoji = frequent[index];
                          return _EmojiCell(
                            emoji: emoji,
                            onTap: () => onSelected(emoji),
                          );
                        }, childCount: frequent.length),
                      ),
                    ),
                  );
                }
              }

              if (snapshot.connectionState != ConnectionState.done) {
                slivers.add(
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                slivers.add(
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text('リアクション一覧の読み込みに失敗しました'),
                    ),
                  ),
                );
              } else {
                final raw =
                    snapshot.data ?? const <String, List<_CustomEmojiItem>>{};

                if (categoryPath.value.isNotEmpty) {
                  // カテゴリ詳細ビュー
                  if (query.value.isNotEmpty) {
                    final emojis = _searchEmojisForPath(
                      raw,
                      categoryPath.value,
                      query.value,
                    );

                    if (emojis.isEmpty) {
                      slivers.add(
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Text('検索に一致するリアクションがありません'),
                          ),
                        ),
                      );
                    } else {
                      slivers.add(
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: Text(
                              '検索結果 ${emojis.length} 件',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                        ),
                      );
                      slivers.add(buildSearchResultsSliver(emojis));
                      slivers.add(
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),
                      );
                    }
                  } else {
                    final subItems = _getSubItemsForPath(raw, categoryPath.value);
                    final subCategories =
                        subItems['subCategories']
                            as Map<String, List<_CustomEmojiItem>>;
                    final emojis = subItems['emojis'] as List<_CustomEmojiItem>;

                    final hasContent =
                        subCategories.isNotEmpty || emojis.isNotEmpty;

                    if (!hasContent) {
                      slivers.add(
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Text('このカテゴリに表示できるリアクションがありません'),
                          ),
                        ),
                      );
                    } else {
                      // サブカテゴリを表示
                      if (subCategories.isNotEmpty) {
                        slivers.add(
                          SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final subCatName = subCategories.keys.elementAt(
                                index,
                              );
                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                title: Text(subCatName),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  categoryPath.value = [
                                    ...categoryPath.value,
                                    subCatName,
                                  ];
                                  searchController.clear();
                                  query.value = '';
                                },
                              );
                            }, childCount: subCategories.length),
                          ),
                        );
                      }

                      // 絵文字グリッドを表示
                      if (emojis.isNotEmpty) {
                        slivers.add(
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 8,
                                    childAspectRatio: 1,
                                  ),
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final item = emojis[index];
                                return _CustomEmojiCell(
                                  name: item.name,
                                  url: item.url,
                                  onTap: () => onSelected(':${item.name}:'),
                                );
                              }, childCount: emojis.length),
                            ),
                          ),
                        );
                      }
                    }
                  }
                } else {
                  // トップレベルのカテゴリ一覧
                  if (query.value.isNotEmpty) {
                    final emojis = _searchEmojisForPath(raw, const [], query.value);

                    if (emojis.isEmpty) {
                      slivers.add(
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Text('検索に一致するリアクションがありません'),
                          ),
                        ),
                      );
                    } else {
                      slivers.add(
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: Text(
                              '検索結果 ${emojis.length} 件',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                        ),
                      );
                      slivers.add(buildSearchResultsSliver(emojis));
                      slivers.add(
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),
                      );
                    }
                  } else {
                    final topLevelCategories = <String, int>{}; // カテゴリ名 -> アイテム数
                    for (final entry in raw.entries) {
                      final fullPath = entry.key;
                      final parts = _splitCategoryPath(fullPath);
                      if (parts.isEmpty) continue;
                      final topLevelCat = parts[0];
                      topLevelCategories[topLevelCat] =
                          (topLevelCategories[topLevelCat] ?? 0) +
                          entry.value.length;
                    }

                    final categories = topLevelCategories.entries.toList(growable: false)
                      ..sort((a, b) => a.key.compareTo(b.key));

                    if (categories.isEmpty) {
                      slivers.add(
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Text('表示できるリアクションがありません'),
                          ),
                        ),
                      );
                    } else {
                      slivers.add(
                        SliverList(
                          delegate: SliverChildBuilderDelegate((context, index) {
                            final entry = categories[index];
                            final category = entry.key;
                            final count = entry.value;

                            return ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              title: Text(category),
                              subtitle: Text('$count 件'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                categoryPath.value = [category];
                                searchController.clear();
                                query.value = '';
                              },
                            );
                          }, childCount: categories.length),
                        ),
                      );
                      slivers.add(
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),
                      );
                    }
                  }
                }
              }

              return CustomScrollView(
                controller: scrollController,
                slivers: slivers,
              );
            },
          );
        },
      ),
    );
  }
}

class _EmojiCell extends StatelessWidget {
  const _EmojiCell({required this.emoji, required this.onTap});

  final String emoji;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
    );
  }
}

class _CustomEmojiItem {
  const _CustomEmojiItem({
    required this.name,
    required this.url,
    required this.aliases,
    required this.categoryPath,
  });

  final String name;
  final String url;
  final List<String> aliases;
  final String categoryPath;
}

class _CustomEmojiSearchResultTile extends StatelessWidget {
  const _CustomEmojiSearchResultTile({
    required this.name,
    required this.url,
    required this.aliases,
    required this.categoryPath,
    required this.onTap,
  });

  final String name;
  final String url;
  final List<String> aliases;
  final String categoryPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final aliasSummary = switch (aliases.length) {
      0 => null,
      <= 3 => aliases.map((alias) => ':$alias:').join(', '),
      _ => '${aliases.take(3).map((alias) => ':$alias:').join(', ')}…',
    };
    final subtitle = [
      ?aliasSummary,
      categoryPath,
    ].join(' • ');

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: SizedBox(
        width: 32,
        height: 32,
        child: Image.network(
          url,
          fit: BoxFit.contain,
          errorBuilder: (_, error, stackTrace) => Center(
            child: Text(
              ':$name:',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ),
      title: Text(':$name:'),
      subtitle: subtitle.isEmpty
          ? null
          : Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
      onTap: onTap,
    );
  }
}

class _PinnedSheetHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _PinnedSheetHeaderDelegate({
    required this.colorScheme,
    required this.categoryPath,
    required this.query,
    required this.searchController,
    required this.searchFocusNode,
    required this.onClose,
    required this.onQueryChanged,
    this.onBack,
    this.onClear,
  });

  final ColorScheme colorScheme;
  final List<String> categoryPath;
  final String query;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final VoidCallback? onBack;
  final VoidCallback? onClear;
  final VoidCallback onClose;
  final ValueChanged<String> onQueryChanged;

  // Padding 16 + handle 4 + gaps 16 + title row 48 + search bar 56 = 140.
  static const double _height = 140;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: colorScheme.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: overlapsContent
              ? Border(bottom: BorderSide(color: colorScheme.outlineVariant))
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            children: [
              const Center(child: _SheetDragHandle()),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (onBack != null)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'カテゴリ一覧に戻る',
                      onPressed: onBack,
                    ),
                  Expanded(
                    child: Text(
                      categoryPath.isEmpty
                          ? 'リアクションを選択'
                          : categoryPath.join(' / '),
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: '閉じる',
                    onPressed: onClose,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SearchBar(
                controller: searchController,
                focusNode: searchFocusNode,
                hintText: '絵文字を検索',
                leading: const Icon(Icons.search),
                trailing: [
                  if (query.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: onClear,
                    ),
                ],
                onChanged: onQueryChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedSheetHeaderDelegate oldDelegate) {
    return colorScheme != oldDelegate.colorScheme ||
        categoryPath != oldDelegate.categoryPath ||
        query != oldDelegate.query ||
        searchController != oldDelegate.searchController ||
        searchFocusNode != oldDelegate.searchFocusNode ||
        onBack != oldDelegate.onBack ||
        onClear != oldDelegate.onClear ||
        onClose != oldDelegate.onClose ||
        onQueryChanged != oldDelegate.onQueryChanged;
  }
}

class _SheetDragHandle extends StatelessWidget {
  const _SheetDragHandle();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _CustomEmojiCell extends StatelessWidget {
  const _CustomEmojiCell({
    required this.name,
    required this.url,
    required this.onTap,
  });

  final String name;
  final String url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Image.network(
          url,
          fit: BoxFit.contain,
          errorBuilder: (_, error, stackTrace) => Center(
            child: Text(
              ':$name:',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ),
    );
  }
}

/// リアクション選択ボトムシートを表示するユーティリティ関数。
///
/// ShellRoute 配下の画面から呼ばれる前提のため、常にルート Navigator
/// に表示して AppBar / NavigationBar より前面に重ねる。
///
/// ユーザーが絵文字を選択した場合はその文字列が返り、
/// キャンセルした場合は `null` が返る。
Future<String?> showReactionPickerSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => ReactionPickerSheet(
      onSelected: (emoji) => Navigator.of(context).pop(emoji),
    ),
  );
}
