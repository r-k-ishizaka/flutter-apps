import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/note.dart';
import '../../models/user_profile.dart';
import '../../sheets/reaction_picker/reaction_picker_sheet.dart';
import '../../widgets/emoji_text.dart';
import '../../widgets/timeline_note_item.dart';
import '../../widgets/user_avatar.dart';
import 'profile_provider.dart';
import 'profile_screen_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final status = context.select<ProfileProvider, ProfileStatus>(
      (p) => p.state.status,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('プロフィール')),
      body: switch (status) {
        ProfileStatus.idle || ProfileStatus.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        ProfileStatus.error => _ProfileError(
          message: context.select<ProfileProvider, String?>(
            (p) => p.state.message,
          ),
          onRetry: () => context.read<ProfileProvider>().load(userId),
        ),
        ProfileStatus.loaded => RefreshIndicator(
          onRefresh: () => context.read<ProfileProvider>().load(userId),
          // 画面全体（NestedScrollView本体）だけでリフレッシュ判定する。
          notificationPredicate: (notification) => notification.depth == 0,
          child: _ProfileContentConsumer(userId: userId),
        ),
      },
    );
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message ?? 'プロフィールの読み込みに失敗しました。'),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('再試行')),
          ],
        ),
      ),
    );
  }
}

/// loaded 状態のみ購読し、profile/notes が変わったときだけ rebuild する。
class _ProfileContentConsumer extends StatelessWidget {
  const _ProfileContentConsumer({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final state = context.select<ProfileProvider, (UserProfile?, List<Note>, List<Note>, List<Note>)>(
      (p) => (p.state.profile, p.state.allNotes, p.state.noteOnlyNotes, p.state.mediaNotes),
    );
    return _ProfileContent(
      profile: state.$1,
      allNotes: state.$2,
      noteOnlyNotes: state.$3,
      mediaNotes: state.$4,
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.profile,
    required this.allNotes,
    required this.noteOnlyNotes,
    required this.mediaNotes,
  });

  final UserProfile? profile;
  final List<Note> allNotes;
  final List<Note> noteOnlyNotes;
  final List<Note> mediaNotes;

  @override
  Widget build(BuildContext context) {
    final user = profile;
    if (user == null) {
      return const Center(child: Text('プロフィール情報がありません。'));
    }

    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: NestedScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          final colorScheme = Theme.of(context).colorScheme;
          return [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _ProfileHeader(profile: user),
                  _ProfileSummary(profile: user),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _ProfileTabBarHeaderDelegate(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(color: colorScheme.outlineVariant),
                    ),
                  ),
                  child: const TabBar(
                    tabs: [
                      Tab(text: '全て'),
                      Tab(text: 'ノート'),
                      Tab(text: 'メディア'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          children: [
            _ProfileNotesTab(
              notes: allNotes,
              emptyMessage: 'ノートがありません。',
              storageKey: 'profile_notes_all',
            ),
            _ProfileNotesTab(
              notes: noteOnlyNotes,
              emptyMessage: '投稿ノートがありません。',
              storageKey: 'profile_notes_only',
            ),
            _ProfileNotesTab(
              notes: mediaNotes,
              emptyMessage: 'メディア付きノートがありません。',
              storageKey: 'profile_notes_media',
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          EmojiText(
            profile.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            '@${profile.username}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          if (profile.roles.isNotEmpty) ...[
            _ProfileRolesChips(roles: profile.roles),
            const SizedBox(height: 12),
          ],
          EmojiText(
            _orFallback(profile.description, '未設定'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          _InfoItem(
            label: '誕生日',
            value: _formatDate(profile.birthday, fallback: '未設定'),
          ),
          const SizedBox(height: 12),
          _InfoItem(
            label: '登録日',
            value: _formatDate(profile.createdAt, fallback: '不明'),
          ),
          const SizedBox(height: 12),
          _CountRow(profile: profile),
        ],
      ),
    );
  }

  static String _orFallback(String? value, String fallback) {
    if (value == null || value.trim().isEmpty) {
      return fallback;
    }
    return value;
  }

  static String _formatDate(DateTime? date, {required String fallback}) {
    if (date == null) {
      return fallback;
    }
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}/$month/$day';
  }
}

class _ProfileNotesTab extends StatelessWidget {
  const _ProfileNotesTab({
    required this.notes,
    required this.emptyMessage,
    required this.storageKey,
  });

  final List<Note> notes;
  final String emptyMessage;
  final String storageKey;

  static Future<void> _onNoteReaction(BuildContext context, Note note) async {
    final emoji = await showReactionPickerSheet(context);
    if (emoji == null || !context.mounted) return;
    final message = await context.read<ProfileProvider>().createReaction(
      note,
      emoji,
    );
    if (!context.mounted || message == null) return;
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  static Future<void> _onReactionChipTap(
    BuildContext context,
    Note note,
    String reaction,
  ) async {
    final message = await context.read<ProfileProvider>().createReaction(
      note,
      reaction,
    );
    if (!context.mounted || message == null) return;
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return CustomScrollView(
        key: PageStorageKey<String>(storageKey),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text(emptyMessage)),
          ),
        ],
      );
    }

    return ListView.builder(
      key: PageStorageKey<String>(storageKey),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return TimelineNoteItem(
          note: note,
          animation: kAlwaysCompleteAnimation,
          onReaction: () => _onNoteReaction(context, note),
          onReactionChipTap: (reaction) =>
              _onReactionChipTap(context, note, reaction),
        );
      },
    );
  }
}

