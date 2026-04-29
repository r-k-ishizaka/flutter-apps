import 'package:flutter/material.dart';

/// シート上部に固定表示されるヘッダー（タイトル行＋検索バー）。
class PinnedSheetHeaderDelegate extends SliverPersistentHeaderDelegate {
  const PinnedSheetHeaderDelegate({
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
              const Center(child: SheetDragHandle()),
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
  bool shouldRebuild(covariant PinnedSheetHeaderDelegate old) {
    return colorScheme != old.colorScheme ||
        categoryPath != old.categoryPath ||
        query != old.query ||
        searchController != old.searchController ||
        searchFocusNode != old.searchFocusNode ||
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
