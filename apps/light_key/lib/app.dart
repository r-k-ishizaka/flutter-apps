import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

TextTheme buildMixedTextTheme(TextTheme baseTheme) {
  final jpFamily = GoogleFonts.notoSansJp().fontFamily;
  final robotoTheme = GoogleFonts.robotoTextTheme(baseTheme);
  if (jpFamily == null) {
    return robotoTheme;
  }

  return robotoTheme.apply(fontFamilyFallback: <String>[jpFamily]);
}

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
          create: (_) =>
              AuthProvider(getIt<AuthRepository>(), getIt<EmojiRepository>()),
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
        builder: (context, themeProvider, _) {
          final lightTheme = themeProvider.lightTheme;
          final darkTheme = themeProvider.darkTheme;

          return MaterialApp.router(
            title: 'light_key',
            theme: lightTheme.copyWith(
              textTheme: buildMixedTextTheme(lightTheme.textTheme),
            ),
            darkTheme: darkTheme.copyWith(
              textTheme: buildMixedTextTheme(darkTheme.textTheme),
            ),
            themeMode: themeProvider.flutterThemeMode,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
