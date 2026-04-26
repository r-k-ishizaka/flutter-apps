import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/note.dart';
import '../../route/app_routes.dart';
import 'timeline_provider.dart';
import 'timeline_screen_state.dart';

class TimelineScreen extends HookWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      final provider = context.read<TimelineProvider>();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.startRealtime();
      });
      return () {
        unawaited(provider.stopRealtime());
      };
    }, const []);

    final state = context.watch<TimelineProvider>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('タイムライン'),
        actions: [
          IconButton(
            onPressed: () => context.read<TimelineProvider>().fetch(),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () => context.go('/post'),
            icon: const Icon(Icons.edit_note),
          ),
        ],
      ),
      bottomNavigationBar: const AppNavBar(currentPath: '/timeline'),
      body: switch (state.status) {
        TimelineStatus.loading => const Center(child: CircularProgressIndicator()),
        TimelineStatus.error => Center(child: Text(state.message ?? 'エラーが発生しました。')),
        _ => _TimelineList(notes: state.notes, message: state.message),
      },
    );
  }
}

class _TimelineList extends HookWidget {
  const _TimelineList({required this.notes, this.message});

  final List<Note> notes;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final listKey = useMemoized(() => GlobalKey<AnimatedListState>());
    final scrollController = useScrollController();
    final visibleNotes = useState<List<Note>>(List<Note>.from(notes));
    final isFirstSync = useRef(true);
    final pendingNotes = useRef<List<Note>>([]);
    final isAtTop = useState(true);

    // スクロール位置を監視
    useEffect(() {
      void listener() {
        final atTop = scrollController.offset == 0;
        isAtTop.value = atTop;

        // 最上部に来たときに保留中の更新を反映
        if (atTop && pendingNotes.value.isNotEmpty) {
          _applyNoteUpdates(
            context,
            listKey,
            visibleNotes,
            pendingNotes.value,
          );
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

      // 最上部にいる場合は即座に反映、そうでない場合は保留
      if (isAtTop.value) {
        _applyNoteUpdates(
          context,
          listKey,
          visibleNotes,
          notes,
        );
        pendingNotes.value = [];
      } else {
        pendingNotes.value = List<Note>.from(notes);
      }

      return null;
    }, [notes]);

    if (visibleNotes.value.isEmpty) {
      return Center(
        child: Text(message ?? '投稿がありません。認証後に再取得してください。'),
      );
    }

    return AnimatedList(
      key: listKey,
      controller: scrollController,
      initialItemCount: visibleNotes.value.length,
      itemBuilder: (context, index, animation) {
        final note = visibleNotes.value[index];
        return _AnimatedTimelineItem(note: note, animation: animation);
      },
    );
  }

  static void _applyNoteUpdates(
    BuildContext context,
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
        (context, animation) => _AnimatedTimelineItem(
          note: removed,
          animation: animation,
        ),
        duration: const Duration(milliseconds: 180),
      );
    }

    visibleNotes.value = List<Note>.unmodifiable(current);
  }
}

class _AnimatedTimelineItem extends StatelessWidget {
  const _AnimatedTimelineItem({required this.note, required this.animation});

  final Note note;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    return SizeTransition(
      sizeFactor: curved,
      axisAlignment: -1,
      child: FadeTransition(
        opacity: animation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('@${note.user.username}'),
              subtitle: Text(note.text.isEmpty ? '(本文なし)' : note.text),
              trailing: Text(
                '${note.createdAt.month}/${note.createdAt.day} ${note.createdAt.hour}:${note.createdAt.minute.toString().padLeft(2, '0')}',
              ),
            ),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}
