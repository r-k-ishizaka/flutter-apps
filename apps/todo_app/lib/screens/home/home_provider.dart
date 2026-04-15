
import 'package:flutter/material.dart';
import '../../models/todo.dart';
import '../../repositories/todo_repository.dart';

class HomeProvider extends ChangeNotifier {
  final TodoRepository todoRepository;

  HomeProvider(this.todoRepository);

  List<Todo> get todos => todoRepository.todos;
  void addTodo(Todo todo) {
    todoRepository.addTodo(todo);
    notifyListeners();
  }
  void toggleTodo(String id) {
    todoRepository.toggleTodo(id);
    notifyListeners();
  }
  void removeTodo(String id) {
    todoRepository.removeTodo(id);
    notifyListeners();
  }
}
