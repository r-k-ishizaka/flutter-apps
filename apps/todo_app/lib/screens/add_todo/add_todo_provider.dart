import 'package:core/models/result.dart';
import '../../repositories/todo_repository.dart';
import '../../models/todo.dart';
import 'package:flutter/material.dart';
import 'add_todo_screen_state.dart'; // Moved to the correct position

import 'add_todo_effect_state.dart';

class AddTodoProvider extends ChangeNotifier {
  // 副作用通知用
  AddTodoEffectState _effect = const AddTodoEffectState.none();
  AddTodoEffectState get effect => _effect;
  void clearEffect() {
    _effect = const AddTodoEffectState.none();
  }

  final TodoRepository todoRepository;

  AddTodoProvider(this.todoRepository);

  AddTodoScreenState _state = const AddTodoScreenState.stable();
  AddTodoScreenState get state => _state;

  String _todoText = '';
  String get todoText => _todoText;
  String get validText => _todoText.trim();

  void _updateState(AddTodoScreenState state) {
    _state = state;
    notifyListeners();
  }

  void updateText(String text) {
    _todoText = text;
    _updateState(const AddTodoScreenState.stable());
  }

  void clear() {
    _todoText = '';
    _updateState(const AddTodoScreenState.stable());
  }

  Future<void> addTodo() async {
    final text = validText;
    if (text.isEmpty) return;
    _updateState(const AddTodoScreenState.updating());
    final result = await todoRepository.addTodo(
      Todo(id: DateTime.now().toString(), title: text),
    );
    result.when(
      success: (_) {
        clear();
        _effect = const AddTodoEffectState.success();
        notifyListeners();
      },
      failure: (error, _) {
        _effect = AddTodoEffectState.failure(error.toString());
        notifyListeners();
      },
    );
  }
}

