import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import 'custom_emoji_item.dart';
import 'emoji_cells.dart';
import 'pinned_sheet_header.dart';
import 'reaction_picker_provider.dart';
import 'search_result_tile.dart';

/// カテゴリの代表アイコンをを表示。URLがなければデフォルトアイコンを表示。
class _CategoryRepresentativeIcon extends StatelessWidget {
  const _CategoryRepresentativeIcon({
    required this.iconUrl,
    this.size = 24,
  });

  final String? iconUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (iconUrl == null || iconUrl!.isEmpty) {
      return Icon(Icons.emoji_emotions, size: size);
    }

    return SizedBox(
      width: size,
      height: size,
      child: CachedNetworkImage(
        imageUrl: iconUrl!,
        fit: BoxFit.contain,
        placeholder: (context, url) => Center(
          child: SizedBox.square(
            dimension: size * 0.5,
            child: const CircularProgressIndicator(strokeWidth: 1),
          ),
        ),
        errorWidget: (context, url, error) => Icon(Icons.emoji_emotions, size: size),
      ),
    );
  }
}

bool _useInitialSheetAnimationDone(ReactionPickerProvider notifier) {
  final isInitialSheetAnimationDone = useState(false);

  useEffect(
    () {
      const initialSheetAnimationDuration = Duration(milliseconds: 300);
      final timer = Timer(initialSheetAnimationDuration, () {
        isInitialSheetAnimationDone.value = true;
        unawaited(notifier.ensureInitialCategoriesLoaded());
      });
      return timer.cancel;
    },
    [isInitialSheetAnimationDone, notifier],
  );

  return isInitialSheetAnimationDone.value;
}

