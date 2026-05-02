import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../models/misskey_notification.dart';
import '../../services/emoji_cache.dart';
import 'notification_item.dart';
import 'notifications_provider.dart';
import 'notifications_screen_state.dart';

class NotificationsScreen extends HookWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<NotificationsProvider>();
        if (provider.state is NotificationsScreenStateIdle) {
          provider.fetch();
        }
      });
      return null;
    }, const []);

    final state = context.watch<NotificationsProvider>().state;

    return switch (state) {
      NotificationsScreenStateIdle() ||
      NotificationsScreenStateLoading() =>
        const LoadingContent(),
      NotificationsScreenStateError(:final message) => ErrorContent(
          message: message ?? 'エラーが発生しました。',
          onRetry: () => context.read<NotificationsProvider>().fetch(),
        ),
      NotificationsScreenStateLoaded(
        :final notifications,
        :final isLoadingMore,
        :final hasMore,
        :final message,
      ) =>
        _NotificationList(
          notifications: notifications,
          isLoadingMore: isLoadingMore,
          hasMore: hasMore,
          errorMessage: message,
          onRefresh: () =>
              context.read<NotificationsProvider>().fetch(showLoading: false),
          onLoadMore: () => context.read<NotificationsProvider>().fetchMore(),
        ),
    };
  }
}

class _NotificationList extends HookWidget {
  const _NotificationList({
    required this.notifications,
    required this.isLoadingMore,
    required this.hasMore,
    required this.onRefresh,
    required this.onLoadMore,
    this.errorMessage,
  });

  final List<MisskeyNotification> notifications;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    final emojis = context.read<EmojiCache>().entries;

    useEffect(() {
      void listener() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          onLoadMore();
        }
      }

      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [onLoadMore]);

    if (notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '通知はありません',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Column(
        children: [
          if (errorMessage != null)
            Material(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onErrorContainer,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: notifications.length + (isLoadingMore ? 1 : 0),
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index == notifications.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return NotificationItem(
                  notification: notifications[index],
                  emojis: emojis,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
