import 'package:flutter/material.dart';

import '../models/note.dart';
import '../models/note_type.dart';
import 'emoji_text.dart';
import 'note_media_list.dart';
import 'note_reaction_list.dart';
import 'renote_card.dart';
import 'user_avatar.dart';

class TimelineNoteItem extends StatelessWidget {
  const TimelineNoteItem({
    required this.note,
    required this.animation,
    this.onReply,
    this.onRenote,
    this.onReaction,
    this.onReactionChipTap,
    super.key,
  });

  final Note note;
  final Animation<double> animation;
  final VoidCallback? onReply;
  final VoidCallback? onRenote;
  final VoidCallback? onReaction;
  final ValueChanged<String>? onReactionChipTap;

  String _createdAtLabel(DateTime createdAt) {
    return '${createdAt.month}/${createdAt.day} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
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
                          UserAvatar(
                            avatarUrl: note.user.avatarUrl,
                            avatarBlurHash: note.user.avatarBlurHash,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '@${note.user.username} がリノート',
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UserAvatar(
                        avatarUrl: displayNote.user.avatarUrl,
                        avatarBlurHash: displayNote.user.avatarBlurHash,
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
                                  child: Text(
                                    '@${displayNote.user.username}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(_createdAtLabel(displayNote.createdAt)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            switch (note.noteType) {
                              NoteType.normal => EmojiText(
                                note.text.isEmpty ? '(本文なし)' : note.text,
                              ),
                              NoteType.pureRenote => EmojiText(
                                displayNote.text.isEmpty
                                    ? '(本文なし)'
                                    : displayNote.text,
                              ),
                              NoteType.quoteRenote => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  EmojiText(
                                    note.text.isEmpty ? '(本文なし)' : note.text,
                                  ),
                                  if (note.files.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    NoteMediaList(files: note.files),
                                  ],
                                  const SizedBox(height: 8),
                                  RenoteCard(renote: note.renote!),
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
                            const SizedBox(height: 8),
                            _TimelineNoteActionRow(
                              onReply: onReply,
                              onRenote: onRenote,
                              onReaction: onReaction,
                            ),
                            if (displayReactions.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              NoteReactionList(
                                reactions: displayReactions,
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
