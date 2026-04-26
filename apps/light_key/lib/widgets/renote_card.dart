import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter/material.dart';

import '../models/note.dart';
import 'emoji_text.dart';

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

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UserAvatar(
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
                      child: Text(
                        '@${renote.user.username}',
                        style: textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
              ],
            ),
          ),
        ],
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