class _ProfileTabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _ProfileTabBarHeaderDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => kTextTabBarHeight;

  @override
  double get maxExtent => kTextTabBarHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(_ProfileTabBarHeaderDelegate oldDelegate) => false;
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: 190,
          width: double.infinity,
          child: profile.bannerUrl == null || profile.bannerUrl!.isEmpty
              ? ColoredBox(color: colorScheme.surfaceContainerHighest)
              : CachedNetworkImage(
                  imageUrl: profile.bannerUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) =>
                      ColoredBox(color: colorScheme.surfaceContainerHighest),
                ),
        ),
        Positioned(
          left: 16,
          bottom: -26,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.surface, width: 3),
            ),
            child: UserAvatar(
              avatarUrl: profile.avatarUrl,
              avatarBlurHash: profile.avatarBlurHash,
              size: 76,
            ),
          ),
        ),
      ],
    );
  }
}

class _CountRow extends StatelessWidget {
  const _CountRow({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CountItem(label: 'ノート', count: profile.notesCount),
        ),
        Expanded(
          child: _CountItem(label: 'フォロー', count: profile.followingCount),
        ),
        Expanded(
          child: _CountItem(label: 'フォロワー', count: profile.followersCount),
        ),
      ],
    );
  }
}

class _ProfileRolesChips extends StatelessWidget {
  const _ProfileRolesChips({required this.roles});

  final List<UserProfileRole> roles;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: roles
          .map(
            (role) => Chip(
              avatar: _buildRoleIcon(role.iconUrl),
              label: Text(
                role.name,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              shape: StadiumBorder(
                side: BorderSide(
                  color:
                      _parseRoleColor(role.color) ??
                      Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              labelPadding: const EdgeInsets.symmetric(
                horizontal: 2,
                vertical: 0,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          )
          .toList(growable: false),
    );
  }

  Widget? _buildRoleIcon(String? iconUrl) {
    if (iconUrl == null || iconUrl.isEmpty) {
      return null;
    }
    return SizedBox.square(
      dimension: 16,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: iconUrl,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  Color? _parseRoleColor(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final hex = value.startsWith('#') ? value.substring(1) : value;
    if (hex.length == 6) {
      final parsed = int.tryParse('FF$hex', radix: 16);
      return parsed == null ? null : Color(parsed);
    }
    if (hex.length == 8) {
      final parsed = int.tryParse(hex, radix: 16);
      return parsed == null ? null : Color(parsed);
    }
    return null;
  }
}

class _CountItem extends StatelessWidget {
  const _CountItem({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(count.toString(), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({this.label, required this.value});

  final String? label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final hasLabel = label != null && label!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasLabel) ...[
          Text(label!, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
        ],
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
