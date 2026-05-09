import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/note.dart';
import '../../models/note_type.dart';
import '../../route/app_routes.dart';
import '../../screens/post/post_screen_param.dart';
import '../../sheets/note_emoji_action/note_emoji_action_sheet.dart';
import '../../sheets/reaction_picker/reaction_picker_sheet.dart';
import '../../sheets/renote_action/renote_action_sheet.dart';

/// [NoteActions] 実装で共通して使用するヘルパーメソッドを提供するMixin。
///
/// リアクション送信、リノート、絵文字アクション、SnackBar表示など、
/// 複数の画面で同じ処理が必要な機能を集約する。
mixin NoteActionsMixin {
  /// Contextを取得する。各実装クラスで提供する必要がある。
  BuildContext get context;

  /// SnackBarを表示する。
  @protected
  void showSnackBar(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// 「準備中」メッセージを表示する。
  @protected
  void showComingSoon(String label) {
    showSnackBar('$label は準備中です');
  }

  /// リアクションピッカーを表示して絵文字を選択する。
  @protected
  Future<String?> pickReaction() async {
    return showReactionPickerSheet(context);
  }

  /// リノートアクションシートを表示してアクションを選択する。
  @protected
  Future<RenoteAction?> pickRenoteAction() async {
    return showRenoteActionSheet(context);
  }

  /// 絵文字アクションシートを表示してアクションを選択する。
  @protected
  Future<NoteEmojiAction?> pickEmojiAction(String emoji) async {
    return showNoteEmojiActionSheet(context, emoji: emoji);
  }

  /// 絵文字をクリップボードにコピーする。
  @protected
  Future<void> copyEmojiToClipboard(String emoji) async {
    await Clipboard.setData(ClipboardData(text: emoji));
    if (!context.mounted) return;
    showSnackBar('絵文字をコピーしました。');
  }

  /// ノート詳細画面で表示するノートIDを取得する。
  /// 純粋リノートの場合はリノート元のIDを返す。
  @protected
  String getNoteDetailId(Note note) {
    if (note.noteType == NoteType.pureRenote) {
      return note.renote?.id ?? note.id;
    }
    return note.id;
  }

  /// リプライ対象のノートIDを取得する。
  /// 純粋リノートの場合はリノート元のIDを返す。
  @protected
  String getReplyTargetId(Note note) {
    if (note.noteType == NoteType.pureRenote) {
      return note.renote?.id ?? '';
    }
    return note.id;
  }

  /// リプライ対象のノートを取得する。
  /// 純粋リノートの場合はリノート元を返す。
  @protected
  Note getReplyTargetNote(Note note) {
    if (note.noteType == NoteType.pureRenote && note.renote != null) {
      return note.renote!;
    }
    return note;
  }

  /// リプライプレビューに表示するテキストを取得する。
  /// CWがある場合はCWテキストを優先する。
  @protected
  String getReplyPreviewText(Note note) {
    if (note.cw != null && note.cw!.isNotEmpty) {
      return note.cw!;
    }
    return note.text;
  }

  /// 引用リノート画面へ遷移する。
  /// 純粋リノートの場合は元ノートを引用する。
  @protected
  Future<String?> navigateToQuoteRenote(Note note) async {
    final targetNote = getReplyTargetNote(note);
    final renoteId = getReplyTargetId(note);
    if (renoteId.isEmpty) {
      return null;
    }

    return PostRoute(
      $extra: PostScreenParam.quote(
        targetId: renoteId,
        userName: targetNote.user.username,
        displayName: targetNote.user.name,
        text: getReplyPreviewText(targetNote),
        avatarUrl: targetNote.user.avatarUrl,
      ),
    ).push<String>(context);
  }
}
