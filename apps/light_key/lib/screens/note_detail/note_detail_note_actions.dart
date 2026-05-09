import 'package:flutter/material.dart';

import '../../models/note.dart';
import '../../models/user.dart';
import '../../route/app_routes.dart';
import '../../screens/post/post_screen_param.dart';
import '../../services/emoji_cache.dart';
import '../../sheets/note_emoji_action/note_emoji_action_sheet.dart';
import '../../sheets/note_menu/note_menu_sheet.dart';
import '../../sheets/renote_action/renote_action_sheet.dart';
import '../../widgets/note_actions/note_actions.dart';
import '../../widgets/note_actions/note_actions_mixin.dart';
import 'note_detail_provider.dart';

/// NoteDetail画面でのノートアクション実装。
///
/// NoteDetailProviderと連携して、リアクション/リノートの投稿、
/// ユーザープロフィールへの遷移を行う。
/// 本体ノートタップは無効だが、引用など別ノート部分タップは遷移対象とする。
class NoteDetailNoteActions with NoteActionsMixin implements NoteActions {
  NoteDetailNoteActions({
    required this.provider,
    required this.currentNoteId,
    required BuildContext context,
  }) : _context = context;

  final NoteDetailProvider provider;
  final String currentNoteId;
  final BuildContext _context;

  @override
  BuildContext get context => _context;

  @override
  Future<void> onNoteTap(Note note) async {
    // 現在表示中のノート本体タップは無視し、引用など別ノートのみ遷移する。
    if (note.id.isEmpty || note.id == currentNoteId) {
      return;
    }
    final detailId = getNoteDetailId(note);
    if (detailId.isEmpty) {
      return;
    }
    await NoteDetailRoute(noteId: detailId).push<void>(context);
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
      $extra: PostScreenParam.reply(
        targetId: replyToId,
        userName: targetNote.user.username,
        displayName: targetNote.user.name,
        text: getReplyPreviewText(targetNote),
        avatarUrl: targetNote.user.avatarUrl,
      ),
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
        final message = await navigateToQuoteRenote(note);
        if (!context.mounted || message == null || message.isEmpty) return;
        showSnackBar(message);
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

  @override
  Future<void> onMenu(Note note, Map<String, EmojiCacheEntry> emojis) async {
    final action = await pickNoteMenuAction(note, emojis);
    if (action == null || !context.mounted) return;
    switch (action) {
      case NoteMenuAction.addFavorite:
        final message = await provider.createFavorite(note);
        if (!context.mounted) return;
        showSnackBar(message ?? 'お気に入りに追加しました。');
        return;
      case NoteMenuAction.copyLink:
        await copyNoteLinkToClipboard(note);
        return;
      case NoteMenuAction.pinNote:
        final message = await provider.createPin(note);
        if (!context.mounted) return;
        showSnackBar(message ?? 'ピン留めしました。');
        return;
      case NoteMenuAction.deleteNote:
        final shouldDelete = await confirmDeleteNote();
        if (!context.mounted || !shouldDelete) return;
        final message = await provider.deleteNote(note);
        if (!context.mounted) return;
        showSnackBar(message ?? '投稿を削除しました。');
        return;
      case NoteMenuAction.muteUser:
        final targetUserId = getMenuActionTargetNote(note).user.id;
        final message = await provider.createMute(targetUserId);
        if (!context.mounted) return;
        showSnackBar(message ?? 'ユーザーをミュートしました。');
        return;
      case NoteMenuAction.muteUserRenote:
        final renoteUserId = note.user.id;
        final message = await provider.createRenoteMute(renoteUserId);
        if (!context.mounted) return;
        showSnackBar(message ?? 'ユーザーのリノートをミュートしました。');
        return;
      case NoteMenuAction.blockUser:
        final targetUserId = getMenuActionTargetNote(note).user.id;
        final message = await provider.createBlock(targetUserId);
        if (!context.mounted) return;
        showSnackBar(message ?? 'ユーザーをブロックしました。');
        return;
      case NoteMenuAction.report:
        // TODO: 通報
        showComingSoon('通報');
        return;
    }
  }

  /// リアクションを送信する。
  Future<void> _sendReaction(Note note, String reaction) async {
    final message = await provider.createReaction(note, reaction);
    if (!context.mounted || message == null) return;
    showSnackBar(message);
  }
}
