import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../datasources/auth_data_source.dart';
import '../datasources/misskey_auth_data_source.dart';
import '../datasources/misskey_post_data_source.dart';
import '../datasources/misskey_timeline_data_source.dart';
import '../datasources/post_data_source.dart';
import '../datasources/timeline_data_source.dart';
import '../repositories/auth_repository.dart';
import '../repositories/post_repository.dart';
import '../repositories/timeline_repository.dart';
import '../utils/misskey_http_client.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerLazySingleton(MisskeyHttpClient.new);
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  getIt.registerLazySingleton<AuthDataSource>(
    () => MisskeyAuthDataSource(
      client: getIt<MisskeyHttpClient>(),
      prefs: getIt<SharedPreferences>(),
    ),
  );
  getIt.registerLazySingleton<TimelineDataSource>(
    () => MisskeyTimelineDataSource(getIt<MisskeyHttpClient>()),
  );
  getIt.registerLazySingleton<PostDataSource>(
    () => MisskeyPostDataSource(getIt<MisskeyHttpClient>()),
  );

  getIt.registerLazySingleton(() => AuthRepository(getIt<AuthDataSource>()));
  getIt.registerLazySingleton(
    () => TimelineRepository(getIt<TimelineDataSource>()),
  );
  getIt.registerLazySingleton(() => PostRepository(getIt<PostDataSource>()));

}
