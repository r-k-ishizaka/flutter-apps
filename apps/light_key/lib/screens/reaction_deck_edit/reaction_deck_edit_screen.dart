import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../sheets/reaction_picker/emoji_cells.dart';
import 'reaction_deck_edit_provider.dart';
import 'reaction_deck_edit_screen_state.dart';

class ReactionDeckEditScreen extends HookWidget {
  const ReactionDeckEditScreen({super.key});

  static const int _deckMaxItems = 32;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReactionDeckEditProvider>();
    final state = provider.state;

    final nameController = useTextEditingController(text: state.deckName);
    final searchController = useTextEditingController(text: state.query);

    useEffect(() {
      if (nameController.text == state.deckName) {
        return null;
      }
      nameController
        ..text = state.deckName
        ..selection = TextSelection.collapsed(offset: state.deckName.length);
      return null;
    }, [state.deckName]);

    useEffect(() {
      if (searchController.text == state.query) {
        return null;
      }
      searchController
        ..text = state.query
        ..selection = TextSelection.collapsed(offset: state.query.length);
      return null;
    }, [state.query]);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('リアクションデッキ編集'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'デッキ内容'),
              Tab(text: '絵文字を追加'),
            ],
          ),
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: SegmentedButton<int>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment<int>(value: 1, label: Text('デッキ1')),
                        ButtonSegment<int>(value: 2, label: Text('デッキ2')),
                        ButtonSegment<int>(value: 3, label: Text('デッキ3')),
                        ButtonSegment<int>(value: 4, label: Text('デッキ4')),
                      ],
                      selected: <int>{state.selectedDeckId},
                      onSelectionChanged: (selection) {
                        final deckId = selection.firstOrNull;
                        if (deckId != null) {
                          provider.selectDeck(deckId);
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'デッキ名',
                              hintText: '未設定の場合はデフォルト名',
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted: provider.renameSelectedDeck,
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: () => unawaited(
                            provider.renameSelectedDeck(nameController.text),
                          ),
                          icon: const Icon(Icons.save),
                          label: const Text('保存'),
                        ),
                      ],
                    ),
                  ),
                  if (state.message != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Material(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                        child: ListTile(
                          dense: true,
                          title: Text(state.message!),
                          trailing: IconButton(
                            onPressed: provider.clearMessage,
                            icon: const Icon(Icons.close),
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _DeckItemsTab(
                          deckEmojis: state.deckEmojis,
                          onReorder: provider.reorderEmoji,
                          onRemove: provider.removeEmojiAt,
                          customEmojiUrlOf: provider.getCustomEmojiUrl,
                          customEmojiNameOf: provider.getCustomEmojiName,
                        ),
                        _AddEmojiTab(
                          queryController: searchController,
                          filteredCandidates: state.filteredCandidates,
                          candidatesByCategory: state.candidatesByCategory,
                          sortedCategoryNames: state.sortedCategoryNames,
                          deckItemCount: state.deckEmojis.length,
                          isSearching: state.query.isNotEmpty,
                          onQueryChanged: provider.updateQuery,
                          onAddEmoji: provider.addEmojiToSelectedDeck,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _DeckItemsTab extends StatelessWidget {
  const _DeckItemsTab({
    required this.deckEmojis,
    required this.onReorder,
    required this.onRemove,
    required this.customEmojiUrlOf,
    required this.customEmojiNameOf,
  });

  final List<String> deckEmojis;
  final Future<void> Function(int oldIndex, int newIndex) onReorder;
  final Future<void> Function(int index) onRemove;
  final String? Function(String emoji) customEmojiUrlOf;
  final String? Function(String emoji) customEmojiNameOf;

  @override
  Widget build(BuildContext context) {
    if (deckEmojis.isEmpty) {
      return const Center(child: Text('デッキに絵文字がありません。追加タブから登録してください。'));
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: deckEmojis.length,
      onReorder: (oldIndex, newIndex) => unawaited(onReorder(oldIndex, newIndex)),
      itemBuilder: (context, index) {
        final emoji = deckEmojis[index];
        final customUrl = customEmojiUrlOf(emoji);
        final customName = customEmojiNameOf(emoji);

        return ListTile(
          key: ValueKey('$emoji-$index'),
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: SizedBox(
            width: 36,
            height: 36,
            child: customUrl != null && customUrl.isNotEmpty
                ? CustomEmojiCell(name: customName ?? emoji, url: customUrl, onTap: () {})
                : Center(
                    child: Text(
                      customName != null ? ':$customName:' : emoji,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
          ),
          title: Text(customName != null ? ':$customName:' : emoji),
          subtitle: Text('${index + 1} / 32'),
          trailing: IconButton(
            onPressed: () => unawaited(onRemove(index)),
            icon: const Icon(Icons.delete_outline),
            tooltip: '削除',
          ),
        );
      },
    );
  }
}

class _AddEmojiTab extends HookWidget {
  const _AddEmojiTab({
    required this.queryController,
    required this.filteredCandidates,
    required this.candidatesByCategory,
    required this.sortedCategoryNames,
    required this.deckItemCount,
    required this.isSearching,
    required this.onQueryChanged,
    required this.onAddEmoji,
  });

  final TextEditingController queryController;
  final List<ReactionDeckCandidateEmoji> filteredCandidates;
  final Map<String, List<ReactionDeckCandidateEmoji>> candidatesByCategory;
  final List<String> sortedCategoryNames;
  final int deckItemCount;
  final bool isSearching;
  final ValueChanged<String> onQueryChanged;
  final Future<void> Function(String emoji) onAddEmoji;

  @override
  Widget build(BuildContext context) {
    final selectedCategory = useState<String?>(null);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: queryController,
            decoration: const InputDecoration(
              labelText: '追加する絵文字を検索',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: onQueryChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('登録数 $deckItemCount / ${ReactionDeckEditScreen._deckMaxItems}'),
          ),
        ),
        if (!isSearching && selectedCategory.value != null)
          _CategoryHeader(
            categoryName: selectedCategory.value!,
            onBack: () => selectedCategory.value = null,
          ),
        Expanded(
          child: _buildBody(context, selectedCategory),
        ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    ValueNotifier<String?> selectedCategory,
  ) {
    // 検索中: フラットな検索結果グリッド
    if (isSearching) {
      if (filteredCandidates.isEmpty) {
        return const Center(child: Text('一致する絵文字がありません。'));
      }
      return _EmojiGrid(
        emojis: filteredCandidates,
        onAddEmoji: onAddEmoji,
      );
    }

    // カテゴリ選択済み: そのカテゴリの絵文字グリッド
    final category = selectedCategory.value;
    if (category != null) {
      final emojis = candidatesByCategory[category] ?? const [];
      if (emojis.isEmpty) {
        return const Center(child: Text('このカテゴリに絵文字がありません。'));
      }
      return _EmojiGrid(
        emojis: emojis,
        onAddEmoji: onAddEmoji,
      );
    }

    // カテゴリ一覧
    if (sortedCategoryNames.isEmpty) {
      return const Center(child: Text('表示できる絵文字がありません。'));
    }
    return ListView.separated(
      itemCount: sortedCategoryNames.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final name = sortedCategoryNames[index];
        final count = candidatesByCategory[name]?.length ?? 0;
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text(name),
          subtitle: Text('$count 件'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => selectedCategory.value = name,
        );
      },
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.categoryName, required this.onBack});

  final String categoryName;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'カテゴリ一覧に戻る',
          onPressed: onBack,
        ),
        Expanded(
          child: Text(
            categoryName,
            style: Theme.of(context).textTheme.titleSmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _EmojiGrid extends StatelessWidget {
  const _EmojiGrid({required this.emojis, required this.onAddEmoji});

  final List<ReactionDeckCandidateEmoji> emojis;
  final Future<void> Function(String emoji) onAddEmoji;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        childAspectRatio: 1,
      ),
      itemCount: emojis.length,
      itemBuilder: (context, index) {
        final item = emojis[index];
        return CustomEmojiCell(
          name: item.name,
          url: item.url,
          onTap: () => unawaited(onAddEmoji(':${item.name}:')),
        );
      },
    );
  }
}
