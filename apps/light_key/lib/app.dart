import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'di/di.dart';
import 'providers/theme_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/emoji_repository.dart';
import 'repositories/post_repository.dart';
import 'repositories/timeline_repository.dart';
import 'route/app_routes.dart';
import 'screens/auth/auth_provider.dart';
import 'screens/post/post_provider.dart';
import 'screens/timeline/timeline_provider.dart';

class LightKeyApp extends StatelessWidget {
  const LightKeyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => getIt<ThemeProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            getIt<AuthRepository>(),
            getIt<EmojiRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TimelineProvider(
            authRepository: getIt<AuthRepository>(),
            timelineRepository: getIt<TimelineRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => PostProvider(
            authRepository: getIt<AuthRepository>(),
            postRepository: getIt<PostRepository>(),
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp.router(
          title: 'light_key',
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.flutterThemeMode,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
