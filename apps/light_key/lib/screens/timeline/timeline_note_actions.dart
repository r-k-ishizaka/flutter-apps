import 'package:flutter/material.dart';

import '../../models/note.dart';
import '../../models/user.dart';
import '../../route/app_routes.dart';
import '../../sheets/note_emoji_action/note_emoji_action_sheet.dart';
import '../../sheets/renote_action/renote_action_sheet.dart';
import '../../widgets/note_actions/note_actions.dart';
import '../../widgets/note_actions/note_actions_mixin.dart';
import 'timeline_provider.dart';

/// Timeline画面でのノートアクション実装。
///
/// TimelineProviderと連携して、リアクション/リノートの投稿、
/// ノート詳細/ユーザープロフィール/投稿画面への遷移を行う。
class TimelineNoteActions with NoteActionsMixin implements NoteActions {
  TimelineNoteActions({
    required this.provider,
    required BuildContext context,
  }) : _context = context;

  final TimelineProvider provider;
  final BuildContext _context;

  @override
  BuildContext get context => _context;

  @override
  Future<void> onNoteTap(Note note) async {
    final noteId = getNoteDetailId(note);
    if (noteId.isEmpty) {
      showComingSoon('ノート詳細');
      return;
    }
    await NoteDetailRoute(noteId: noteId).push<void>(context);
  }

  @override
  Future<void> onReply(Note note) async {
    final targetNote = getReplyTargetNote(note);
    final replyToId = getReplyTargetId(note);
    if (replyToId.isEmpty) {
      showComingSoon('リプライ');
      return;
    }

    final message = await PostRoute(
      replyToId: replyToId,
      replyToUserName: targetNote.user.username,
      replyToDisplayName: targetNote.user.name,
      replyToText: getReplyPreviewText(targetNote),
      replyToAvatarUrl: targetNote.user.avatarUrl,
    ).push<String>(context);

    if (!context.mounted || message == null || message.isEmpty) return;
    showSnackBar(message);
  }

  @override
  Future<void> onRenote(Note note) async {
    final action = await pickRenoteAction();
    if (action == null || !context.mounted) return;

    switch (action) {
      case RenoteAction.renote:
        final message = await provider.createRenote(note);
        if (!context.mounted) return;
        showSnackBar(message ?? 'リノートしました。');
        return;
      case RenoteAction.quote:
        showComingSoon('引用');
        return;
    }
  }

  @override
  Future<void> onReaction(Note note) async {
    final emoji = await pickReaction();
    if (emoji == null || !context.mounted) return;
    await _sendReaction(note, emoji);
  }

  @override
  Future<void> onReactionChipTap(Note note, String reaction) async {
    await _sendReaction(note, reaction);
  }

  @override
  Future<void> onUserTap(User user) async {
    if (user.id.isEmpty) {
      showComingSoon('プロフィール表示');
      return;
    }
    await UserProfileRoute(userId: user.id).push<void>(context);
  }

  @override
  Future<void> onBodyEmojiTap(Note note, String emoji) async {
    final action = await pickEmojiAction(emoji);
    if (action == null || !context.mounted) return;

    switch (action) {
      case NoteEmojiAction.react:
        await _sendReaction(note, emoji);
        return;
      case NoteEmojiAction.copy:
        await copyEmojiToClipboard(emoji);
        return;
    }
  }

  @override
  Future<void> onReplyNoteTap(Note reply) async {
    await onNoteTap(reply);
  }

  /// リアクションを送信する。
  Future<void> _sendReaction(Note note, String reaction) async {
    final message = await provider.createReaction(note, reaction);
    if (!context.mounted || message == null) return;
    showSnackBar(message);
  }
}
