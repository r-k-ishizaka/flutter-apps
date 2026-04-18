import '../models/todo.dart' as model;
import '../models/schedule_notification.dart';
import 'todo_database.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'dart:convert';

@lazySingleton
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
    await db.into(db.todos).insert(
      TodosCompanion(
        id: Value(todo.id),
        title: Value(todo.title),
        isDone: Value(todo.isDone),
        scheduleNotification: Value(
          todo.scheduleNotification == null
              ? null
              : jsonEncode(todo.scheduleNotification!.toJson()),
        ),
      ),
    );
    return todo;
  }

  // Todo更新
  Future<void> updateTodo(model.Todo todo) async {
    await (db.update(db.todos)..where((tbl) => tbl.id.equals(todo.id))).write(
      TodosCompanion(
        title: Value(todo.title),
        isDone: Value(todo.isDone),
        scheduleNotification: Value(
          todo.scheduleNotification == null
              ? null
              : jsonEncode(todo.scheduleNotification!.toJson()),
        ),
      ),
    );
  }

  // Todo削除
  Future<void> deleteTodo(String id) async {
    await (db.delete(db.todos)..where((tbl) => tbl.id.equals(id))).go();
  }

  // DriftのTodoエントリからモデルへの変換
  model.Todo _fromEntry(Todo entry) {
    return model.Todo(
      id: entry.id,
      title: entry.title,
      isDone: entry.isDone,
      scheduleNotification: entry.scheduleNotification == null
          ? null
          : ScheduleNotification.fromJson(
              Map<String, dynamic>.from(jsonDecode(entry.scheduleNotification!)),
            ),
    );
  }
}
