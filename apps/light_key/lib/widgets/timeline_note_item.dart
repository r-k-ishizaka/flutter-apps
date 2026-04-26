import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter/material.dart';

import '../models/note.dart';
import 'emoji_text.dart';
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

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );

    // 純粋リノートの場合はリノート元を主役として表示
    final displayNote =
        note.noteType == NoteType.pureRenote ? note.renote! : note;

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
                                  EmojiText(note.text),
                                  const SizedBox(height: 8),
                                  RenoteCard(renote: note.renote!),
                                ],
                              ),
                            },
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
        errorWidget: (context, _, _) =>
            CircleAvatar(
              radius: size / 2,
              child: Icon(Icons.person_outline, size: size * 0.5),
            ),
      ),
    );
  }
}
