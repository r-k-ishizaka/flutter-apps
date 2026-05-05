import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../models/note.dart';
import '../models/note_type.dart';
import '../models/note_visibility.dart';
import '../models/user.dart';
import '../services/emoji_cache.dart';
import '../utils/datetime_format.dart';
import 'emoji_text.dart';
import 'note_media_list.dart';
import 'note_reaction_list.dart';
import 'renote_card.dart';
import 'user_avatar.dart';

class TimelineNoteItem extends HookWidget {
  const TimelineNoteItem({
    required this.note,
    required this.animation,
    required this.emojis,
    this.onReply,
    this.onRenote,
    this.onReaction,
    this.onReactionChipTap,
    this.onUserTap,
    this.onBodyEmojiTap,
    super.key,
  });

  final Note note;
  final Animation<double> animation;
  final Map<String, EmojiCacheEntry> emojis;
  final VoidCallback? onReply;
  final VoidCallback? onRenote;
  final VoidCallback? onReaction;
  final ValueChanged<String>? onReactionChipTap;
  final ValueChanged<User>? onUserTap;
  final ValueChanged<String>? onBodyEmojiTap;

  String _createdAtLabel(DateTime createdAt) => createdAt.toNoteLabel();

  @override
  Widget build(BuildContext context) {
    final cwExpanded = useState(false);
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );

    // 純粋リノートの場合はリノート元を主役として表示
    final displayNote = note.noteType == NoteType.pureRenote
        ? note.renote!
        : note;
    final displayReactions = note.noteType == NoteType.pureRenote
        ? displayNote.reactions
        : note.reactions;
    final displayMyReaction = note.noteType == NoteType.pureRenote
        ? displayNote.myReaction
        : note.myReaction;
    final displayUserName = displayNote.user.name.isNotEmpty
        ? displayNote.user.name
        : displayNote.user.username;
    final renoteUserName = note.user.name.isNotEmpty
        ? note.user.name
        : note.user.username;
    final onDisplayUserTap = displayNote.user.id.isNotEmpty && onUserTap != null
        ? () => onUserTap!(displayNote.user)
        : null;
    final onRenoteUserTap = note.user.id.isNotEmpty && onUserTap != null
        ? () => onUserTap!(note.user)
        : null;

    // CW の有無
    final cw = displayNote.cw;
    final hasCw = cw != null && cw.isNotEmpty;
    final renoteAction = displayNote.visibility == NoteVisibility.followers
        ? null
        : onRenote;

