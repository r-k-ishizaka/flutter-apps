import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'di.config.dart';
// ...existing code...

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();
