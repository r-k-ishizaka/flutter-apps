import 'package:injectable/injectable.dart';
import '../datasources/todo_database.dart';

@module
abstract class DatabaseModule {
  @lazySingleton
  TodoDatabase provideTodoDatabase() => TodoDatabase();
}
