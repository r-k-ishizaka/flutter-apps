import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

import '../../models/misskey_notification.dart';
import '../../models/user.dart';
import '../../services/emoji_cache.dart';
import '../../widgets/emoji_text.dart';
import '../../widgets/note_actions/note_actions.dart';
import '../../widgets/timeline_note_item.dart';

/// 通知一覧の個別アイテム Widget
class NotificationItem extends StatelessWidget {
  const NotificationItem({
    required this.notification,
    required this.emojis,
    this.actions,
    this.onUserTap,
    this.onNoteTap,
    super.key,
  });

  final MisskeyNotification notification;
  final Map<String, EmojiCacheEntry> emojis;
  final NoteActions? actions;
  final ValueChanged<User>? onUserTap;
  final ValueChanged<String>? onNoteTap;

  @override
  Widget build(BuildContext context) {
    return switch (notification) {
      final FollowNotification n => _FollowItem(
        notification: n,
        emojis: emojis,
        onUserTap: onUserTap,
      ),
      final ReplyNotification n => _ReplyItem(
        notification: n,
        emojis: emojis,
        actions: actions,
      ),
      final MentionNotification n => _MentionItem(
        notification: n,
        emojis: emojis,
        actions: actions,
      ),
      final RenoteNotification n => _RenoteItem(
        notification: n,
        emojis: emojis,
        onUserTap: onUserTap,
        onNoteTap: onNoteTap,
      ),
      final QuoteNotification n => _QuoteItem(
        notification: n,
        emojis: emojis,
        actions: actions,
      ),
      final ReactionNotification n => _ReactionItem(
        notification: n,
        emojis: emojis,
        onUserTap: onUserTap,
        onNoteTap: onNoteTap,
      ),
      final ReactionGroupedNotification n => _ReactionGroupedItem(
        notification: n,
        emojis: emojis,
        onUserTap: onUserTap,
        onNoteTap: onNoteTap,
      ),
      final FollowRequestAcceptedNotification n => _FollowRequestAcceptedItem(
        notification: n,
        emojis: emojis,
        onUserTap: onUserTap,
      ),
      final PollEndedNotification n => _PollEndedItem(
        notification: n,
        emojis: emojis,
        onNoteTap: onNoteTap,
      ),
      final LoginNotification n => _LoginItem(notification: n),
      final UnknownNotification n => _UnknownItem(notification: n),
    };
  }
}

// ---------------------------------------------------------------------------
// フォロー通知
// ---------------------------------------------------------------------------
class _FollowItem extends StatelessWidget {
  const _FollowItem({
    required this.notification,
    required this.emojis,
    this.onUserTap,
  });

  final FollowNotification notification;
  final Map<String, EmojiCacheEntry> emojis;
  final ValueChanged<User>? onUserTap;

