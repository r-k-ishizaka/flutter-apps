// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:todo_app/datasources/todo_data_source.dart' as _i251;
import 'package:todo_app/datasources/todo_database.dart' as _i589;
import 'package:todo_app/datasources/todo_drift_data_source.dart' as _i661;
import 'package:todo_app/datasources/todo_firestore_data_source.dart' as _i145;
import 'package:todo_app/di/database_module.dart' as _i842;
import 'package:todo_app/repositories/todo_repository.dart' as _i994;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final databaseModule = _$DatabaseModule();
    gh.lazySingleton<_i589.TodoDatabase>(
      () => databaseModule.provideTodoDatabase(),
    );
    gh.lazySingleton<_i974.FirebaseFirestore>(
      () => databaseModule.provideFirebaseFirestore(),
    );
    gh.lazySingleton<_i661.DriftTodoDataSource>(
      () => _i661.DriftTodoDataSource(gh<_i589.TodoDatabase>()),
    );
    gh.lazySingleton<_i251.TodoDataSource>(
      () => _i145.FirestoreTodoDataSource(gh<_i974.FirebaseFirestore>()),
    );
    gh.factory<_i994.TodoRepository>(
      () => _i994.TodoRepository(gh<_i251.TodoDataSource>()),
    );
    return this;
  }
}

class _$DatabaseModule extends _i842.DatabaseModule {}
