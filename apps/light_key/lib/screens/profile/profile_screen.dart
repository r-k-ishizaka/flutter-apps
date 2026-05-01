import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_profile.dart';
import '../../widgets/emoji_text.dart';
import '../../widgets/user_avatar.dart';
import 'profile_provider.dart';
import 'profile_screen_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProfileProvider>().state;

    return Scaffold(
      appBar: AppBar(title: const Text('プロフィール')),
      body: switch (state.status) {
        ProfileStatus.idle || ProfileStatus.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        ProfileStatus.error => _ProfileError(
          message: state.message,
          onRetry: () => context.read<ProfileProvider>().load(userId),
        ),
        ProfileStatus.loaded => _ProfileContent(profile: state.profile),
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

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.profile});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final user = profile;
    if (user == null) {
      return const Center(child: Text('プロフィール情報がありません。'));
    }

    return ListView(
      children: [
        _ProfileHeader(profile: user),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                EmojiText(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '@${user.username}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 12),
              if (user.roles.isNotEmpty) ...[
                _ProfileRolesChips(roles: user.roles),
                const SizedBox(height: 12),
              ],
              EmojiText(
                _orFallback(user.description, '未設定'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              _InfoItem(
                label: '誕生日',
                value: _formatDate(user.birthday, fallback: '未設定'),
              ),
              const SizedBox(height: 12),
              _InfoItem(
                label: '登録日',
                value: _formatDate(user.createdAt, fallback: '不明'),
              ),
              const SizedBox(height: 12),
              _CountRow(profile: user),
            ],
          ),
        ),
      ],
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
