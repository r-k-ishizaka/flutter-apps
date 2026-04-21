import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../datasources/todo_database.dart';

@module
abstract class DatabaseModule {
  @lazySingleton
  TodoDatabase provideTodoDatabase() => TodoDatabase();

  @lazySingleton
  FirebaseFirestore provideFirebaseFirestore() => FirebaseFirestore.instance;
}
