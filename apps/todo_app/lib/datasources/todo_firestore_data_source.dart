import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../models/todo.dart' as model;
import 'todo_data_source.dart';

@LazySingleton(as: TodoDataSource)
class FirestoreTodoDataSource implements TodoDataSource {
  FirestoreTodoDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _todosCollection =>
      _firestore.collection('todos');

  @override
  Future<List<model.Todo>> getTodos() async {
    final snapshot = await _todosCollection.get();
    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = data['id'] ?? doc.id;
      return model.Todo.fromJson(data);
    }).toList();
  }

  @override
  Future<model.Todo> addTodo(model.Todo todo) async {
    await _todosCollection.doc(todo.id).set(todo.toJson());
    return todo;
  }

  @override
  Future<void> updateTodo(model.Todo todo) async {
    await _todosCollection.doc(todo.id).update(todo.toJson());
  }

  @override
  Future<void> deleteTodo(String id) async {
    await _todosCollection.doc(id).delete();
  }
}
