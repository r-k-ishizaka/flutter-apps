import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_todo_screen_state.freezed.dart';

@freezed
class AddTodoScreenState with _$AddTodoScreenState {
  const factory AddTodoScreenState.stable() = Stable;
  const factory AddTodoScreenState.updating() = Updating;
}
