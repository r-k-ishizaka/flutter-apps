import '../models/todo.dart';
import 'package:injectable/injectable.dart';
import '../datasources/todo_data_source.dart';
import 'package:core/models/result.dart';

@injectable
class TodoRepository {
  final TodoDataSource dataSource;

  TodoRepository(this.dataSource);

  Future<Result<List<Todo>>> getTodos() async {
    try {
      final result = await dataSource.getTodos();
      return Success(result);
    } on Exception catch (e) {
      return Failure(e);
    }
  }

  Future<Result<Todo>> addTodo(Todo todo) async {
    try {
      final result = await dataSource.addTodo(todo);
      return Success(result);
    } on Exception catch (e) {
      return Failure(e);
    }
  }

  Future<Result<void>> updateTodo(Todo todo) async {
    try {
      await dataSource.updateTodo(todo);
      return Success(null);
    } on Exception catch (e) {
      return Failure(e);
    }
  }

  Future<Result<void>> removeTodo(String id) async {
    try {
      await dataSource.deleteTodo(id);
      return Success(null);
    } on Exception catch (e) {
      return Failure(e);
    }
  }
}
