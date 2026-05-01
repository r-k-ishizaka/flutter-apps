import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../datasources/auth_data_source.dart';
import '../datasources/emoji_data_source.dart';
import '../datasources/misskey_auth_data_source.dart';
import '../datasources/misskey_emoji_data_source.dart';
import '../datasources/misskey_post_data_source.dart';
import '../datasources/misskey_timeline_data_source.dart';
import '../datasources/misskey_user_profile_data_source.dart';
import '../datasources/post_data_source.dart';
import '../datasources/timeline_data_source.dart';
import '../datasources/user_profile_data_source.dart';
import '../providers/theme_provider.dart';
import '../repositories/auth_repository.dart';
import '../repositories/emoji_repository.dart';
import '../repositories/post_repository.dart';
import '../repositories/timeline_repository.dart';
import '../repositories/user_profile_repository.dart';
import '../services/app_database.dart';
import '../services/emoji_cache.dart';
import '../utils/misskey_http_client.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerLazySingleton(MisskeyHttpClient.new);
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  getIt.registerSingleton<ThemeProvider>(ThemeProvider(sharedPreferences));

  // --- Emoji ---
  getIt.registerSingleton<AppDatabase>(AppDatabase());
  getIt.registerSingleton<EmojiCache>(EmojiCache());
  getIt.registerLazySingleton<EmojiDataSource>(
    () => MisskeyEmojiDataSource(client: getIt<MisskeyHttpClient>()),
  );
  getIt.registerLazySingleton(
    () => EmojiRepository(
      dataSource: getIt<EmojiDataSource>(),
      database: getIt<AppDatabase>(),
      cache: getIt<EmojiCache>(),
    ),
  );

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
  getIt.registerLazySingleton<UserProfileDataSource>(
    () => MisskeyUserProfileDataSource(getIt<MisskeyHttpClient>()),
  );

  getIt.registerLazySingleton(() => AuthRepository(getIt<AuthDataSource>()));
  getIt.registerLazySingleton(
    () => TimelineRepository(getIt<TimelineDataSource>()),
  );
  getIt.registerLazySingleton(() => PostRepository(getIt<PostDataSource>()));
  getIt.registerLazySingleton(
    () => UserProfileRepository(getIt<UserProfileDataSource>()),
  );
}
