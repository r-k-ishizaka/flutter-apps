import 'package:flutter/material.dart';

/// 検索結果に表示するカスタム絵文字の一覧タイル。
class CustomEmojiSearchResultTile extends StatelessWidget {
  const CustomEmojiSearchResultTile({
    required this.name,
    required this.url,
    required this.aliases,
    required this.categoryPath,
    required this.onTap,
    super.key,
  });

  final String name;
  final String url;
  final List<String> aliases;
  final String categoryPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final aliasSummary = switch (aliases.length) {
      0 => null,
      <= 3 => aliases.map((a) => ':$a:').join(', '),
      _ => '${aliases.take(3).map((a) => ':$a:').join(', ')}…',
    };
    final subtitle = [?aliasSummary, categoryPath].join(' • ');

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: SizedBox(
        width: 32,
        height: 32,
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
      title: Text(':$name:'),
      subtitle: subtitle.isEmpty
          ? null
          : Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
      onTap: onTap,
    );
  }
}
