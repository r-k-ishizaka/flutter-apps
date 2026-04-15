import 'package:flutter/material.dart';

class AddTodoScreen extends StatelessWidget {
  const AddTodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('TODO追加')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'TODO内容'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: const Text('追加'),
            ),
          ],
        ),
      ),
    );
  }
}
