import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import 'custom_emoji_item.dart';
import 'emoji_cells.dart';
import 'pinned_sheet_header.dart';
import 'reaction_picker_provider.dart';
import 'search_result_tile.dart';

/// リアクションピッカーの本体ウィジェット。
///
/// 上位の [ReactionPickerProvider] を参照してUI全体を組み立てる。
/// スクロール・フォーカス制御などのUI固有の状態はこのウィジェット内で保持する。
class ReactionPickerBody extends HookWidget {
  const ReactionPickerBody({required this.onSelected, super.key});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ReactionPickerProvider>();
    final searchController = useTextEditingController();
    final searchFocusNode = useFocusNode();
    final sheetController = useMemoized(DraggableScrollableController.new);
    final latestScrollController = useRef<ScrollController?>(null);
    final wasSearchFocused = useState(false);
    final colorScheme = Theme.of(context).colorScheme;
    const collapsedSheetSize = 1 / 3;

    void scrollToTopAfterBuild() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final sc = latestScrollController.value;
        if (sc != null && sc.hasClients) sc.jumpTo(0);
      });
    }

    void handleBackToParentCategory() {
      notifier.navigateBack();
      scrollToTopAfterBuild();
    }

    void handleCategorySelected(List<String> nextPath) {
      notifier.navigateToCategory(nextPath);
      scrollToTopAfterBuild();
    }

    useEffect(() {
      void onFocusChanged() {
        final focused = searchFocusNode.hasFocus;
        if (focused == wasSearchFocused.value) return;
        wasSearchFocused.value = focused;
        if (!focused) return;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (sheetController.isAttached) {
            sheetController.animateTo(
              1.0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
            );
          }
          scrollToTopAfterBuild();
        });
      }

      searchFocusNode.addListener(onFocusChanged);
      return () => searchFocusNode.removeListener(onFocusChanged);
    }, [searchFocusNode, sheetController, wasSearchFocused]);

    return PopScope(
      canPop: notifier.categoryPath.isEmpty,
      onPopInvokedWithResult: (_, _) {
        if (notifier.categoryPath.isNotEmpty) handleBackToParentCategory();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final parentHeight = constraints.maxHeight;
          final minSheetSize =
              (PinnedSheetHeaderDelegate.headerHeight / parentHeight).clamp(
                0.0,
                1.0,
              );
          final initialSheetSize = collapsedSheetSize < minSheetSize
              ? minSheetSize
              : collapsedSheetSize;
          final snapSizes = <double>[
            minSheetSize,
            if (initialSheetSize > minSheetSize) initialSheetSize,
            1.0,
          ];

          return DraggableScrollableSheet(
            controller: sheetController,
            initialChildSize: initialSheetSize,
            minChildSize: minSheetSize,
            maxChildSize: 1.0,
            shouldCloseOnMinExtent: true,
            snap: true,
            snapSizes: snapSizes,
            expand: false,
            builder: (context, scrollController) {
              latestScrollController.value = scrollController;

              final slivers = <Widget>[
                SliverPersistentHeader(
                  pinned: true,
                  delegate: PinnedSheetHeaderDelegate(
                    colorScheme: colorScheme,
                    categoryPath: notifier.categoryPath,
                    query: notifier.query,
                    searchController: searchController,
                    searchFocusNode: searchFocusNode,
                    onBack: notifier.categoryPath.isEmpty
                        ? null
                        : handleBackToParentCategory,
                    onClear: notifier.query.isEmpty
                        ? null
                        : () {
                            searchController.clear();
                            notifier.clearQuery();
                          },
                    onClose: () => Navigator.of(context).pop(),
                    onQueryChanged: notifier.updateQuery,
                  ),
                ),
              ];

              // よく使う絵文字セクション（トップレベル＋クエリ未入力のみ表示）
              if (notifier.categoryPath.isEmpty && notifier.query.isEmpty) {
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

                final frequent = notifier.filteredFrequent;
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
                          return EmojiCell(
                            emoji: emoji,
                            onTap: () => onSelected(emoji),
                          );
                        }, childCount: frequent.length),
                      ),
                    ),
                  );
                }
              }

              // カスタム絵文字セクション
              if (notifier.isLoading) {
                slivers.add(
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                );
              } else if (notifier.loadError != null) {
                slivers.add(
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text('リアクション一覧の読み込みに失敗しました'),
                    ),
                  ),
                );
              } else if (notifier.categoryPath.isNotEmpty) {
                slivers.addAll(
                  _buildCategoryDetailSlivers(
                    context,
                    notifier,
                    handleCategorySelected,
                  ),
                );
              } else {
                slivers.addAll(
                  _buildTopLevelSlivers(
                    context,
                    notifier,
                    handleCategorySelected,
                  ),
                );
              }

              final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
              final bottomPadding = keyboardInset > 0
                  ? keyboardInset
                  : MediaQuery.viewPaddingOf(context).bottom;
              slivers.add(
                SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
              );

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

  // ── Sliver builders ────────────────────────────────────────────────────────

  List<Widget> _buildSearchResultsSlivers(
    BuildContext context,
    List<CustomEmojiItem> emojis,
  ) {
    if (emojis.isEmpty) {
      return [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text('検索に一致するリアクションがありません'),
          ),
        ),
      ];
    }

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            '検索結果 ${emojis.length} 件',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = emojis[index];
          return CustomEmojiSearchResultTile(
            name: item.name,
            url: item.url,
            aliases: item.aliases,
            categoryPath: item.categoryPath,
            onTap: () => onSelected(':${item.name}:'),
          );
        }, childCount: emojis.length),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),
    ];
  }

  List<Widget> _buildCategoryDetailSlivers(
    BuildContext context,
    ReactionPickerProvider notifier,
    void Function(List<String>) onCategorySelected,
  ) {
    if (notifier.query.isNotEmpty) {
      return _buildSearchResultsSlivers(
        context,
        notifier.searchEmojisForCurrentPath(),
      );
    }

    final (:subCategoryNames, :emojis) = notifier.getSubItemsForCurrentPath();
    if (subCategoryNames.isEmpty && emojis.isEmpty) {
      return [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text('このカテゴリに表示できるリアクションがありません'),
          ),
        ),
      ];
    }

    return [
      if (subCategoryNames.isNotEmpty)
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final subCatName = subCategoryNames[index];
            return ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Text(subCatName),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  onCategorySelected([...notifier.categoryPath, subCatName]),
            );
          }, childCount: subCategoryNames.length),
        ),
      if (emojis.isNotEmpty)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              childAspectRatio: 1,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = emojis[index];
              return CustomEmojiCell(
                name: item.name,
                url: item.url,
                onTap: () => onSelected(':${item.name}:'),
              );
            }, childCount: emojis.length),
          ),
        ),
    ];
  }

  List<Widget> _buildTopLevelSlivers(
    BuildContext context,
    ReactionPickerProvider notifier,
    void Function(List<String>) onCategorySelected,
  ) {
    if (notifier.query.isNotEmpty) {
      return _buildSearchResultsSlivers(
        context,
        notifier.searchEmojisForCurrentPath(),
      );
    }

    final categories = notifier.topLevelCategories;
    if (categories.isEmpty) {
      return [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text('表示できるリアクションがありません'),
          ),
        ),
      ];
    }

    return [
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final entry = categories[index];
          return ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(entry.key),
            subtitle: Text('${entry.value} 件'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onCategorySelected([entry.key]),
          );
        }, childCount: categories.length),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),
    ];
  }
}
