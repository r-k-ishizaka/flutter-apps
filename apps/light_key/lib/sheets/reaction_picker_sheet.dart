import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../di/di.dart';
import '../services/app_database.dart';
import '../services/emoji_cache.dart';

/// よく使われる絵文字リアクションの一覧（仮）。
const _kFrequentReactions = [
  '👍', '❤️', '😂', '😮', '😢', '🙏',
  '🔥', '🎉', '✨', '👏', '🤔', '😍',
  '😎', '🥳', '😅', '🤣', '🥺', '💯',
  '🚀', '⭐', '💪', '👀', '🌟', '🫶',
];

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

  Future<Map<String, List<_CustomEmojiItem>>> _loadCustomEmojisByCategory() async {
    final db = getIt<AppDatabase>();
    final cache = getIt<EmojiCache>();
    final rows = await db.getAllEmojis();

    final grouped = <String, List<_CustomEmojiItem>>{};
    for (final row in rows) {
      final url = cache.getUrl(row.name);
      if (url == null || url.isEmpty) continue;

      final category = (row.category?.trim().isNotEmpty ?? false)
          ? row.category!.trim()
          : 'その他';
      grouped.putIfAbsent(category, () => []).add(
        _CustomEmojiItem(name: row.name, url: url),
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
      final fullPathParts = entry.key.split('/');

      // 現在パスと共通プレフィックスが一致しないカテゴリは対象外。
      if (fullPathParts.length < currentPath.length) {
        continue;
      }
      var matchesPrefix = true;
      for (var i = 0; i < currentPath.length; i++) {
        if (fullPathParts[i] != currentPath[i]) {
          matchesPrefix = false;
          break;
        }
      }
      if (!matchesPrefix) {
        continue;
      }

      if (fullPathParts.length == currentPath.length) {
        // 現在のカテゴリ自身に紐づく絵文字。
        emojis.addAll(entry.value);
      } else {
        // 1階層下のカテゴリ名だけを抽出して一覧化。
        final subCatName = fullPathParts[currentPath.length];
        subCategories.putIfAbsent(
          subCatName,
          () => const <_CustomEmojiItem>[],
        );
      }
    }

    return {
      'subCategories': subCategories,
      'emojis': emojis,
    };
  }

  /// パス配下のカテゴリをフィルター
  Map<String, dynamic> _filterSubItems(
    Map<String, dynamic> subItems,
    String query,
  ) {
    if (query.isEmpty) return subItems;
    final normalized = query.toLowerCase();

    final subCategories =
        (subItems['subCategories'] as Map<String, List<_CustomEmojiItem>>)
            .entries
            .where((e) => e.key.toLowerCase().contains(normalized))
            .fold<Map<String, List<_CustomEmojiItem>>>(
              <String, List<_CustomEmojiItem>>{},
              (acc, e) {
                acc[e.key] = e.value;
                return acc;
              },
            );

    final emojis = (subItems['emojis'] as List<_CustomEmojiItem>)
        .where((item) => item.name.toLowerCase().contains(normalized))
        .toList(growable: false);

    return {
      'subCategories': subCategories,
      'emojis': emojis,
    };
  }

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final query = useState('');
    final categoryPath = useState<List<String>>([]);
    final customByCategoryFuture = useMemoized(
      () => _loadCustomEmojisByCategory(),
    );
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 1.0,
      expand: false,
      builder: (context, scrollController) {
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
                  onBack: categoryPath.value.isEmpty
                      ? null
                      : () {
                          categoryPath.value = categoryPath.value.isEmpty
                              ? []
                              : categoryPath.value.sublist(
                                  0,
                                  categoryPath.value.length - 1,
                                );
                          searchController.clear();
                          query.value = '';
                        },
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

            if (categoryPath.value.isEmpty) {
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
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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

            slivers.add(
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Text(
                    categoryPath.value.isEmpty ? 'リアクション一覧' : 'カテゴリ詳細',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
            );

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
              final raw = snapshot.data ?? const <String, List<_CustomEmojiItem>>{};

              if (categoryPath.value.isNotEmpty) {
                // カテゴリ詳細ビュー
                final subItems = _getSubItemsForPath(raw, categoryPath.value);
                final filteredItems = _filterSubItems(subItems, query.value);
                final subCategories =
                    filteredItems['subCategories'] as Map<String, List<_CustomEmojiItem>>;
                final emojis = filteredItems['emojis'] as List<_CustomEmojiItem>;

                final hasContent = subCategories.isNotEmpty || emojis.isNotEmpty;

                if (!hasContent) {
                  slivers.add(
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          query.value.isEmpty
                              ? 'このカテゴリに表示できるリアクションがありません'
                              : '検索に一致するリアクションがありません',
                        ),
                      ),
                    ),
                  );
                } else {
                  // サブカテゴリを表示
                  if (subCategories.isNotEmpty) {
                    slivers.add(
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final subCatName =
                              subCategories.keys.elementAt(index);
                          return ListTile(
                            dense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
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
                          delegate: SliverChildBuilderDelegate((context, index) {
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
              } else {
                // トップレベルのカテゴリ一覧
                final topLevelCategories =
                    <String, int>{}; // カテゴリ名 -> アイテム数
                for (final entry in raw.entries) {
                  final fullPath = entry.key;
                  final parts = fullPath.split('/');
                  final topLevelCat = parts[0];
                  topLevelCategories[topLevelCat] =
                      (topLevelCategories[topLevelCat] ?? 0) + entry.value.length;
                }

                final filtered = topLevelCategories.entries
                    .where((e) {
                  if (query.value.isEmpty) return true;
                  final normalized = query.value.toLowerCase();
                  return e.key.toLowerCase().contains(normalized);
                })
                    .toList(growable: false)
                  ..sort((a, b) => a.key.compareTo(b.key));

                if (filtered.isEmpty) {
                  slivers.add(
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          query.value.isEmpty
                              ? '表示できるリアクションがありません'
                              : '検索に一致するリアクションがありません',
                        ),
                      ),
                    ),
                  );
                } else {
                  slivers.add(
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final entry = filtered[index];
                        final category = entry.key;
                        final count = entry.value;

                        return ListTile(
                          dense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          title: Text(category),
                          subtitle: Text('$count 件'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            categoryPath.value = [category];
                            searchController.clear();
                            query.value = '';
                          },
                        );
                      }, childCount: filtered.length),
                    ),
                  );
                  slivers.add(
                      const SliverToBoxAdapter(child: SizedBox(height: 16)));
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
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 28)),
      ),
    );
  }
}

class _CustomEmojiItem {
  const _CustomEmojiItem({required this.name, required this.url});

  final String name;
  final String url;
}

class _PinnedSheetHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _PinnedSheetHeaderDelegate({
    required this.colorScheme,
    required this.categoryPath,
    required this.query,
    required this.searchController,
    required this.onClose,
    required this.onQueryChanged,
    this.onBack,
    this.onClear,
  });

  final ColorScheme colorScheme;
  final List<String> categoryPath;
  final String query;
  final TextEditingController searchController;
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
              ? Border(
                  bottom: BorderSide(color: colorScheme.outlineVariant),
                )
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
