import 'package:cached_network_image/cached_network_image.dart';
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
            ListTile(
              leading: _UserAvatar(avatarUrl: note.user.avatarUrl),
              title: Text('@${note.user.username}'),
              subtitle: Text(note.text.isEmpty ? '(本文なし)' : note.text),
              trailing: Text(
                '${note.createdAt.month}/${note.createdAt.day} ${note.createdAt.hour}:${note.createdAt.minute.toString().padLeft(2, '0')}',
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
  const _UserAvatar({required this.avatarUrl});

  final String? avatarUrl;

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
        placeholder: (context, _) => const SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, _, _) =>
            const CircleAvatar(child: Icon(Icons.person_outline)),
      ),
    );
  }
}
