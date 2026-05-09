import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../models/note.dart';
import '../services/emoji_cache.dart';
import '../utils/datetime_format.dart';
import 'emoji_text.dart';
import 'note_media_list.dart';
import 'user_avatar.dart';

/// リノート元ノートを枠線付きカードで表示するウィジェット。
/// 多段リノートは 1 段のみ表示。
class RenoteCard extends HookWidget {
  const RenoteCard({
    required this.renote,
    required this.emojis,
    this.onBodyEmojiTap,
    this.onTap,
    super.key,
  });

  final Note renote;
  final Map<String, EmojiCacheEntry> emojis;
  final ValueChanged<String>? onBodyEmojiTap;
  final VoidCallback? onTap;

  String _createdAtLabel(DateTime createdAt) => createdAt.toNoteLabel();

  @override
  Widget build(BuildContext context) {
    final cwExpanded = useState(false);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final displayUserName = renote.user.name.isNotEmpty
        ? renote.user.name
        : renote.user.username;

    final cw = renote.cw;
    final hasCw = cw != null && cw.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
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
                              emojis: emojis,
                              host: renote.user.host,
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
                  if (hasCw) ...[
                    _RenoteCardCwBar(
                      cwText: cw,
                      expanded: cwExpanded.value,
                      onToggle: () => cwExpanded.value = !cwExpanded.value,
                      host: renote.user.host,
                      emojis: emojis,
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (!hasCw || cwExpanded.value) ...[
                    EmojiText(
                      renote.text.isNotEmpty
                          ? renote.text
                          : renote.renote != null
                          ? '(リノート)'
                          : '(本文なし)',
                      emojis: emojis,
                      host: renote.user.host,
                      onEmojiTap: onBodyEmojiTap,
                      style: textTheme.bodyMedium,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (renote.files.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      NoteMediaList(files: renote.files),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RenoteCardCwBar extends StatelessWidget {
  const _RenoteCardCwBar({
    required this.cwText,
    required this.expanded,
    required this.onToggle,
    required this.host,
    required this.emojis,
  });

  final String cwText;
  final bool expanded;
  final VoidCallback onToggle;
  final String? host;
  final Map<String, EmojiCacheEntry> emojis;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EmojiText(
              cwText,
              emojis: emojis,
              host: host,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              emojiSize: 14,
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                expanded ? '隠す' : 'もっと見る',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
