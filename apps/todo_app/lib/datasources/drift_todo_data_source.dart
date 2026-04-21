import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../models/schedule_notification.dart';
import '../models/todo.dart' as model;
import 'todo_data_source.dart';
import 'todo_database.dart';

@lazySingleton
class DriftTodoDataSource implements TodoDataSource {
  DriftTodoDataSource(this.db);

  final TodoDatabase db;

  @override
  Future<List<model.Todo>> getTodos() async {
    final entries = await db.select(db.todos).get();
    return entries.map(_fromEntry).toList();
  }

  @override
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

  @override
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

  @override
  Future<void> deleteTodo(String id) async {
    await (db.delete(db.todos)..where((tbl) => tbl.id.equals(id))).go();
  }

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
