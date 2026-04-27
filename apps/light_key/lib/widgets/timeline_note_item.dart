import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter/material.dart';

import '../models/note.dart';
import '../models/note_type.dart';
import 'emoji_text.dart';
import 'note_media_list.dart';
import 'renote_card.dart';

class TimelineNoteItem extends StatelessWidget {
  const TimelineNoteItem({
    required this.note,
    required this.animation,
    super.key,
  });

  final Note note;
  final Animation<double> animation;

  String _createdAtLabel(DateTime createdAt) {
    return '${createdAt.month}/${createdAt.day} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  // `:name@.:` は同一サーバ絵文字なので `:name:` に正規化する。
  String _normalizeReaction(String reaction) {
    final match = RegExp(r'^:([a-zA-Z0-9_]+)@\.:$').firstMatch(reaction);
    if (match == null) {
      return reaction;
    }
    return ':${match.group(1)}:';
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
                          _UserAvatar(
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
                      _UserAvatar(
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
                            if (displayReactions.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: displayReactions.entries
                                    .where((entry) => entry.value > 0)
                                    .map(
                                      (entry) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            EmojiText(
                                              _normalizeReaction(entry.key),
                                              emojiSize: 18,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(width: 4),
                                            Text('${entry.value}'),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(growable: false),
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

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({
    required this.avatarUrl,
    this.avatarBlurHash,
    this.size = 40,
  });

  final String? avatarUrl;
  final String? avatarBlurHash;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;
    if (url == null || url.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        child: Icon(Icons.person_outline, size: size * 0.5),
      );
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, _) {
          final blurHash = avatarBlurHash;
          if (blurHash != null && blurHash.isNotEmpty) {
            return BlurHash(hash: blurHash);
          }
          return SizedBox(
            width: size,
            height: size,
            child: Center(
              child: SizedBox(
                width: size * 0.4,
                height: size * 0.4,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorWidget: (context, _, _) => CircleAvatar(
          radius: size / 2,
          child: Icon(Icons.person_outline, size: size * 0.5),
        ),
      ),
    );
  }
}
