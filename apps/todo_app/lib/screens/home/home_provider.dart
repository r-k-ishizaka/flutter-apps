
import 'package:flutter/material.dart';
import '../../models/todo.dart';
import '../../repositories/todo_repository.dart';

class HomeProvider extends ChangeNotifier {
  final TodoRepository todoRepository;

  HomeProvider(this.todoRepository) {
    fetchTodos();
  }

  List<Todo> _todos = [];
  List<Todo> get todos => List.unmodifiable(_todos);

  Future<void> fetchTodos() async {
    _todos = await todoRepository.getTodos();
    notifyListeners();
  }

  Future<void> addTodo(Todo todo) async {
    await todoRepository.addTodo(todo);
    await fetchTodos();
  }

  Future<void> toggleTodo(String id) async {
    final todo = _todos.firstWhere((t) => t.id == id);
    await todoRepository.updateTodo(todo.copyWith(isDone: !todo.isDone));
    await fetchTodos();
  }

  Future<void> removeTodo(String id) async {
    await todoRepository.removeTodo(id);
    await fetchTodos();
  }
}