  @override
  Widget build(BuildContext context) {
    return _BaseItem(
      leading: _AvatarWithBadge(
        user: notification.user,
        badge: const Icon(Icons.person_add, size: 16, color: Colors.white),
        badgeColor: Colors.blue,
        onTap: onUserTap,
      ),
      createdAt: notification.createdAt,
      title: _UserNameText(
        user: notification.user,
        suffix: ' さんにフォローされました',
        emojis: emojis,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// フォローリクエスト承認通知
// ---------------------------------------------------------------------------
class _FollowRequestAcceptedItem extends StatelessWidget {
  const _FollowRequestAcceptedItem({
    required this.notification,
    required this.emojis,
    this.onUserTap,
  });

  final FollowRequestAcceptedNotification notification;
  final Map<String, EmojiCacheEntry> emojis;
  final ValueChanged<User>? onUserTap;

  @override
  Widget build(BuildContext context) {
    return _BaseItem(
      leading: _AvatarWithBadge(
        user: notification.user,
        badge: const Icon(Icons.check, size: 16, color: Colors.white),
        badgeColor: Colors.green,
        onTap: onUserTap,
      ),
      createdAt: notification.createdAt,
      title: _UserNameText(
        user: notification.user,
        suffix: ' さんにフォローリクエストが承認されました',
        emojis: emojis,
      ),
      subtitle: notification.message != null && notification.message!.isNotEmpty
          ? Text(
              notification.message!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            )
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// リプライ通知
// ---------------------------------------------------------------------------
class _ReplyItem extends StatelessWidget {
  const _ReplyItem({
    required this.notification,
    required this.emojis,
    this.actions,
  });

  final ReplyNotification notification;
  final Map<String, EmojiCacheEntry> emojis;
  final NoteActions? actions;

  @override
  Widget build(BuildContext context) {
    return TimelineNoteItem(
      note: notification.note,
      animation: kAlwaysCompleteAnimation,
      emojis: emojis,
      actions: actions,
    );
  }
}

// ---------------------------------------------------------------------------
// メンション通知
// ---------------------------------------------------------------------------
class _MentionItem extends StatelessWidget {
  const _MentionItem({
    required this.notification,
    required this.emojis,
    this.actions,
  });

  final MentionNotification notification;
  final Map<String, EmojiCacheEntry> emojis;
  final NoteActions? actions;

  @override
  Widget build(BuildContext context) {
    return TimelineNoteItem(
      note: notification.note,
      animation: kAlwaysCompleteAnimation,
      emojis: emojis,
      actions: actions,
    );
  }
}

// ---------------------------------------------------------------------------
// リノート通知
// ---------------------------------------------------------------------------
class _RenoteItem extends StatelessWidget {
  const _RenoteItem({
    required this.notification,
    required this.emojis,
    this.onUserTap,
    this.onNoteTap,
  });

  final RenoteNotification notification;
  final Map<String, EmojiCacheEntry> emojis;
  final ValueChanged<User>? onUserTap;
  final ValueChanged<String>? onNoteTap;

  @override
  Widget build(BuildContext context) {
    final previewNote =
        notification.note.text.isEmpty && notification.note.renote != null
        ? notification.note.renote!
        : notification.note;
    final previewText = previewNote.text.isNotEmpty ? previewNote.text : '(本文なし)';

    return _BaseItem(
      leading: _AvatarWithBadge(
        user: notification.user,
        badge: const Icon(Icons.repeat, size: 15, color: Colors.white),
        badgeColor: Colors.green,
        onTap: onUserTap,
      ),
      createdAt: notification.createdAt,
      title: _UserNameText(
        user: notification.user,
        suffix: ' さんがリノートしました',
        emojis: emojis,
      ),
      subtitle: _NotePreview(
        text: previewText,
        emojis: emojis,
        noteId: previewNote.id,
        onTap: onNoteTap,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 引用通知
// ---------------------------------------------------------------------------
class _QuoteItem extends StatelessWidget {
  const _QuoteItem({
    required this.notification,
    required this.emojis,
    this.actions,
  });

  final QuoteNotification notification;
  final Map<String, EmojiCacheEntry> emojis;
  final NoteActions? actions;

  @override
  Widget build(BuildContext context) {
    return TimelineNoteItem(
      note: notification.note,
      animation: kAlwaysCompleteAnimation,
      emojis: emojis,
      actions: actions,
    );
  }
}

// ---------------------------------------------------------------------------
// リアクション通知（単一）
// ---------------------------------------------------------------------------
class _ReactionItem extends StatelessWidget {
  const _ReactionItem({
    required this.notification,
    required this.emojis,
    this.onUserTap,
    this.onNoteTap,
  });

  final ReactionNotification notification;
  final Map<String, EmojiCacheEntry> emojis;
  final ValueChanged<User>? onUserTap;
  final ValueChanged<String>? onNoteTap;

  @override
  Widget build(BuildContext context) {
    return _BaseItem(
      leading: _AvatarWithBadge(
        user: notification.user,
        badge: EmojiText(
          notification.reaction,
          emojis: emojis,
          emojiSize: 11,
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: const TextStyle(fontSize: 9, height: 1),
        ),
        badgeColor: Theme.of(context).scaffoldBackgroundColor,
        onTap: onUserTap,
      ),
      createdAt: notification.createdAt,
      title: _UserNameText(
        user: notification.user,
        suffix: ' さんがリアクションしました',
        emojis: emojis,
      ),
      subtitle: _NotePreview(
        text: notification.note.text,
        emojis: emojis,
        noteId: notification.note.id,
        onTap: onNoteTap,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// リアクション通知（グループ化）
// ---------------------------------------------------------------------------
class _ReactionGroupedItem extends StatelessWidget {
  const _ReactionGroupedItem({
    required this.notification,
    required this.emojis,
    this.onUserTap,
    this.onNoteTap,
  });

  final ReactionGroupedNotification notification;
  final Map<String, EmojiCacheEntry> emojis;
  final ValueChanged<User>? onUserTap;
  final ValueChanged<String>? onNoteTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final leadingUser = notification.reactions.isNotEmpty
        ? notification.reactions.first.user
        : const User();
    final leadingReaction = notification.reactions.isNotEmpty
        ? notification.reactions.first.reaction
        : '';

    return _BaseItem(
      leading: _AvatarWithBadge(
        user: leadingUser,
        badge: leadingReaction.isNotEmpty
            ? EmojiText(
                leadingReaction,
                emojis: emojis,
                emojiSize: 11,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: const TextStyle(fontSize: 9, height: 1),
              )
            : const Icon(Icons.auto_awesome, size: 14, color: Colors.white),
        badgeColor: leadingReaction.isNotEmpty
            ? Theme.of(context).scaffoldBackgroundColor
            : Colors.orange,
        onTap: onUserTap,
      ),
      createdAt: notification.createdAt,
      title: Text(
        '${notification.reactions.length}件のリアクション',
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (notification.note.text.isNotEmpty) ...[
            _NotePreview(
              text: notification.note.text,
              emojis: emojis,
              noteId: notification.note.id,
              onTap: onNoteTap,
            ),
          ],
          if (notification.reactions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: notification.reactions
                  .map(
                    (item) => _AvatarWithBadge(
                      user: item.user,
                      badge: EmojiText(
                        item.reaction,
                        emojis: emojis,
                        emojiSize: 11,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: const TextStyle(fontSize: 9, height: 1),
                      ),
                      badgeColor: Theme.of(context).scaffoldBackgroundColor,
                      onTap: onUserTap,
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 投票終了通知
// ---------------------------------------------------------------------------
class _PollEndedItem extends StatelessWidget {
  const _PollEndedItem({
    required this.notification,
    required this.emojis,
    this.onNoteTap,
  });

  final PollEndedNotification notification;
  final Map<String, EmojiCacheEntry> emojis;
  final ValueChanged<String>? onNoteTap;

  @override
  Widget build(BuildContext context) {
    return _BaseItem(
      leading: const CircleAvatar(
        radius: 20,
        backgroundColor: Colors.deepOrange,
        child: Icon(Icons.poll, size: 20, color: Colors.white),
      ),
      createdAt: notification.createdAt,
      title: Text('投票が終了しました', style: Theme.of(context).textTheme.bodyMedium),
      subtitle: _NotePreview(
        text: notification.note.text,
        emojis: emojis,
        noteId: notification.note.id,
        onTap: onNoteTap,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ログイン通知
// ---------------------------------------------------------------------------
class _LoginItem extends StatelessWidget {
  const _LoginItem({required this.notification});

  final LoginNotification notification;

  @override
  Widget build(BuildContext context) {
    return _BaseItem(
      leading: const CircleAvatar(
        radius: 20,
        backgroundColor: Colors.blueGrey,
        child: Icon(Icons.login, size: 20, color: Colors.white),
      ),
      createdAt: notification.createdAt,
      title: Text('ログイン通知', style: Theme.of(context).textTheme.bodyMedium),
      subtitle: Text(
        notification.message?.isNotEmpty == true
            ? notification.message!
            : '新しいログインが検出されました',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 未対応通知
// ---------------------------------------------------------------------------
class _UnknownItem extends StatelessWidget {
  const _UnknownItem({required this.notification});

  final UnknownNotification notification;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.notifications_none, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              notification.type,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ベースレイアウト
// ---------------------------------------------------------------------------
class _BaseItem extends StatelessWidget {
  const _BaseItem({
    required this.leading,
    required this.title,
    required this.createdAt,
    this.subtitle,
  });

  final Widget leading;
  final Widget title;
  final DateTime createdAt;
  final Widget? subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Align(alignment: Alignment.topCenter, child: leading),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: title),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(createdAt),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (subtitle != null) ...[const SizedBox(height: 4), subtitle!],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// アバター（バッジ付き）
// ---------------------------------------------------------------------------
class _AvatarWithBadge extends StatelessWidget {
  const _AvatarWithBadge({
    required this.user,
    this.badge,
    required this.badgeColor,
    this.onTap,
  });

  final User user;
  final Widget? badge;
  final Color badgeColor;
  final ValueChanged<User>? onTap;

  @override
  Widget build(BuildContext context) {
    final avatar = Stack(
      clipBehavior: Clip.none,
      children: [
        _UserAvatar(user: user, radius: 20),
        Positioned(
          bottom: -4,
          right: -4,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.surface,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: badge ?? const SizedBox.shrink(),
          ),
        ),
      ],
    );

    final handleTap = onTap;
    if (user.id.isEmpty || handleTap == null) {
      return avatar;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => handleTap(user),
        child: avatar,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ユーザーアバター
// ---------------------------------------------------------------------------
class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.user, this.radius = 20});

  final User user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = user.avatarUrl;
    final blurHash = user.avatarBlurHash;

    if (url == null || url.isEmpty) {
      return CircleAvatar(
        radius: radius,
        child: Text(
          (user.name.isNotEmpty ? user.name : user.username).characters
              .take(1)
              .toString(),
          style: TextStyle(fontSize: radius * 0.6),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: (context, url) => blurHash != null && blurHash.isNotEmpty
              ? BlurHash(hash: blurHash)
              : const SizedBox.shrink(),
          errorWidget: (context, url, error) => const Icon(Icons.person),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ノートテキストプレビュー
// ---------------------------------------------------------------------------
class _NotePreview extends StatelessWidget {
  const _NotePreview({
    required this.text,
    required this.emojis,
    this.noteId = '',
    this.onTap,
  });

  final String text;
  final Map<String, EmojiCacheEntry> emojis;
  final String noteId;
  final ValueChanged<String>? onTap;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    final handleTap = onTap;
    final isInteractive = noteId.isNotEmpty && handleTap != null;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final quoteBackground = colorScheme.onSurface.withValues(
      alpha: isInteractive ? 0.08 : 0.05,
    );
    final quoteBorder = colorScheme.onSurfaceVariant.withValues(alpha: 0.45);

    final preview = IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 3,
            child: DecoratedBox(decoration: BoxDecoration(color: quoteBorder)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: quoteBackground,
                borderRadius: BorderRadius.circular(6),
              ),
              child: EmojiText(
                text,
                emojis: emojis,
                emojiSize: 14,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.84),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (!isInteractive) {
      return preview;
    }

    return Semantics(
      button: true,
      label: 'ノート詳細を開く',
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => handleTap(noteId),
          mouseCursor: SystemMouseCursors.click,
          child: preview,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ユーザー名テキスト
// ---------------------------------------------------------------------------
class _UserNameText extends StatelessWidget {
  const _UserNameText({
    required this.user,
    required this.suffix,
    required this.emojis,
  });

  final User user;
  final String suffix;
  final Map<String, EmojiCacheEntry> emojis;

  @override
  Widget build(BuildContext context) {
    final displayName = user.name.isNotEmpty ? user.name : user.username;
    return EmojiText(
      '$displayName$suffix',
      emojis: emojis,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}

// ---------------------------------------------------------------------------
// ヘルパー
// ---------------------------------------------------------------------------

String _formatDate(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inSeconds < 60) return '今';
  if (diff.inMinutes < 60) return '${diff.inMinutes}分前';
  if (diff.inHours < 24) return '${diff.inHours}時間前';
  if (diff.inDays < 7) return '${diff.inDays}日前';
  return '${dt.month}/${dt.day}';
}
