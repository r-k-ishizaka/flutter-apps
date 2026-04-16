
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../models/todo.dart';

part 'home_screen_state.freezed.dart';

@freezed
class HomeScreenState with _$HomeScreenState {
  const factory HomeScreenState.loading() = Loading;
  const factory HomeScreenState.success(List<Todo> todos) = Success;
  const factory HomeScreenState.failure(Exception exception) = Failure;
}
