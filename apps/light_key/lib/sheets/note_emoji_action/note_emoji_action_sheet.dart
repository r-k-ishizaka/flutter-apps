import 'package:flutter/material.dart';

enum NoteEmojiAction { react, copy }

/// 本文絵文字に対する操作を選択するボトムシート。
Future<NoteEmojiAction?> showNoteEmojiActionSheet(
  BuildContext context, {
  required String emoji,
}) {
  return showModalBottomSheet<NoteEmojiAction>(
    context: context,
    useRootNavigator: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(emoji),
              dense: true,
            ),
            ListTile(
              leading: const Icon(Icons.add_reaction_outlined),
              title: const Text('リアクションする'),
              onTap: () => Navigator.of(context).pop(NoteEmojiAction.react),
            ),
            ListTile(
              leading: const Icon(Icons.content_copy_outlined),
              title: const Text('コピー'),
              onTap: () => Navigator.of(context).pop(NoteEmojiAction.copy),
            ),
          ],
        ),
      );
    },
  );
}
