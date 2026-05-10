import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/note.dart';
import '../../models/note_type.dart';
import '../../route/app_routes.dart';
import '../../screens/auth/auth_provider.dart';
import '../../screens/post/post_screen_param.dart';
import '../../services/emoji_cache.dart';
import '../../sheets/note_emoji_action/note_emoji_action_sheet.dart';
import '../../sheets/note_menu/note_menu_sheet.dart';
import '../../sheets/note_report/note_report_sheet.dart';
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

  /// 投稿削除の確認ダイアログを表示する。
  @protected
  Future<bool> confirmDeleteNote() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('この投稿を削除しますか？'),
        content: const Text('削除した投稿は元に戻せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('削除する'),
          ),
        ],
      ),
    );
    return shouldDelete == true;
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

  /// ノートメニューシートを表示してアクションを選択する。
  @protected
  Future<NoteMenuAction?> pickNoteMenuAction(
    Note note,
    Map<String, EmojiCacheEntry> emojis,
  ) async {
    final currentUserId = context.read<AuthProvider>().currentUser?.id ?? '';
    final isOwnNote = currentUserId.isNotEmpty && currentUserId == note.user.id;
    final isPureRenote = note.noteType == NoteType.pureRenote;
    final renoteUserName = isPureRenote
        ? (note.user.name.isNotEmpty ? note.user.name : note.user.username)
        : '';

    // ミュート・ブロック対象のユーザーノート
    // pure renote の場合はリノート元ノート
    final menuTargetNote = isPureRenote ? note.renote! : note;

    return showNoteMenuSheet(
      context,
      note: note,
      menuTargetNote: menuTargetNote,
      emojis: emojis,
      isOwnNote: isOwnNote,
      isPureRenote: isPureRenote,
      renoteUserName: renoteUserName,
    );
  }

  /// ノート通報シートを表示して入力内容を返す。
  @protected
  Future<NoteReportInput?> pickNoteReportReason() async {
    return showNoteReportSheet(context);
  }

  /// 絵文字をクリップボードにコピーする。
  @protected
  Future<void> copyEmojiToClipboard(String emoji) async {
    await Clipboard.setData(ClipboardData(text: emoji));
    if (!context.mounted) return;
    showSnackBar('絵文字をコピーしました。');
  }

  /// メニューアクションの対象ノートを取得する。
  /// 純粋リノートの場合はリノート元を返す。
  @protected
  Note getMenuActionTargetNote(Note note) {
    if (note.noteType == NoteType.pureRenote) {
      return note.renote ?? note;
    }
    return note;
  }

  /// ノートリンクをクリップボードにコピーする。
  @protected
  Future<void> copyNoteLinkToClipboard(Note note) async {
    final targetNote = getMenuActionTargetNote(note);
    if (targetNote.id.isEmpty) {
      showSnackBar('リンク対象のノートIDが見つかりません。');
      return;
    }

    final session = context.read<AuthProvider>().state.session;
    if (session == null) {
      showSnackBar('先に認証してください。');
      return;
    }

    final noteUrl = _buildNoteUrl(session.baseUrl, targetNote.id);
    await Clipboard.setData(ClipboardData(text: noteUrl));
    if (!context.mounted) return;
    showSnackBar('リンクをコピーしました。');
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

  String _buildNoteUrl(String baseUrl, String noteId) {
    final baseUri = Uri.parse(baseUrl.trim());
    final segments =
        baseUri.pathSegments
            .where((segment) => segment.isNotEmpty)
            .toList(growable: true)
          ..add('notes')
          ..add(noteId);

    return baseUri
        .replace(pathSegments: segments, query: null, fragment: null)
        .toString();
  }
}
