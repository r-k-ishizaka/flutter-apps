import 'package:flutter/material.dart';

import '../services/emoji_cache.dart';
import 'emoji_text.dart';

/// リアクション一覧（チップ群）を表示するウィジェット。
/// reactions が空の場合は何も表示しない。
class NoteReactionList extends StatelessWidget {
  const NoteReactionList({
    required this.reactions,
    required this.emojis,
    this.myReaction,
    this.onReactionTap,
    super.key,
  });

  final Map<String, int> reactions;
  final Map<String, EmojiCacheEntry> emojis;

  /// 自分がつけたリアクション。該当するチップにアクセントが付く。
  final String? myReaction;
  final ValueChanged<String>? onReactionTap;

  // `:name@.:` は同一サーバ絵文字なので `:name:` に正規化する。
  static String _normalizeReaction(String reaction) {
    final match = RegExp(r'^:([a-zA-Z0-9_]+)@\.:$').firstMatch(reaction);
    if (match == null) {
      return reaction;
    }
    final normalized = ':${match.group(1)}:';
    return normalized;
  }

  // `:name@host:` 形式で host が `.` 以外なら他サーバ絵文字として扱う。
  static bool _isCrossServerReaction(String reaction) {
    final match = RegExp(r'^:[a-zA-Z0-9_]+@([^:]+):$').firstMatch(reaction);
    final isCrossServer = match != null && match.group(1) != '.';
    return isCrossServer;
  }

  static const int _maxVisibleReactions = 16;

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox.shrink();
    final normalizedMyReaction = myReaction == null
        ? null
        : _normalizeReaction(myReaction!);
    final sortedEntries =
        reactions.entries
            .where((entry) => entry.value > 0)
            .toList(growable: false)
          ..sort((a, b) {
            final countCompare = b.value.compareTo(a.value);
            if (countCompare != 0) return countCompare;
            return a.key.compareTo(b.key);
          });

    final hasMore = sortedEntries.length > _maxVisibleReactions;

    // 上位16件を基本とし、自分のリアクションが16件目以降にある場合も必ず含める
    List<MapEntry<String, int>> visibleEntries;
    if (!hasMore) {
      visibleEntries = sortedEntries;
    } else {
      visibleEntries = sortedEntries.take(_maxVisibleReactions).toList();
      if (normalizedMyReaction != null) {
        final alreadyVisible = visibleEntries.any(
          (e) => _normalizeReaction(e.key) == normalizedMyReaction,
        );
        if (!alreadyVisible) {
          final myEntry = sortedEntries.firstWhere(
            (e) => _normalizeReaction(e.key) == normalizedMyReaction,
            orElse: () => const MapEntry('', 0),
          );
          if (myEntry.key.isNotEmpty) {
            visibleEntries = [...visibleEntries, myEntry];
          }
        }
      }
    }

    final hiddenCount = sortedEntries.length - visibleEntries.length;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ...visibleEntries.map((entry) {
          final normalizedReaction = _normalizeReaction(entry.key);
          final canTap = !_isCrossServerReaction(entry.key);
          return _ReactionChip(
            reactionKey: entry.key,
            reaction: normalizedReaction,
            count: entry.value,
            emojis: emojis,
            isEnabled: canTap,
            isMyReaction:
                normalizedMyReaction != null &&
                normalizedMyReaction == normalizedReaction,
            onTap: canTap ? onReactionTap : null,
          );
        }),
        if (hiddenCount > 0) _MoreReactionsChip(hiddenCount: hiddenCount),
      ],
    );
  }
}

class _MoreReactionsChip extends StatelessWidget {
  const _MoreReactionsChip({required this.hiddenCount});

  final int hiddenCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          'もっと見る',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _ReactionChip extends StatelessWidget {
  const _ReactionChip({
    required this.reactionKey,
    required this.reaction,
    required this.count,
    required this.emojis,
    this.isEnabled = true,
    this.isMyReaction = false,
    this.onTap,
  });

  final String reactionKey;
  final String reaction;
  final int count;
  final Map<String, EmojiCacheEntry> emojis;
  final bool isEnabled;
  final bool isMyReaction;
  final ValueChanged<String>? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = !isEnabled
        ? null
        : isMyReaction
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final textColor = !isEnabled
        ? colorScheme.onSurfaceVariant
        : isMyReaction
        ? colorScheme.onPrimaryContainer
        : null;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
           EmojiText(
             reaction,
             emojis: emojis,
             emojiSize: 18,
             maxLines: 1,
             overflow: TextOverflow.ellipsis,
           ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: textColor != null
                ? TextStyle(color: textColor, fontWeight: FontWeight.bold)
                : null,
          ),
        ],
      ),
    );

    final chipBody = Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        key: ValueKey('reaction-chip-$reactionKey'),
        borderRadius: BorderRadius.circular(12),
        onTap: onTap == null ? null : () => onTap!(reactionKey),
        child: content,
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: isMyReaction && isEnabled
            ? Border.all(color: colorScheme.primary, width: 1.5)
            : null,
      ),
      child: chipBody,
    );
  }
}
