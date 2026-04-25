import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/note.dart';
import '../../route/app_routes.dart';
import 'timeline_provider.dart';
import 'timeline_screen_state.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimelineProvider>().fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
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
        TimelineStatus.loading => const Center(child: CircularProgressIndicator()),
        TimelineStatus.error => Center(child: Text(state.message ?? 'エラーが発生しました。')),
        _ => _TimelineList(notes: state.notes, message: state.message),
      },
    );
  }
}

class _TimelineList extends StatelessWidget {
  const _TimelineList({required this.notes, this.message});

  final List<Note> notes;
  final String? message;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return Center(
        child: Text(message ?? '投稿がありません。認証後に再取得してください。'),
      );
    }

    return ListView.separated(
      itemCount: notes.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          title: Text('@${note.user.username}'),
          subtitle: Text(note.text.isEmpty ? '(本文なし)' : note.text),
          trailing: Text(
            '${note.createdAt.month}/${note.createdAt.day} ${note.createdAt.hour}:${note.createdAt.minute.toString().padLeft(2, '0')}',
          ),
        );
      },
    );
  }
}
