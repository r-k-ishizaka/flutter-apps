import 'package:flutter/material.dart';

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
class ReactionPickerSheet extends StatefulWidget {
  const ReactionPickerSheet({required this.onSelected, super.key});

  final ValueChanged<String> onSelected;

  @override
  State<ReactionPickerSheet> createState() => _ReactionPickerSheetState();
}

class _ReactionPickerSheetState extends State<ReactionPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filtered {
    if (_query.isEmpty) return _kFrequentReactions;
    return _kFrequentReactions
        .where((e) => e.contains(_query))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Text(
                      'リアクションを選択',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: '閉じる',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: SearchBar(
                  controller: _searchController,
                  hintText: '絵文字を検索',
                  leading: const Icon(Icons.search),
                  trailing: [
                    if (_query.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                  ],
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
            ),
            if (_filtered.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('該当する絵文字がありません')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    childAspectRatio: 1,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final emoji = _filtered[index];
                    return _EmojiCell(
                      emoji: emoji,
                      onTap: () => widget.onSelected(emoji),
                    );
                  }, childCount: _filtered.length),
                ),
              ),
          ],
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

/// リアクション選択ボトムシートを表示するユーティリティ関数。
///
/// ユーザーが絵文字を選択した場合はその文字列が返り、
/// キャンセルした場合は `null` が返る。
Future<String?> showReactionPickerSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => ReactionPickerSheet(
      onSelected: (emoji) => Navigator.of(context).pop(emoji),
    ),
  );
}
