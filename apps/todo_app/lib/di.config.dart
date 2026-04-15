// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
// import 'package:todo_app/providers/todo_provider.dart' as _i754;
import 'package:todo_app/repositories/todo_repository.dart' as _i994;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    // gh.singleton<_i754.TodoRepository>(() => _i754.TodoRepository());
    gh.singleton<_i994.TodoRepository>(() => _i994.TodoRepository());
    return this;
  }
}
