import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'add_todo_provider.dart';

class AddTodoScreen extends HookWidget {
  const AddTodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AddTodoProvider>(context);
    final controller = useTextEditingController(text: provider.todoText);

    return Scaffold(
      appBar: AppBar(title: const Text('TODO追加')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'TODO内容'),
              onChanged: provider.updateText,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final text = provider.validText;
                if (text.isNotEmpty) {
                  provider.clear();
                  context.pop(text);
                }
              },
              child: const Text('追加'),
            ),
          ],
        ),
      ),
    );
  }
}
