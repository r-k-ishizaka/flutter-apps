import 'package:flutter/material.dart';
import '../models/todo.dart';
import 'todo_item.dart';

class TodoList extends StatelessWidget {
  final List<Todo> todos;
  final void Function(String) onToggle;
  final void Function(String) onDelete;
  final void Function(String id) onRequestNotification;

  const TodoList({
    super.key,
    required this.todos,
    required this.onToggle,
    required this.onDelete,
    required this.onRequestNotification,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return TodoItem(
          todo: todo,
          onToggle: () => onToggle(todo.id),
          onDelete: () => onDelete(todo.id),
          onRequestNotification: onRequestNotification,
        );
      },
    );
  }
}