    return SizeTransition(
      sizeFactor: curved,
      axisAlignment: -1,
      child: FadeTransition(
        opacity: animation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 純粋リノートのヘッダー
                  if (note.noteType == NoteType.pureRenote)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.repeat, size: 14),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: onRenoteUserTap,
                            child: UserAvatar(
                              avatarUrl: note.user.avatarUrl,
                              avatarBlurHash: note.user.avatarBlurHash,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: GestureDetector(
                              onTap: onRenoteUserTap,
                              behavior: HitTestBehavior.opaque,
                              child: EmojiText(
                                '$renoteUserName がリノート',
                                emojis: emojis,
                                host: note.user.host,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                emojiSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: onDisplayUserTap,
                        child: UserAvatar(
                          avatarUrl: displayNote.user.avatarUrl,
                          avatarBlurHash: displayNote.user.avatarBlurHash,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: onDisplayUserTap,
                                    behavior: HitTestBehavior.opaque,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                          EmojiText(
                                            displayUserName,
                                            emojis: emojis,
                                          host: displayNote.user.host,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          emojiSize: 18,
                                        ),
                                        Text(
                                          '@${displayNote.user.username}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _NoteStatusIcons(note: displayNote),
                                    const SizedBox(width: 4),
                                    Text(
                                      _createdAtLabel(displayNote.createdAt),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                             // CW バー
                             if (hasCw) ...[
                                _CwBar(
                                 cwText: cw,
                                 expanded: cwExpanded.value,
                                 onToggle: () =>
                                     cwExpanded.value = !cwExpanded.value,
                                   host: displayNote.user.host,
                                 emojis: emojis,
                               ),
                               const SizedBox(height: 4),
                             ],
                            // 本文・メディア（CW がある場合は展開時のみ表示）
                            if (!hasCw || cwExpanded.value) ...[
                               switch (note.noteType) {
                               NoteType.normal => EmojiText(
                                 note.text.isEmpty ? '(本文なし)' : note.text,
                                 emojis: emojis,
                                 host: note.user.host,
                                 onEmojiTap: onBodyEmojiTap,
                               ),
                               NoteType.pureRenote => EmojiText(
                                 displayNote.text.isEmpty
                                     ? '(本文なし)'
                                     : displayNote.text,
                                 emojis: emojis,
                                 host: displayNote.user.host,
                                 onEmojiTap: onBodyEmojiTap,
                               ),
                               NoteType.quoteRenote => Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   EmojiText(
                                     note.text.isEmpty ? '(本文なし)' : note.text,
                                     emojis: emojis,
                                     host: note.user.host,
                                     onEmojiTap: onBodyEmojiTap,
                                   ),
                                    if (note.files.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      NoteMediaList(files: note.files),
                                    ],
                                     const SizedBox(height: 8),
                                     RenoteCard(
                                       renote: note.renote!,
                                       emojis: emojis,
                                       onBodyEmojiTap: onBodyEmojiTap,
                                     ),
                                   ],
                                ),
                              },
                              if (note.noteType == NoteType.normal &&
                                  note.files.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                NoteMediaList(files: note.files),
                              ],
                              if (note.noteType == NoteType.pureRenote &&
                                  displayNote.files.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                NoteMediaList(files: displayNote.files),
                              ],
                            ],
                            const SizedBox(height: 8),
                            _TimelineNoteActionRow(
                              onReply: onReply,
                              onRenote: renoteAction,
                              onReaction: onReaction,
                            ),
                            if (displayReactions.isNotEmpty) ...[
                              const SizedBox(height: 8),
                             NoteReactionList(
                               reactions: displayReactions,
                               emojis: emojis,
                                myReaction: displayMyReaction,
                                onReactionTap: onReactionChipTap,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}

/// 公開範囲・連合有無アイコン行
class _NoteStatusIcons extends StatelessWidget {
  const _NoteStatusIcons({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    final iconSize = 14.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 2,
      children: [
        // public は広く知られているデフォルトなので非表示
        if (note.visibility != NoteVisibility.public)
          Tooltip(
            message: note.visibility.label,
            child: Icon(note.visibility.icon, size: iconSize, color: color),
          ),
        if (note.localOnly)
          Tooltip(
            message: 'ローカルのみ（連合なし）',
            child: _LocalOnlyIcon(size: iconSize, color: color),
          ),
      ],
    );
  }
}

/// 連合なし（ローカルのみ）アイコン。ロケットに斜線を重ねた表現。
class _LocalOnlyIcon extends StatelessWidget {
  const _LocalOnlyIcon({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surface;
    final slashW = size * 0.85;
    final slashH = size * 0.19;
    final outlineW = size * 0.95;
    final outlineH = size * 0.32;
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.rocket_launch, size: size, color: color),
        Transform.rotate(
          angle: 0.7,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: outlineW,
                height: outlineH,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(outlineH / 2),
                ),
              ),
              Container(
                width: slashW,
                height: slashH,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(slashH / 2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// CW (Contents Warning) バー。CW テキストと展開/折りたたみボタンを表示する。
class _CwBar extends StatelessWidget {
  const _CwBar({
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
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
            emojiSize: 16,
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onToggle,
              child: Text(
                expanded ? '隠す' : 'もっと見る',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineNoteActionRow extends StatelessWidget {
  const _TimelineNoteActionRow({this.onReply, this.onRenote, this.onReaction});

  final VoidCallback? onReply;
  final VoidCallback? onRenote;
  final VoidCallback? onReaction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: 8,
      children: [
        _TimelineNoteActionButton(
          icon: Icons.reply_outlined,
          tooltip: 'リプライ',
          onPressed: onReply,
        ),
        _TimelineNoteActionButton(
          icon: Icons.repeat,
          tooltip: 'リノート',
          onPressed: onRenote,
        ),
        _TimelineNoteActionButton(
          icon: Icons.add_reaction_outlined,
          tooltip: 'リアクション',
          onPressed: onReaction,
        ),
      ],
    );
  }
}

class _TimelineNoteActionButton extends StatelessWidget {
  const _TimelineNoteActionButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      constraints: const BoxConstraints(minHeight: 36),
      alignment: Alignment.centerLeft,
    );
  }
}
