import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import 'dto/firestore_todo_dto.dart';
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
      final dto = FirestoreTodoDto.fromFirestore(doc.data());
      return dto.toDomain(doc.id);
    }).toList();
  }

  @override
  Future<model.Todo> addTodo(model.Todo todo) async {
    final dto = FirestoreTodoDto.fromDomain(todo);
    await _todosCollection.doc(todo.id).set(dto.toFirestore());
    return todo;
  }

  @override
  Future<void> updateTodo(model.Todo todo) async {
    final dto = FirestoreTodoDto.fromDomain(todo);
    await _todosCollection.doc(todo.id).update(dto.toFirestore());
  }

  @override
  Future<void> deleteTodo(String id) async {
    await _todosCollection.doc(id).delete();
  }
}
