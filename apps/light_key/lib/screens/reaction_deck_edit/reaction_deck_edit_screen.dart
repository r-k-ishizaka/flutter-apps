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

  Future<bool> _confirmLeave(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('未保存の変更があります'),
        content: const Text('変更を破棄して戻りますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('破棄して戻る'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReactionDeckEditProvider>();
    final state = provider.state;
    final colorScheme = Theme.of(context).colorScheme;
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    final tabController = useTabController(initialLength: 2);
    useListenable(tabController);
    final isBackDialogOpen = useState(false);
    final isDraggingDeckItem = useState(false);

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

    useEffect(() {
      final message = state.message;
      if (message == null) {
        return null;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          return;
        }
        scaffoldMessenger
          ?..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
        provider.clearMessage();
      });
      return null;
    }, [state.message, scaffoldMessenger]);

    return PopScope(
      canPop: !state.hasUnsavedDeckChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || isBackDialogOpen.value) {
          return;
        }

        isBackDialogOpen.value = true;
        final shouldLeave = await _confirmLeave(context);
        isBackDialogOpen.value = false;

        if (!context.mounted || !shouldLeave) {
          return;
        }
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('リアクションデッキ編集'),
          bottom: TabBar(
            controller: tabController,
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
                  Expanded(
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        _DeckItemsTab(
                          deckEmojis: state.deckEmojis,
                          onReorder: provider.reorderEmoji,
                          onRemove: provider.removeEmojiAt,
                          customEmojiUrlOf: provider.getCustomEmojiUrl,
                          customEmojiNameOf: provider.getCustomEmojiName,
                          onDraggingChanged: (isDragging) {
                            if (isDraggingDeckItem.value == isDragging) {
                              return;
                            }
                            isDraggingDeckItem.value = isDragging;
                          },
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
        floatingActionButton:
            state.isLoading ||
                tabController.index != 0 ||
                isDraggingDeckItem.value
            ? null
            : FloatingActionButton.extended(
                onPressed: state.hasUnsavedDeckChanges
                    ? () => unawaited(provider.saveSelectedDeck())
                    : null,
                backgroundColor: state.hasUnsavedDeckChanges
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
                foregroundColor: state.hasUnsavedDeckChanges
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                icon: const Icon(Icons.save),
                label: const Text('デッキ保存'),
              ),
      ),
    );
  }
}

class _DeckItemsTab extends HookWidget {
  const _DeckItemsTab({
    required this.deckEmojis,
    required this.onReorder,
    required this.onRemove,
    required this.customEmojiUrlOf,
    required this.customEmojiNameOf,
    required this.onDraggingChanged,
  });

  final List<String> deckEmojis;
  final Future<void> Function(int oldIndex, int newIndex) onReorder;
  final Future<void> Function(int index) onRemove;
  final String? Function(String emoji) customEmojiUrlOf;
  final String? Function(String emoji) customEmojiNameOf;
  final ValueChanged<bool> onDraggingChanged;

  static const int _crossAxisCount = 8;
  static const double _insertAfterThreshold = 0.66;

  List<_DeckGridCell> _buildPreviewCells({
    required List<String> emojis,
    required int draggingFromIndex,
    required int placeholderIndex,
  }) {
    final base = <_DeckGridItem>[];
    for (var i = 0; i < emojis.length; i++) {
      if (i == draggingFromIndex) {
        continue;
      }
      base.add(_DeckGridItem(originalIndex: i, emoji: emojis[i]));
    }

    final normalizedPlaceholder = placeholderIndex.clamp(0, base.length);
    final cells = <_DeckGridCell>[];
    for (var i = 0; i <= base.length; i++) {
      if (i == normalizedPlaceholder) {
        cells.add(_DeckGridCell.placeholder(insertIndex: i));
      }
      if (i < base.length) {
        cells.add(_DeckGridCell.item(baseIndex: i, item: base[i]));
      }
    }
    return cells;
  }

