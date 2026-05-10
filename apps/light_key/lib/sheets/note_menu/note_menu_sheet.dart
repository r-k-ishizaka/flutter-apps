import 'package:flutter/material.dart';

import '../../models/note.dart';
import '../../services/emoji_cache.dart';
import '../../widgets/emoji_text.dart';

enum NoteMenuAction {
  addFavorite,
  copyLink,
  pinNote,
  undoRenote,
  deleteNote,
  muteUser,
  muteUserRenote,
  blockUser,
  report,
}

/// ノートのメニューを表示するボトムシート。
///
/// セクション構成:
/// - お気に入りに追加 / リンクをコピー
/// - ピン留め / この投稿を削除（自分のノートのみ）
/// - リノートをミュート（pure renote のみ）/ 〇〇さんをミュート / 〇〇さんをブロック（他人のノートのみ）
/// - 通報（他人のノートのみ）
Future<NoteMenuAction?> showNoteMenuSheet(
  BuildContext context, {
  required Note note,
  required Note menuTargetNote,
  Map<String, EmojiCacheEntry> emojis = const {},
  bool isOwnNote = false,
  bool isPureRenote = false,
  String renoteUserName = '',
}) {
  final displayName = menuTargetNote.user.name.isNotEmpty
      ? menuTargetNote.user.name
      : menuTargetNote.user.username;

  return showModalBottomSheet<NoteMenuAction>(
    context: context,
    useRootNavigator: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── セクション1: お気に入り / リンクコピー ──
              ListTile(
                leading: const Icon(Icons.star_outline),
                title: const Text('お気に入りに追加'),
                onTap: () =>
                    Navigator.of(context).pop(NoteMenuAction.addFavorite),
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('リンクをコピー'),
                onTap: () =>
                    Navigator.of(context).pop(NoteMenuAction.copyLink),
              ),
              const Divider(height: 1),
              // ── セクション2: ピン留め / 投稿を削除（自分のノートのみ） ──
              if (isOwnNote) ...[
                ListTile(
                  leading: const Icon(Icons.push_pin_outlined),
                  title: const Text('ピン留め'),
                  onTap: () =>
                      Navigator.of(context).pop(NoteMenuAction.pinNote),
                ),
                if (isPureRenote)
                  ListTile(
                    leading: const Icon(Icons.undo_outlined),
                    title: const Text('リノートを取り消す'),
                    onTap: () =>
                        Navigator.of(context).pop(NoteMenuAction.undoRenote),
                  ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('この投稿を削除'),
                  onTap: () =>
                      Navigator.of(context).pop(NoteMenuAction.deleteNote),
                ),
                const Divider(height: 1),
              ],
              // ── セクション3: ミュート / ブロック（他人のノートのみ） ──
              if (!isOwnNote) ...[
                if (isPureRenote)
                  ListTile(
                    leading: const Icon(Icons.volume_off_outlined),
                    title: EmojiText(
                      '$renoteUserName さんのリノートをミュート',
                      emojis: emojis,
                      host: note.user.host,
                    ),
                    onTap: () =>
                        Navigator.of(context).pop(NoteMenuAction.muteUserRenote),
                  ),
                ListTile(
                  leading: const Icon(Icons.volume_off_outlined),
                  title: EmojiText(
                    '$displayName さんをミュート',
                    emojis: emojis,
                    host: menuTargetNote.user.host,
                  ),
                  onTap: () =>
                      Navigator.of(context).pop(NoteMenuAction.muteUser),
                ),
                ListTile(
                  leading: const Icon(Icons.block),
                  title: EmojiText(
                    '$displayName さんをブロック',
                    emojis: emojis,
                    host: menuTargetNote.user.host,
                  ),
                  onTap: () =>
                      Navigator.of(context).pop(NoteMenuAction.blockUser),
                ),
                const Divider(height: 1),
              ],
              // ── セクション4: 通報（他人のノートのみ） ──
              if (!isOwnNote)
                ListTile(
                leading: Icon(
                  Icons.flag_outlined,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  '通報',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                onTap: () =>
                    Navigator.of(context).pop(NoteMenuAction.report),
              ),
            ],
          ),
        ),
      );
    },
  );
}