ValueNotifier<bool> _useForceSearchExpanded({
  required ReactionPickerProvider notifier,
  required FocusNode searchFocusNode,
  required DraggableScrollableController sheetController,
  required VoidCallback scrollToTopAfterBuild,
}) {
  final forceSearchExpanded = useState(false);
  final wasSearchFocused = useState(false);

  useEffect(
    () {
      void onFocusChanged() {
        final focused = searchFocusNode.hasFocus;
        if (focused == wasSearchFocused.value) return;
        wasSearchFocused.value = focused;
        if (!focused) {
          if (notifier.query.isEmpty) {
            forceSearchExpanded.value = false;
          }
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
          scrollToTopAfterBuild();
        });
      }

      searchFocusNode.addListener(onFocusChanged);
      return () => searchFocusNode.removeListener(onFocusChanged);
    },
    [
      notifier,
      searchFocusNode,
      sheetController,
      wasSearchFocused,
      forceSearchExpanded,
    ],
  );

  return forceSearchExpanded;
}

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
    useListenable(searchFocusNode);
    final sheetController = useMemoized(DraggableScrollableController.new);
    final latestScrollController = useRef<ScrollController?>(null);
    final wasAtMinExtent = useRef(false);
    final colorScheme = Theme.of(context).colorScheme;

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
    final forceSearchExpanded = _useForceSearchExpanded(
      notifier: notifier,
      searchFocusNode: searchFocusNode,
      sheetController: sheetController,
      scrollToTopAfterBuild: scrollToTopAfterBuild,
    );
    final isInitialSheetAnimationDone = _useInitialSheetAnimationDone(notifier);
    final isSearchExpanded =
        forceSearchExpanded.value ||
        searchFocusNode.hasFocus ||
        notifier.query.isNotEmpty;

    return PopScope(
      canPop: notifier.categoryPath.isEmpty,
      onPopInvokedWithResult: (_, _) {
        if (notifier.categoryPath.isNotEmpty) handleBackToParentCategory();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
          final minSheetSize = 1 / 3;
          const minExtentEpsilon = 0.005;
          final rawSnapSizes = <double>[0, minSheetSize, 1.0]..sort();
          final snapSizes = <double>[];
          for (final size in rawSnapSizes) {
            if (snapSizes.isEmpty || (size - snapSizes.last).abs() > 0.0001) {
              snapSizes.add(size);
            }
          }

          bool isAtMinExtent(double extent) =>
              (extent - minSheetSize).abs() <= minExtentEpsilon;

          return NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              if (notification.depth != 0) return false;

              final extent = notification.extent;

              final atMinExtent = isAtMinExtent(extent);

              // ヘッダーサイズに到達したときだけキーボードを閉じる
              if (atMinExtent && !wasAtMinExtent.value) {
                searchFocusNode.unfocus();
              }

              wasAtMinExtent.value = atMinExtent;

              return false;
            },
            child: DraggableScrollableSheet(
              controller: sheetController,
              initialChildSize: minSheetSize,
              minChildSize: 0,
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
                      isSearchExpanded: isSearchExpanded,
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
                              if (!searchFocusNode.hasFocus) {
                                forceSearchExpanded.value = false;
                              }
                            },
                      onSearchPressed: () {
                        forceSearchExpanded.value = true;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          searchFocusNode.requestFocus();
                        });
                      },
                      onSearchBackPressed: () {
                        searchFocusNode.unfocus();
                        searchController.clear();
                        notifier.clearQuery();
                        forceSearchExpanded.value = false;
                      },
                      onClose: () => Navigator.of(context).pop(),
                      onQueryChanged: notifier.updateQuery,
                    ),
                  ),
                ];

                final bodySlivers = <Widget>[];
                final shouldShowLoadingSlivers =
                    !isInitialSheetAnimationDone || notifier.isLoading;
                bodySlivers.addAll(_buildFrequentSectionSlivers(context, notifier));
                bodySlivers.addAll(
                  _buildCustomEmojiSectionSlivers(
                    context,
                    notifier,
                    shouldShowLoadingSlivers,
                    handleCategorySelected,
                  ),
                );
                bodySlivers.add(_buildBottomInsetSliver(context, keyboardInset));

                slivers.addAll(bodySlivers);

                return CustomScrollView(
                  controller: scrollController,
                  slivers: slivers,
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ── Sliver builders ────────────────────────────────────────────────────────

  List<Widget> _buildFrequentSectionSlivers(
    BuildContext context,
    ReactionPickerProvider notifier,
  ) {
    if (notifier.categoryPath.isNotEmpty || notifier.query.isNotEmpty) {
      return const [];
    }

    final slivers = <Widget>[
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Text(
            'よく使う絵文字',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ),
    ];

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
      return slivers;
    }

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
            return EmojiCell(emoji: emoji, onTap: () => onSelected(emoji));
          }, childCount: frequent.length),
        ),
      ),
    );
    return slivers;
  }

  List<Widget> _buildCustomEmojiSectionSlivers(
    BuildContext context,
    ReactionPickerProvider notifier,
    bool shouldShowLoadingSlivers,
    void Function(List<String>) onCategorySelected,
  ) {
    if (shouldShowLoadingSlivers) {
      return _buildTopLevelLoadingSlivers(context);
    }

    if (notifier.loadError != null) {
      return const [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text('リアクション一覧の読み込みに失敗しました'),
          ),
        ),
      ];
    }

    if (notifier.categoryPath.isNotEmpty) {
      return _buildCategoryDetailSlivers(context, notifier, onCategorySelected);
    }

    return _buildTopLevelSlivers(context, notifier, onCategorySelected);
  }

  Widget _buildBottomInsetSliver(BuildContext context, double keyboardInset) {
    final bottomPadding = keyboardInset > 0
        ? keyboardInset
        : MediaQuery.viewPaddingOf(context).bottom;
    return SliverToBoxAdapter(child: SizedBox(height: bottomPadding));
  }

  List<Widget> _buildTopLevelLoadingSlivers(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final placeholderColor = colorScheme.onSurface.withValues(alpha: 0.12);

    return [
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final titleWidthFactor = 0.4 + (index % 4) * 0.1;
          return ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: titleWidthFactor,
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: placeholderColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: 0.18,
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: placeholderColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
            trailing: Icon(Icons.chevron_right, color: placeholderColor),
          );
        }, childCount: 12),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),
    ];
  }

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
            final nextPath = [...notifier.categoryPath, subCatName];
            final categoryPathKey = nextPath.join('/');
            final representativeUrl =
                notifier.getRepresentativeEmojiUrlForCategory(categoryPathKey);
            return Column(
              children: [
                ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Text(subCatName),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: _CategoryRepresentativeIcon(
                          iconUrl: representativeUrl,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () => onCategorySelected(nextPath),
                ),
                const Divider(height: 1),
              ],
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
          final representativeUrl =
              notifier.getRepresentativeEmojiUrlByTopCategory(entry.key);
          return ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(entry.key),
            subtitle: Text('${entry.value} 件'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: _CategoryRepresentativeIcon(
                    iconUrl: representativeUrl,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () => onCategorySelected([entry.key]),
          );
        }, childCount: categories.length),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),
    ];
  }
}