  int _resolveInsertIndexFromTarget(
    BuildContext context,
    DragTargetDetails<_DraggingDeckEmoji> details,
    int baseIndex,
  ) {
    final renderObject = context.findRenderObject();
    final box = renderObject is RenderBox ? renderObject : null;
    if (box == null || !box.hasSize) {
      return baseIndex;
    }

    final local = box.globalToLocal(details.offset);
    final normalizedX = (local.dx / box.size.width).clamp(0.0, 1.0);
    final insertAfter = normalizedX >= _insertAfterThreshold;
    return baseIndex + (insertAfter ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    final draggingFromIndex = useState<int?>(null);
    final placeholderIndex = useState<int?>(null);
    final isOverDeleteZone = useState(false);

    final currentDraggingIndex = draggingFromIndex.value;
    final currentPlaceholderIndex = placeholderIndex.value;
    final isDragging =
        currentDraggingIndex != null && currentPlaceholderIndex != null;

    final previewCells = isDragging
        ? _buildPreviewCells(
            emojis: deckEmojis,
            draggingFromIndex: currentDraggingIndex,
            placeholderIndex: currentPlaceholderIndex,
          )
        : List<_DeckGridCell>.generate(
            deckEmojis.length,
            (index) => _DeckGridCell.item(
              baseIndex: index,
              item: _DeckGridItem(
                originalIndex: index,
                emoji: deckEmojis[index],
              ),
            ),
            growable: false,
          );

    Future<void> commitReorder(
      _DraggingDeckEmoji dragging,
      int destination,
    ) async {
      final from = dragging.originalIndex;
      if (from == destination) {
        return;
      }

      await onReorder(from, destination);
    }

    void clearDraggingState() {
      draggingFromIndex.value = null;
      placeholderIndex.value = null;
      isOverDeleteZone.value = false;
      onDraggingChanged(false);
    }

    if (deckEmojis.isEmpty) {
      return const Center(child: Text('デッキに絵文字がありません。追加タブから登録してください。'));
    }

    return Stack(
      children: [
        GridView.builder(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 84),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _crossAxisCount,
            childAspectRatio: 1,
          ),
          itemCount: previewCells.length + (isDragging ? 1 : 0),
          itemBuilder: (context, index) {
            if (isDragging && index == previewCells.length) {
              final endDestination = deckEmojis.length - 1;
              return DragTarget<_DraggingDeckEmoji>(
                key: const ValueKey('deck-end-drop-target'),
                onWillAcceptWithDetails: (_) => true,
                onMove: (_) {
                  placeholderIndex.value = endDestination;
                },
                onAcceptWithDetails: (details) {
                  if (details.data.originalIndex != endDestination) {
                    unawaited(commitReorder(details.data, endDestination));
                  }
                  clearDraggingState();
                },
                builder: (context, candidateData, _) => _DeckEndDropTargetCell(
                  isActive: candidateData.isNotEmpty,
                ),
              );
            }

            final cell = previewCells[index];
            if (cell.isPlaceholder) {
              final insertIndex = cell.insertIndex;
              if (insertIndex == null) {
                return const SizedBox.shrink();
              }
              return KeyedSubtree(
                key: ValueKey('deck-placeholder-${cell.insertIndex}'),
                child: DragTarget<_DraggingDeckEmoji>(
                  onWillAcceptWithDetails: (_) => true,
                  onAcceptWithDetails: (details) {
                    final from = details.data.originalIndex;
                    if (from != insertIndex) {
                      unawaited(commitReorder(details.data, insertIndex));
                    }
                    clearDraggingState();
                  },
                  builder: (context, _, __) => const _DeckPlaceholderCell(),
                ),
              );
            }

            final item = cell.item;
            final baseIndex = cell.baseIndex;
            if (item == null || baseIndex == null) {
              return const SizedBox.shrink();
            }

            final customUrl = customEmojiUrlOf(item.emoji);
            final customName = customEmojiNameOf(item.emoji);

            return DragTarget<_DraggingDeckEmoji>(
              key: ValueKey('deck-item-${item.originalIndex}'),
              onWillAcceptWithDetails: (_) => true,
              onMove: (details) {
                placeholderIndex.value = _resolveInsertIndexFromTarget(
                  context,
                  details,
                  baseIndex,
                );
              },
              onAcceptWithDetails: (details) {
                final destination = _resolveInsertIndexFromTarget(
                  context,
                  details,
                  baseIndex,
                );
                unawaited(commitReorder(details.data, destination));
                clearDraggingState();
              },
              builder: (context, _, __) =>
                  LongPressDraggable<_DraggingDeckEmoji>(
                    key: ValueKey('deck-draggable-${item.originalIndex}'),
                    data: _DraggingDeckEmoji(
                      originalIndex: item.originalIndex,
                      emoji: item.emoji,
                    ),
                    delay: const Duration(milliseconds: 220),
                    feedback: SizedBox(
                      width: 52,
                      height: 52,
                      child: Material(
                        color: Colors.transparent,
                        child: _DeckEmojiChip(
                          emoji: item.emoji,
                          customUrl: customUrl,
                          customName: customName,
                          isDragging: true,
                        ),
                      ),
                    ),
                    childWhenDragging: const SizedBox.shrink(),
                    onDragStarted: () {
                      draggingFromIndex.value = item.originalIndex;
                      placeholderIndex.value = item.originalIndex;
                      isOverDeleteZone.value = false;
                      onDraggingChanged(true);
                    },
                    onDraggableCanceled: (_, __) {
                      clearDraggingState();
                    },
                    onDragEnd: (_) {
                      // 絵文字のない場所/グリッド外で離した場合も含めて必ず空欄を戻す。
                      clearDraggingState();
                    },
                    child: _DeckEmojiChip(
                      emoji: item.emoji,
                      customUrl: customUrl,
                      customName: customName,
                      isDragging: false,
                    ),
                  ),
            );
          },
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: IgnorePointer(
            ignoring: !isDragging,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 160),
              offset: isDragging ? Offset.zero : const Offset(0, 1),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 140),
                opacity: isDragging ? 1 : 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: DragTarget<_DraggingDeckEmoji>(
                    onWillAcceptWithDetails: (_) {
                      isOverDeleteZone.value = true;
                      return true;
                    },
                    onLeave: (_) => isOverDeleteZone.value = false,
                    onAcceptWithDetails: (details) {
                      unawaited(onRemove(details.data.originalIndex));
                      clearDraggingState();
                    },
                    builder: (context, _, __) {
                      final colorScheme = Theme.of(context).colorScheme;
                      final isActive = isOverDeleteZone.value;
                      return Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: isActive
                              ? colorScheme.errorContainer
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive
                                ? colorScheme.error
                                : colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: isActive
                                  ? colorScheme.onErrorContainer
                                  : colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ここに重ねて削除',
                              style: TextStyle(
                                color: isActive
                                    ? colorScheme.onErrorContainer
                                    : colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DraggingDeckEmoji {
  const _DraggingDeckEmoji({required this.originalIndex, required this.emoji});

  final int originalIndex;
  final String emoji;
}

class _DeckGridItem {
  const _DeckGridItem({required this.originalIndex, required this.emoji});

  final int originalIndex;
  final String emoji;
}

class _DeckGridCell {
  const _DeckGridCell.item({required this.baseIndex, required this.item})
    : isPlaceholder = false,
      insertIndex = null;

  const _DeckGridCell.placeholder({required this.insertIndex})
    : isPlaceholder = true,
      baseIndex = null,
      item = null;

  final bool isPlaceholder;
  final int? baseIndex;
  final _DeckGridItem? item;
  final int? insertIndex;
}

class _DeckPlaceholderCell extends StatelessWidget {
  const _DeckPlaceholderCell();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.35),
            width: 1.1,
          ),
        ),
      ),
    );
  }
}

