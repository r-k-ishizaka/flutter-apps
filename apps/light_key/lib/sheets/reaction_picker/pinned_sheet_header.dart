import 'package:flutter/material.dart';

/// シート上部に固定表示されるヘッダー（タイトル行＋検索バー）。
class PinnedSheetHeaderDelegate extends SliverPersistentHeaderDelegate {
  const PinnedSheetHeaderDelegate({
    required this.colorScheme,
    required this.categoryPath,
    required this.query,
    required this.isSearchExpanded,
    required this.searchController,
    required this.searchFocusNode,
    required this.onSearchPressed,
    required this.onSearchBackPressed,
    required this.onClose,
    required this.onQueryChanged,
    this.onBack,
    this.onClear,
  });

  final ColorScheme colorScheme;
  final List<String> categoryPath;
  final String query;
  final bool isSearchExpanded;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final VoidCallback onSearchPressed;
  final VoidCallback onSearchBackPressed;
  final VoidCallback? onBack;
  final VoidCallback? onClear;
  final VoidCallback onClose;
  final ValueChanged<String> onQueryChanged;

  // Padding 16 + handle 4 + gaps 16 + main row 48 + search row余白 8 = 84.
  static const double headerHeight = 84;

  @override
  double get minExtent => headerHeight;

  @override
  double get maxExtent => headerHeight;

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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(child: SheetDragHandle()),
              const SizedBox(height: 8),
              Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SizeTransition(
                          sizeFactor: animation,
                          axis: Axis.horizontal,
                          axisAlignment: -1,
                          child: child,
                        ),
                      );
                    },
                    child: (isSearchExpanded || onBack == null)
                        ? const SizedBox.shrink(key: ValueKey('left-hidden'))
                        : SizedBox(
                            key: const ValueKey('left-visible'),
                            width: 42,
                            child: IconButton(
                              key: const ValueKey('back-visible'),
                              style: IconButton.styleFrom(
                                minimumSize: const Size.square(42),
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: const Icon(Icons.arrow_back),
                              tooltip: 'カテゴリ一覧に戻る',
                              onPressed: onBack,
                            ),
                          ),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SizeTransition(
                            sizeFactor: animation,
                            axis: Axis.horizontal,
                            axisAlignment: -1,
                            child: child,
                          ),
                        );
                      },
                      child: isSearchExpanded
                          ? SizedBox(
                              key: const ValueKey('expanded-search-bar'),
                              height: 42,
                              child: SearchBar(
                                controller: searchController,
                                focusNode: searchFocusNode,
                                hintText: '絵文字を検索',
                                leading: IconButton(
                                  style: IconButton.styleFrom(
                                    minimumSize: const Size.square(32),
                                    padding: EdgeInsets.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  icon: const Icon(Icons.arrow_back),
                                  tooltip: '検索を閉じる',
                                  onPressed: onSearchBackPressed,
                                ),
                                trailing: [
                                  if (query.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: onClear,
                                    ),
                                ],
                                onChanged: onQueryChanged,
                              ),
                            )
                          : SizedBox(
                              key: const ValueKey('title-label'),
                              height: 42,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  categoryPath.isEmpty
                                      ? 'リアクションを選択'
                                      : categoryPath.join(' / '),
                                  style: Theme.of(context).textTheme.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SizeTransition(
                          sizeFactor: animation,
                          axis: Axis.horizontal,
                          axisAlignment: 1,
                          child: child,
                        ),
                      );
                    },
                    child: !isSearchExpanded
                        ? SizedBox(
                            key: const ValueKey('search-visible-wrap'),
                            width: 42,
                            child: IconButton(
                              key: const ValueKey('search-visible'),
                              style: IconButton.styleFrom(
                                minimumSize: const Size.square(42),
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: const Icon(Icons.search),
                              tooltip: '検索',
                              onPressed: onSearchPressed,
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey('search-hidden')),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SizeTransition(
                          sizeFactor: animation,
                          axis: Axis.horizontal,
                          axisAlignment: 1,
                          child: child,
                        ),
                      );
                    },
                    child: !isSearchExpanded
                        ? SizedBox(
                            key: const ValueKey('close-visible-wrap'),
                            width: 42,
                            child: IconButton(
                              key: const ValueKey('close-visible'),
                              style: IconButton.styleFrom(
                                minimumSize: const Size.square(42),
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: const Icon(Icons.close),
                              tooltip: '閉じる',
                              onPressed: onClose,
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey('close-hidden')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant PinnedSheetHeaderDelegate old) {
    return colorScheme != old.colorScheme ||
        categoryPath != old.categoryPath ||
        query != old.query ||
        isSearchExpanded != old.isSearchExpanded ||
        searchController != old.searchController ||
        searchFocusNode != old.searchFocusNode ||
        onSearchPressed != old.onSearchPressed ||
        onSearchBackPressed != old.onSearchBackPressed ||
        onBack != old.onBack ||
        onClear != old.onClear ||
        onClose != old.onClose ||
        onQueryChanged != old.onQueryChanged;
  }
}

/// ドラッグハンドルのインジケーター。
class SheetDragHandle extends StatelessWidget {
  const SheetDragHandle({super.key});

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
