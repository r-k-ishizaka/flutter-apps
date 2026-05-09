import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../models/note.dart';
import '../../services/emoji_cache.dart';
import '../../widgets/timeline_list.dart';
import 'timeline_note_actions.dart';
import 'timeline_provider.dart';
import 'timeline_screen_state.dart';

class TimelineScreen extends HookWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emojiCache = context.read<EmojiCache>().entries;
    final provider = context.watch<TimelineProvider>();
    final state = provider.state;

    // アクションをuseMemoizedで作成（providerが変わらない限り同じインスタンスを使う）
    final actions = useMemoized(
      () => TimelineNoteActions(
        provider: provider,
        context: context,
      ),
      [provider],
    );

    useEffect(() {
      final timelineProvider = context.read<TimelineProvider>();

      // 初回起動時にリアルタイム購読を開始
      WidgetsBinding.instance.addPostFrameCallback((_) {
        timelineProvider.startRealtime();
      });

      // バックグラウンド移行時に購読停止、フォアグラウンド復帰時に再接続
      // onPause より前の onHide (resumed→inactive→hidden→paused) で止めることで
      // ネットワークが制限される前にWebSocket接続を切断する
      final lifecycleListener = AppLifecycleListener(
        onHide: () => unawaited(timelineProvider.stopRealtime()),
        onResume: () => unawaited(timelineProvider.startRealtime()),
      );

      return () {
        lifecycleListener.dispose();
        unawaited(timelineProvider.stopRealtime());
      };
    }, const []);

    TimelineList buildTimelineList({
      required List<Note> notes,
      required bool isRefreshing,
      required String? message,
    }) {
      return TimelineList(
        notes: notes,
        emojis: emojiCache,
        actions: actions,
        isRefreshing: isRefreshing,
        message: message,
        onRefresh: () => provider.fetch(showLoading: false),
      );
    }

    return switch (state) {
      TimelineScreenStateIdle() => buildTimelineList(
        notes: const <Note>[],
        isRefreshing: false,
        message: null,
      ),
      TimelineScreenStateLoading() => const LoadingContent(),
      TimelineScreenStateLoaded(
        :final notes,
        :final isRefreshing,
        :final message,
      ) =>
        buildTimelineList(
          notes: notes,
          isRefreshing: isRefreshing,
          message: message,
        ),
      TimelineScreenStateError(:final message) => ErrorContent(
        message: message ?? 'エラーが発生しました。',
        onRetry: () => provider.fetch(),
      ),
    };
  }
}
