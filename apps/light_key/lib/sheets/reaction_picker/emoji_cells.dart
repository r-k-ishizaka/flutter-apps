import 'package:flutter/material.dart';

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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Image.network(
          url,
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
        ),
      ),
    );
  }
}
