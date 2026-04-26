import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../widgets/timeline_list.dart';
import 'timeline_provider.dart';
import 'timeline_screen_state.dart';

class TimelineScreen extends HookWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      final provider = context.read<TimelineProvider>();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.startRealtime();
      });
      return () {
        unawaited(provider.stopRealtime());
      };
    }, const []);

    final state = context.watch<TimelineProvider>().state;

    return switch (state.status) {
      TimelineStatus.loading => const LoadingContent(),
      TimelineStatus.error => ErrorContent(
        message: state.message ?? 'エラーが発生しました。',
        onRetry: () => context.read<TimelineProvider>().fetch(),
      ),
      _ => TimelineList(notes: state.notes, message: state.message),
    };
  }
}
