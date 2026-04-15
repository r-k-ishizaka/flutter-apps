import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_list.dart';
import '../models/todo.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TodoProvider>(context);
    final todos = provider.todos;
    final controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('TODOアプリ')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: '新しいTODOを入力'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      provider.addTodo(Todo(
                        id: DateTime.now().toString(),
                        title: controller.text,
                      ));
                      controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: TodoList(
              todos: todos,
              onToggle: provider.toggleTodo,
              onDelete: provider.removeTodo,
            ),
          ),
        ],
      ),
    );
  }
}
