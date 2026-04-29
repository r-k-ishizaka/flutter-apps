import 'package:flutter/material.dart';

import '../models/note.dart';
import 'emoji_text.dart';
import 'note_media_list.dart';
import 'user_avatar.dart';

/// リノート元ノートを枠線付きカードで表示するウィジェット。
/// 多段リノートは 1 段のみ表示。
class RenoteCard extends StatelessWidget {
  const RenoteCard({required this.renote, super.key});

  final Note renote;

  String _createdAtLabel(DateTime createdAt) {
    return '${createdAt.month}/${createdAt.day} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final displayUserName = renote.user.name.isNotEmpty
        ? renote.user.name
        : renote.user.username;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
            avatarUrl: renote.user.avatarUrl,
            avatarBlurHash: renote.user.avatarBlurHash,
            size: 32,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          EmojiText(
                            displayUserName,
                            style: textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            emojiSize: 18,
                          ),
                          Text(
                            '@${renote.user.username}',
                            style: textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _createdAtLabel(renote.createdAt),
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                EmojiText(
                  renote.text.isNotEmpty
                      ? renote.text
                      : renote.renote != null
                      ? '(リノート)'
                      : '(本文なし)',
                  style: textTheme.bodyMedium,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
                if (renote.files.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  NoteMediaList(files: renote.files),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
