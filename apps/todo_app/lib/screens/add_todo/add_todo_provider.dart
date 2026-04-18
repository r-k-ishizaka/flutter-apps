import '../../models/schedule_notification.dart';
import '../../repositories/todo_repository.dart';
import '../../models/todo.dart';
import 'package:flutter/material.dart';
import 'add_todo_screen_state.dart';
import 'add_todo_effect_state.dart';

class AddTodoProvider extends ChangeNotifier {
  // --- フィールド ---
  final TodoRepository todoRepository;
  Todo _input = Todo(id: '', title: '');
  AddTodoScreenState _state = const AddTodoScreenState.stable();
  AddTodoEffectState _effect = const AddTodoEffectState.none();

  // --- コンストラクタ ---
  AddTodoProvider(this.todoRepository);

  // --- getter ---
  Todo get input => _input;
  AddTodoScreenState get state => _state;
  AddTodoEffectState get effect => _effect;
  String get todoText => _input.title;
  ScheduleNotification? get scheduleNotification => _input.scheduleNotification;
  String get validText => _input.title.trim();

  // --- 状態管理 ---
  void _updateState(AddTodoScreenState state) {
    _state = state;
    notifyListeners();
  }
  void clearText() {
    _input = _input.copyWith(title: '');
    _updateState(const AddTodoScreenState.stable());
  }
  void clearEffect() {
    _effect = const AddTodoEffectState.none();
  }

  // --- UI連携メソッド ---
  void updateInput(Todo input) {
    _input = input;
    _updateState(const AddTodoScreenState.stable());
  }
  void updateText(String text) {
    updateInput(_input.copyWith(title: text));
  }
  void updateScheduleNotification(ScheduleNotification? notification) {
    updateInput(_input.copyWith(scheduleNotification: notification));
  }

  // --- メイン処理 ---
  Future<void> addTodo() async {
    final text = validText;
    if (text.isEmpty) return;
    _updateState(const AddTodoScreenState.updating());
    final todo = _input.copyWith(id: DateTime.now().toString(), title: text);
    final result = await todoRepository.addTodo(todo);
    result.when(
      success: (_) {
        clearText();
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
