import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../models/note.dart';
import 'new_notes_banner.dart';
import 'timeline_note_item.dart';

class TimelineList extends HookWidget {
  const TimelineList({
    required this.notes,
    this.isRefreshing = false,
    this.message,
    this.onRefresh,
    this.onNoteReply,
    this.onNoteRenote,
    this.onNoteReaction,
    this.onNoteReactionChipTap,
    super.key,
  });

  final List<Note> notes;
  final bool isRefreshing;
  final String? message;
  final Future<void> Function()? onRefresh;
  final void Function(Note note)? onNoteReply;
  final void Function(Note note)? onNoteRenote;
  final void Function(Note note)? onNoteReaction;
  final void Function(Note note, String reaction)? onNoteReactionChipTap;

  @override
  Widget build(BuildContext context) {
    final listKey = useMemoized(() => GlobalKey<AnimatedListState>());
    final scrollController = useScrollController();
    final visibleNotes = useState<List<Note>>(List<Note>.from(notes));
    final isFirstSync = useRef(true);
    final pendingNotes = useRef<List<Note>>([]);
    final isAtTop = useState(true);
    final localRefreshing = useState(false);

    Future<void> handleRefresh() async {
      final refresh = onRefresh;
      if (refresh == null) return;

      localRefreshing.value = true;
      try {
        await refresh();
      } finally {
        localRefreshing.value = false;
      }
    }

    final shouldDim = isRefreshing || localRefreshing.value;

    useEffect(() {
      void listener() {
        final atTop = scrollController.offset == 0;
        isAtTop.value = atTop;

        if (atTop && pendingNotes.value.isNotEmpty) {
          _applyNoteUpdates(listKey, visibleNotes, pendingNotes.value);
          pendingNotes.value = [];
        }
      }

      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, []);

    useEffect(() {
      if (isFirstSync.value) {
        isFirstSync.value = false;
        return null;
      }

      if (isAtTop.value) {
        _applyNoteUpdates(listKey, visibleNotes, notes);
        pendingNotes.value = [];
      } else {
        _applyExistingNoteUpdates(visibleNotes, notes);
        final currentIds = visibleNotes.value.map((note) => note.id).toSet();
        final newNoteCount = notes
            .where((note) => !currentIds.contains(note.id))
            .length;

        if (newNoteCount > 0) {
          pendingNotes.value = List<Note>.from(notes);
        }
      }

      return null;
    }, [notes]);

    if (visibleNotes.value.isEmpty) {
      if (onRefresh == null) {
        return Center(child: Text(message ?? '投稿がありません。認証後に再取得してください。'));
      }

      return RefreshIndicator(
        onRefresh: handleRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Text(message ?? '投稿がありません。認証後に再取得してください。'),
                ),
              ),
            );
          },
        ),
      );
    }

    final content = Stack(
      children: [
        AnimatedOpacity(
          opacity: shouldDim ? 0.4 : 1.0,
          duration: shouldDim
              ? Duration.zero
              : const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: AnimatedList(
            key: listKey,
            controller: scrollController,
            initialItemCount: visibleNotes.value.length,
            itemBuilder: (context, index, animation) {
              final note = visibleNotes.value[index];
              return TimelineNoteItem(
                note: note,
                animation: animation,
                onReply: onNoteReply != null ? () => onNoteReply!(note) : null,
                onRenote: onNoteRenote != null
                    ? () => onNoteRenote!(note)
                    : null,
                onReaction: onNoteReaction != null
                    ? () => onNoteReaction!(note)
                    : null,
                onReactionChipTap: onNoteReactionChipTap != null
                    ? (reaction) => onNoteReactionChipTap!(note, reaction)
                    : null,
              );
            },
          ),
        ),
        if (pendingNotes.value.isNotEmpty)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: NewNotesBanner(
              onTap: () {
                // タップ時点でノートをキャプチャし、即座にクリアする。
                // スクロールリスナーが offset==0 で同じ pendingNotes を処理する
                // 競合を防ぐため、先にクリアして二重適用を回避する。
                final captured = List<Note>.from(pendingNotes.value);
                pendingNotes.value = [];
                scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
                Future.delayed(const Duration(milliseconds: 300), () {
                  _applyNoteUpdates(listKey, visibleNotes, captured);
                });
              },
            ),
          ),
      ],
    );

    if (onRefresh == null) {
      return content;
    }

    return RefreshIndicator(onRefresh: handleRefresh, child: content);
  }

  static void _applyNoteUpdates(
    GlobalKey<AnimatedListState> listKey,
    ValueNotifier<List<Note>> visibleNotes,
    List<Note> nextNotes,
  ) {
    final nextIds = nextNotes.map((note) => note.id).toSet();
    final current = List<Note>.from(visibleNotes.value);

    for (var i = nextNotes.length - 1; i >= 0; i--) {
      final note = nextNotes[i];
      final currentIndex = current.indexWhere((n) => n.id == note.id);
      if (currentIndex == -1) {
        final insertIndex = i.clamp(0, current.length);
        current.insert(insertIndex, note);
        listKey.currentState?.insertItem(
          insertIndex,
          duration: const Duration(milliseconds: 280),
        );
      } else {
        current[currentIndex] = note;
      }
    }

    for (var i = current.length - 1; i >= 0; i--) {
      final note = current[i];
      if (nextIds.contains(note.id)) {
        continue;
      }

      final removed = current.removeAt(i);
      listKey.currentState?.removeItem(
        i,
        (context, animation) =>
            TimelineNoteItem(note: removed, animation: animation),
        duration: const Duration(milliseconds: 180),
      );
    }

    visibleNotes.value = List<Note>.unmodifiable(current);
  }

  static void _applyExistingNoteUpdates(
    ValueNotifier<List<Note>> visibleNotes,
    List<Note> nextNotes,
  ) {
    final nextById = {for (final note in nextNotes) note.id: note};
    final current = visibleNotes.value;
    var hasChanged = false;

    final updated = current
        .map((note) {
          final next = nextById[note.id];
          if (next == null) {
            return note;
          }
          if (identical(next, note) || next == note) {
            return note;
          }
          hasChanged = true;
          return next;
        })
        .toList(growable: false);

    if (hasChanged) {
      visibleNotes.value = List<Note>.unmodifiable(updated);
    }
  }
}