class _DeckEndDropTargetCell extends StatelessWidget {
  const _DeckEndDropTargetCell({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isActive
              ? colorScheme.secondaryContainer
              : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? colorScheme.secondary : colorScheme.outlineVariant,
            width: 1.1,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.keyboard_double_arrow_down,
            size: 18,
            color: isActive
                ? colorScheme.onSecondaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _DeckEmojiChip extends StatelessWidget {
  const _DeckEmojiChip({
    required this.emoji,
    required this.customUrl,
    required this.customName,
    required this.isDragging,
  });

  final String emoji;
  final String? customUrl;
  final String? customName;
  final bool isDragging;

  @override
  Widget build(BuildContext context) {
    final content = customUrl != null && customUrl!.isNotEmpty
        ? CustomEmojiCell(
            name: customName ?? emoji,
            url: customUrl!,
            onTap: () {},
          )
        : EmojiCell(emoji: emoji, onTap: () {});

    if (!isDragging) {
      return content;
    }

    return Opacity(
      opacity: 0.9,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: content,
      ),
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
            child: Text(
              '登録数 $deckItemCount / ${ReactionDeckEditScreen._deckMaxItems}',
            ),
          ),
        ),
        if (!isSearching && selectedCategory.value != null)
          _CategoryHeader(
            categoryName: selectedCategory.value!,
            onBack: () => selectedCategory.value = null,
          ),
        Expanded(child: _buildBody(context, selectedCategory)),
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
      return _EmojiGrid(emojis: filteredCandidates, onAddEmoji: onAddEmoji);
    }

    // カテゴリ選択済み: そのカテゴリの絵文字グリッド
    final category = selectedCategory.value;
    if (category != null) {
      final emojis = candidatesByCategory[category] ?? const [];
      if (emojis.isEmpty) {
        return const Center(child: Text('このカテゴリに絵文字がありません。'));
      }
      return _EmojiGrid(emojis: emojis, onAddEmoji: onAddEmoji);
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
