import '../models/todo.dart' as model;
import 'todo_database.dart';
import 'package:drift/drift.dart';

class TodoDataSource {
  final TodoDatabase db;

  TodoDataSource(this.db);

  // Todo一覧取得
  Future<List<model.Todo>> getTodos() async {
    final entries = await db.select(db.todos).get();
    return entries.map(_fromEntry).toList();
  }

  // Todo追加
  Future<model.Todo> addTodo(model.Todo todo) async {
    final id = await db
        .into(db.todos)
        .insert(
          TodosCompanion(
            title: Value(todo.title),
            completed: Value(todo.isDone),
          ),
        );
    return todo.copyWith(id: id.toString());
  }

  // Todo更新
  Future<void> updateTodo(model.Todo todo) async {
    final intId = int.tryParse(todo.id);
    if (intId == null) return;
    await (db.update(db.todos)..where((tbl) => tbl.id.equals(intId))).write(
      TodosCompanion(title: Value(todo.title), completed: Value(todo.isDone)),
    );
  }

  // Todo削除
  Future<void> deleteTodo(String id) async {
    final intId = int.tryParse(id);
    if (intId == null) return;
    await (db.delete(db.todos)..where((tbl) => tbl.id.equals(intId))).go();
  }

  // DriftのTodoエントリからモデルへの変換
  model.Todo _fromEntry(Todo entry) {
    return model.Todo(
      id: entry.id.toString(),
      title: entry.title,
      isDone: entry.completed,
    );
  }
}
