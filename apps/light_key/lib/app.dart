import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'di/di.dart';
import 'repositories/auth_repository.dart';
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
        ChangeNotifierProvider(
          create: (_) => AuthProvider(getIt<AuthRepository>())..restoreSession(),
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
      child: MaterialApp.router(
        title: 'light_key',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
