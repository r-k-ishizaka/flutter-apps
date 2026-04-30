import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../di/di.dart';
import '../../services/emoji_cache.dart';

/// ユニコード絵文字を表示するシンプルなセル。
class EmojiCell extends StatelessWidget {
  const EmojiCell({required this.emoji, required this.onTap, super.key});

  final String emoji;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
    );
  }
}

/// カスタム絵文字（URL画像）を表示するセル。
class CustomEmojiCell extends StatelessWidget {
  const CustomEmojiCell({
    required this.name,
    required this.url,
    required this.onTap,
    super.key,
  });

  final String name;
  final String url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cache = getIt<EmojiCache>();
    final imageBytes = cache.getImageBytes(name);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: imageBytes != null && imageBytes.isNotEmpty
            ? Image.memory(
                imageBytes,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    ':$name:',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              )
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                placeholder: (context, url) => const SizedBox.expand(
                  child: Center(
                    child: SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Center(
                  child: Text(
                    ':$name:',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
      ),
    );
  }
}
