import '../models/todo.dart' as model;

abstract class TodoDataSource {
  Future<List<model.Todo>> getTodos();
  Future<model.Todo> addTodo(model.Todo todo);
  Future<void> updateTodo(model.Todo todo);
  Future<void> deleteTodo(String id);
}
