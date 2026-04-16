import '../models/todo.dart';
import 'package:injectable/injectable.dart';
import '../datasources/todo_data_source.dart';

@injectable
class TodoRepository {
  final TodoDataSource dataSource;

  TodoRepository(this.dataSource);

  Future<List<Todo>> getTodos() => dataSource.getTodos();

  Future<Todo> addTodo(Todo todo) => dataSource.addTodo(todo);

  Future<void> updateTodo(Todo todo) => dataSource.updateTodo(todo);

  Future<void> removeTodo(String id) => dataSource.deleteTodo(id);
}
