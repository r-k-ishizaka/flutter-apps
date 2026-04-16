import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'add_todo_effect_state.dart';
import 'add_todo_provider.dart';
import 'add_todo_screen_state.dart';

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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('TODOを追加しました')),
              );
              context.pop();
            }
          });
        },
        failure: (error) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('エラーが発生しました: $error')),
              );
            }
          });
        },
      );
      return null;
    }, [provider.effect]);

    return Scaffold(
      appBar: AppBar(title: const Text('TODO追加')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Builder(
          builder: (_) => state.when(
            stable: () => AddTodoStableScreen(
              controller: controller,
              onChanged: provider.updateText,
              onAdd: () {
                provider.addTodo();
              },
            ),
            updating: () => const AddTodoUpdatingScreen(),
          ),
        ),
      ),
    );
  }
}

class AddTodoStableScreen extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onAdd;
  const AddTodoStableScreen({
    required this.controller,
    required this.onChanged,
    required this.onAdd,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'TODO内容'),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: onAdd, child: const Text('追加')),
      ],
    );
  }
}

class AddTodoUpdatingScreen extends StatelessWidget {
  const AddTodoUpdatingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
