import 'package:flutter/material.dart';

import 'emoji_text.dart';

/// リアクション一覧（チップ群）を表示するウィジェット。
/// reactions が空の場合は何も表示しない。
class NoteReactionList extends StatelessWidget {
  const NoteReactionList({
    required this.reactions,
    this.onReactionTap,
    super.key,
  });

  final Map<String, int> reactions;
  final ValueChanged<String>? onReactionTap;

  // `:name@.:` は同一サーバ絵文字なので `:name:` に正規化する。
  static String _normalizeReaction(String reaction) {
    final match = RegExp(r'^:([a-zA-Z0-9_]+)@\.:$').firstMatch(reaction);
    if (match == null) return reaction;
    return ':${match.group(1)}:';
  }

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: reactions.entries
          .where((entry) => entry.value > 0)
          .map(
            (entry) => _ReactionChip(
              reactionKey: entry.key,
              reaction: _normalizeReaction(entry.key),
              count: entry.value,
              onTap: onReactionTap,
            ),
          )
          .toList(growable: false),
    );
  }
}

class _ReactionChip extends StatelessWidget {
  const _ReactionChip({
    required this.reactionKey,
    required this.reaction,
    required this.count,
    this.onTap,
  });

  final String reactionKey;
  final String reaction;
  final int count;
  final ValueChanged<String>? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          EmojiText(
            reaction,
            emojiSize: 18,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: 4),
          Text('$count'),
        ],
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: ValueKey('reaction-chip-$reactionKey'),
          borderRadius: BorderRadius.circular(12),
          onTap: onTap == null ? null : () => onTap!(reactionKey),
          child: content,
        ),
      ),
    );
  }
}
