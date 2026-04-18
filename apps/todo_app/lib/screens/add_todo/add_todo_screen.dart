import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'add_todo_effect_state.dart';
import 'add_todo_provider.dart';
import 'add_todo_screen_state.dart';
import '../../models/schedule_notification.dart';
import '../../widgets/schedule_notification_input.dart';

class AddTodoScreen extends HookWidget {
  const AddTodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AddTodoProvider>(context);
    final controller = useTextEditingController(text: provider.todoText);
    final state = provider.state;

    useEffect(() {
      final effect = provider.effect;
      provider.clearEffect();
      effect.when(
        none: () {},
        success: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('TODOを追加しました')));
              context.pop();
            }
          });
        },
        failure: (error) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('エラーが発生しました: $error')));
            }
          });
        },
      );
      return null;
    }, [provider.effect]);

    return Scaffold(
      appBar: AppBar(title: const Text('TODO追加')),
      body: _StableScreen(
        controller: controller,
        onChanged: provider.updateText,
        onAdd: () {
          provider.addTodo();
        },
        isLoading: state.maybeWhen(updating: () => true, orElse: () => false),
        scheduleNotification: provider.scheduleNotification,
        onScheduleNotificationChanged: provider.updateScheduleNotification,
      ),
    );
  }
}

class _StableScreen extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onAdd;
  final bool isLoading;
  final ScheduleNotification? scheduleNotification;
  final ValueChanged<ScheduleNotification?> onScheduleNotificationChanged;
  const _StableScreen({
    required this.controller,
    required this.onChanged,
    required this.onAdd,
    required this.isLoading,
    required this.scheduleNotification,
    required this.onScheduleNotificationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'TODO内容'),
            onChanged: onChanged,
          ),
          const SizedBox(height: 16),
          // 通知スケジュールUI
          ScheduleNotificationInput(
            value: scheduleNotification,
            onChanged: onScheduleNotificationChanged,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onAdd, child: const Text('追加')),
        ],
      ),
    );
    if (!isLoading) return content;
    return Stack(
      children: [
        content,
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey.withAlpha(128),
          child: const Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}

// ...existing code...
