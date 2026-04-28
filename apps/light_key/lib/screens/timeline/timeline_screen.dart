import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../models/note.dart';
import '../../sheets/reaction_picker_sheet.dart';
import '../../widgets/timeline_list.dart';
import 'timeline_provider.dart';
import 'timeline_screen_state.dart';

class TimelineScreen extends HookWidget {
  const TimelineScreen({super.key});

  void _showComingSoonSnackBar(BuildContext context, String label) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label は準備中です')));
  }

  Future<void> _sendReaction(
    BuildContext context,
    Note note,
    String reaction,
  ) async {
    final message = await context.read<TimelineProvider>().createReaction(
      note,
      reaction,
    );
    if (!context.mounted || message == null) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onNoteReaction(BuildContext context, Note note) async {
    final emoji = await showReactionPickerSheet(context);
    if (emoji == null || !context.mounted) return;
    await _sendReaction(context, note, emoji);
  }

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      final provider = context.read<TimelineProvider>();

      // 初回起動時にリアルタイム購読を開始
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.startRealtime();
      });

      // バックグラウンド移行時に購読停止、フォアグラウンド復帰時に再接続
      // onPause より前の onHide (resumed→inactive→hidden→paused) で止めることで
      // ネットワークが制限される前にWebSocket接続を切断する
      final lifecycleListener = AppLifecycleListener(
        onHide: () => unawaited(provider.stopRealtime()),
        onResume: () => unawaited(provider.startRealtime()),
      );

      return () {
        lifecycleListener.dispose();
        unawaited(provider.stopRealtime());
      };
    }, const []);

    final state = context.watch<TimelineProvider>().state;

    TimelineList buildTimelineList({
      required List<Note> notes,
      required bool isRefreshing,
      required String? message,
    }) {
      return TimelineList(
        notes: notes,
        isRefreshing: isRefreshing,
        message: message,
        onRefresh: () =>
            context.read<TimelineProvider>().fetch(showLoading: false),
        onNoteReply: (note) => _showComingSoonSnackBar(context, 'リプライ'),
        onNoteRenote: (note) => _showComingSoonSnackBar(context, 'リノート'),
        onNoteReaction: (note) => _onNoteReaction(context, note),
        onNoteReactionChipTap: (note, reaction) =>
            _sendReaction(context, note, reaction),
      );
    }

    return switch (state) {
      TimelineScreenStateIdle() => buildTimelineList(
        notes: const <Note>[],
        isRefreshing: false,
        message: null,
      ),
      TimelineScreenStateLoading() => const LoadingContent(),
      TimelineScreenStateLoaded(:final notes, :final isRefreshing, :final message) =>
        buildTimelineList(
          notes: notes,
          isRefreshing: isRefreshing,
          message: message,
        ),
      TimelineScreenStateError(:final message) => ErrorContent(
        message: message ?? 'エラーが発生しました。',
        onRetry: () => context.read<TimelineProvider>().fetch(),
      ),
    };
  }
}
