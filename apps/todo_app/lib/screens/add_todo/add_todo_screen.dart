import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'add_todo_provider.dart';

class AddTodoScreen extends StatelessWidget {
  const AddTodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AddTodoProvider>(context);
    final controller = TextEditingController(text: provider.todoText);
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
                Navigator.of(context).pop(controller.text);
                provider.clear();
              },
              child: const Text('追加'),
            ),
          ],
        ),
      ),
    );
  }
}
