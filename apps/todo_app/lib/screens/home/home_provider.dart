import 'package:core/models/result.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/screens/home/home_screen_state.dart'
    hide Success, Failure;
import '../../models/todo.dart';
import '../../repositories/todo_repository.dart';

class HomeProvider extends ChangeNotifier {
  final TodoRepository todoRepository;

  HomeProvider(this.todoRepository) {
    fetchTodos();
  }

  HomeScreenState _state = const HomeScreenState.loading();
  HomeScreenState get state => _state;

  void _updateState(HomeScreenState state) {
    _state = state;
    notifyListeners();
  }

  void initialize() {
    _state = const HomeScreenState.loading();
    fetchTodos();
  }

  void fetchTodos() async {
    final result = await todoRepository.getTodos();
    switch (result) {
      case Success<List<Todo>>():
        _updateState(HomeScreenState.success(result.value));
      case Failure<List<Todo>>():
        _updateState(HomeScreenState.failure(result.error));
    }
  }

  void toggleTodo(String id) async {
    state.maybeWhen(
      success: (todos) async {
        final todo = todos.firstWhere((t) => t.id == id);
        await todoRepository.updateTodo(todo.copyWith(isDone: !todo.isDone));
        fetchTodos();
      },
      orElse: () => {/* no-op */},
    );
  }

  void removeTodo(String id) async {
    await todoRepository.removeTodo(id);
    fetchTodos();
  }
}
