import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../models/note.dart';
import '../../models/user.dart';
import '../../route/app_routes.dart';
import '../../services/emoji_cache.dart';
import '../../sheets/note_emoji_action/note_emoji_action_sheet.dart';
import '../../sheets/reaction_picker/reaction_picker_sheet.dart';
import '../../sheets/renote_action/renote_action_sheet.dart';
import '../../widgets/timeline_note_item.dart';
import 'note_detail_provider.dart';
import 'note_detail_screen_state.dart';

class NoteDetailScreen extends HookWidget {
  const NoteDetailScreen({required this.noteId, super.key});

  final String noteId;

  void _showComingSoonSnackBar(BuildContext context, String label) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label は準備中です')));
  }

  Future<void> _sendReaction(
    BuildContext context,
    Note note,
    String reaction,
  ) async {
    final message = await context.read<NoteDetailProvider>().createReaction(
      note,
      reaction,
    );
    if (!context.mounted || message == null) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onNoteReaction(BuildContext context, Note note) async {
    final emoji = await showReactionPickerSheet(context);
    if (emoji == null || !context.mounted) return;
    await _sendReaction(context, note, emoji);
  }

  Future<void> _onNoteBodyEmojiTap(
    BuildContext context,
    Note note,
    String emoji,
  ) async {
    final action = await showNoteEmojiActionSheet(context, emoji: emoji);
    if (action == null || !context.mounted) return;

    switch (action) {
      case NoteEmojiAction.react:
        await _sendReaction(context, note, emoji);
        return;
      case NoteEmojiAction.copy:
        await Clipboard.setData(ClipboardData(text: emoji));
        if (!context.mounted) return;
        final messenger = ScaffoldMessenger.maybeOf(context);
        if (messenger == null) return;
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('絵文字をコピーしました。')));
        return;
    }
  }

  Future<void> _onNoteRenote(BuildContext context, Note note) async {
    final action = await showRenoteActionSheet(context);
    if (action == null || !context.mounted) return;

    switch (action) {
      case RenoteAction.renote:
        final message = await context.read<NoteDetailProvider>().createRenote(
          note,
        );
        if (!context.mounted) return;
        final messenger = ScaffoldMessenger.maybeOf(context);
        if (messenger == null) return;
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message ?? 'リノートしました。')));
        return;
      case RenoteAction.quote:
        _showComingSoonSnackBar(context, '引用');
        return;
    }
  }

  Future<void> _onUserTap(BuildContext context, User user) async {
    if (user.id.isEmpty) {
      _showComingSoonSnackBar(context, 'プロフィール表示');
      return;
    }
    await UserProfileRoute(userId: user.id).push<void>(context);
  }

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<NoteDetailProvider>().load(noteId);
      });
      return null;
    }, [noteId]);

    final state = context.watch<NoteDetailProvider>().state;
    final emojiCache = context.read<EmojiCache>().entries;

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
              onReply: () => _showComingSoonSnackBar(context, 'リプライ'),
              onRenote: () => _onNoteRenote(context, note),
              onReaction: () => _onNoteReaction(context, note),
              onReactionChipTap: (reaction) =>
                  _sendReaction(context, note, reaction),
              onUserTap: (user) => _onUserTap(context, user),
              onBodyEmojiTap: (emoji) =>
                  _onNoteBodyEmojiTap(context, note, emoji),
            ),
          ),
          NoteDetailScreenStateError(:final message) => ErrorContent(
            message: message ?? 'ノート詳細の取得に失敗しました。',
            onRetry: () => context.read<NoteDetailProvider>().load(noteId),
          ),
        },
      ),
    );
  }
}
