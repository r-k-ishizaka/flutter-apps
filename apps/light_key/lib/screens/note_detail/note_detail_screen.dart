import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../services/emoji_cache.dart';
import '../../widgets/timeline_note_item.dart';
import 'note_detail_note_actions.dart';
import 'note_detail_provider.dart';
import 'note_detail_screen_state.dart';

class NoteDetailScreen extends HookWidget {
  const NoteDetailScreen({required this.noteId, super.key});

  final String noteId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoteDetailProvider>();
    final state = provider.state;
    final emojiCache = context.read<EmojiCache>().entries;
    final currentNoteId = switch (state) {
      NoteDetailScreenStateLoaded(:final note) => note.id,
      _ => noteId,
    };

    // アクションをuseMemoizedで作成
    final actions = useMemoized(
      () => NoteDetailNoteActions(
        provider: provider,
        currentNoteId: currentNoteId,
        context: context,
      ),
      [provider, currentNoteId],
    );

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.load(noteId);
      });
      return null;
    }, [noteId]);

    return Scaffold(
      appBar: AppBar(title: const Text('ノート詳細')),
      body: SafeArea(
        top: false,
        child: switch (state) {
          NoteDetailScreenStateIdle() ||
          NoteDetailScreenStateLoading() => const LoadingContent(),
          NoteDetailScreenStateLoaded(:final note) => SingleChildScrollView(
            child: TimelineNoteItem(
              note: note,
              animation: kAlwaysCompleteAnimation,
              emojis: emojiCache,
              showAllMedia: true,
              showAllReactions: true,
              actions: actions,
            ),
          ),
          NoteDetailScreenStateError(:final message) => ErrorContent(
            message: message ?? 'ノート詳細の取得に失敗しました。',
            onRetry: () => provider.load(noteId),
          ),
        },
      ),
    );
  }
}
