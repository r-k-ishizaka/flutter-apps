import '../../repositories/todo_repository.dart';
import '../../models/todo.dart';
import 'package:flutter/material.dart';

class AddTodoProvider extends ChangeNotifier {
  final TodoRepository todoRepository;

  AddTodoProvider(this.todoRepository);
  String get validText => _todoText.trim();

  void addTodo() {
    final text = validText;
    if (text.isNotEmpty) {
      todoRepository.addTodo(Todo(id: DateTime.now().toString(), title: text));
      clear();
    }
  }

  String _todoText = '';

  String get todoText => _todoText;

  void updateText(String text) {
    _todoText = text;
    notifyListeners();
  }

  void clear() {
    _todoText = '';
    notifyListeners();
  }
}
