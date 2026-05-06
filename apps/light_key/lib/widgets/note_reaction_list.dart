import 'package:flutter/material.dart';

import '../services/emoji_cache.dart';
import '../utils/note_emoji_filter.dart';
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

  static const int _maxVisibleReactions = NoteEmojiFilter.maxVisibleReactions;
  static const _animationDuration = Duration(milliseconds: 220);

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

  static String _buildAnimationSignature(
    List<MapEntry<String, int>> visibleEntries,
    int hiddenCount,
  ) {
    final entriesSignature = visibleEntries
        .map((entry) => '${entry.key}:${entry.value}')
        .join('|');
    return '$entriesSignature#$hiddenCount';
  }

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox.shrink();
    final normalizedMyReaction = myReaction == null
        ? null
        : _normalizeReaction(myReaction!);

    // 正規化キーが同じエントリをマージしてカウントを合算する。
    // 例: `:name@.:` と `:name:` は同一リアクションとして扱う。
    final mergedReactions = <String, int>{};
    for (final entry in reactions.entries) {
      if (entry.value <= 0) continue;
      final normalized = _normalizeReaction(entry.key);
      mergedReactions[normalized] = (mergedReactions[normalized] ?? 0) + entry.value;
    }

    final sortedEntries =
        mergedReactions.entries
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
    final animationSignature = _buildAnimationSignature(
      visibleEntries,
      hiddenCount,
    );

    return AnimatedSize(
      duration: _animationDuration,
      curve: Curves.easeInOutCubic,
      alignment: Alignment.topLeft,
      child: AnimatedSwitcher(
        duration: _animationDuration,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          );
          return FadeTransition(opacity: fadeAnimation, child: child);
        },
        child: Wrap(
          key: ValueKey('reaction-wrap-$animationSignature'),
          spacing: 6,
          runSpacing: 6,
          children: [
            ...visibleEntries.map((entry) {
              // マージ後のキーはすでに正規化済み
              final normalizedReaction = entry.key;
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
        ),
      ),
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
    final borderColor = isMyReaction && isEnabled
        ? colorScheme.primary
        : Colors.transparent;

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
            showCrossServerCacheMissAsError: true,
          ),
          const SizedBox(width: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Text(
              '$count',
              key: ValueKey('reaction-count-$reactionKey-$count'),
              style: textColor != null
                  ? TextStyle(color: textColor, fontWeight: FontWeight.bold)
                  : null,
            ),
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        // 枠線の太さを固定して、選択状態の切替時もチップ外形を変えない。
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: chipBody,
    );
  }
}
