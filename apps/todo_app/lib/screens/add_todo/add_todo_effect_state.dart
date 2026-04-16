import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_todo_effect_state.freezed.dart';

@freezed
class AddTodoEffectState with _$AddTodoEffectState {
  const factory AddTodoEffectState.none() = AddTodoEffectNoneState;
  const factory AddTodoEffectState.success() = AddTodoEffectSuccessState;
  const factory AddTodoEffectState.failure(String error) = AddTodoEffectFailureState;
}
