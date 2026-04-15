import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_routes.dart';
import 'home_provider.dart';
import '../../widgets/todo_list.dart';
import '../../models/todo.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context);
    final todos = provider.todos;

    return Scaffold(
      appBar: AppBar(title: const Text('TODOアプリ')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Expanded(child: SizedBox()),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    final result = await const AddTodoRoute().push<String>(
                      context,
                    );
                    if (result != null && result.isNotEmpty) {
                      provider.addTodo(
                        Todo(id: DateTime.now().toString(), title: result),
                      );
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
