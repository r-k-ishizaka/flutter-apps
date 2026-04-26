import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter/material.dart';

import '../models/note.dart';

class TimelineNoteItem extends StatelessWidget {
  const TimelineNoteItem({
    required this.note,
    required this.animation,
    super.key,
  });

  final Note note;
  final Animation<double> animation;

  String get _createdAtLabel {
    final createdAt = note.createdAt;
    return '${createdAt.month}/${createdAt.day} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _UserAvatar(
                    avatarUrl: note.user.avatarUrl,
                    avatarBlurHash: note.user.avatarBlurHash,
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
                                '@${note.user.username}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(_createdAtLabel),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(note.text.isEmpty ? '(本文なし)' : note.text),
                      ],
                    ),
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
  const _UserAvatar({required this.avatarUrl, this.avatarBlurHash});

  final String? avatarUrl;
  final String? avatarBlurHash;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;
    if (url == null || url.isEmpty) {
      return const CircleAvatar(child: Icon(Icons.person_outline));
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        placeholder: (context, _) {
          final blurHash = avatarBlurHash;
          if (blurHash != null && blurHash.isNotEmpty) {
            return BlurHash(hash: blurHash);
          }
          return const SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorWidget: (context, _, _) =>
            const CircleAvatar(child: Icon(Icons.person_outline)),
      ),
    );
  }
}
