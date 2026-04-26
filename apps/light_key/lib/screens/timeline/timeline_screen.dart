import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../route/app_routes.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('タイムライン'),
        actions: [
          IconButton(
            onPressed: () => context.read<TimelineProvider>().fetch(),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () => context.go('/post'),
            icon: const Icon(Icons.edit_note),
          ),
        ],
      ),
      bottomNavigationBar: const AppNavBar(currentPath: '/timeline'),
      body: switch (state.status) {
        TimelineStatus.loading => const LoadingContent(),
        TimelineStatus.error => ErrorContent(
          message: state.message ?? 'エラーが発生しました。',
          onRetry: () => context.read<TimelineProvider>().fetch(),
        ),
        _ => TimelineList(notes: state.notes, message: state.message),
      },
    );
  }
}
