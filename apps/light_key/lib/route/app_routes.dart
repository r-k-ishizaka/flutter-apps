import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../di/di.dart';
import '../models/note_file.dart';
import '../providers/theme_provider.dart';
import '../repositories/auth_repository.dart';
import '../repositories/timeline_repository.dart';
import '../repositories/user_profile_repository.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/image_viewer/image_viewer_screen.dart';
import '../screens/note_detail/note_detail_provider.dart';
import '../screens/note_detail/note_detail_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/post/post_screen.dart';
import '../screens/post/post_screen_param.dart';
import '../screens/profile/profile_provider.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_provider.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/timeline/timeline_screen.dart';

part 'app_routes.g.dart';

@TypedGoRoute<SplashRoute>(path: '/')
@immutable
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SplashScreen();
}

@TypedGoRoute<HomeRoute>(path: '/home')
@immutable
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  String? redirect(BuildContext context, GoRouterState state) =>
      const TimelineRoute().location;
}

@TypedGoRoute<LegacyTimelineRoute>(path: '/timeline')
@immutable
class LegacyTimelineRoute extends GoRouteData with $LegacyTimelineRoute {
  const LegacyTimelineRoute();

  @override
  String? redirect(BuildContext context, GoRouterState state) =>
      const TimelineRoute().location;
}

@TypedShellRoute<HomeShellRouteData>(
  routes: [
    TypedGoRoute<TimelineRoute>(path: '/home/timeline'),
    TypedGoRoute<NotificationsRoute>(path: '/home/notifications'),
  ],
)
@immutable
class HomeShellRouteData extends ShellRouteData {
  const HomeShellRouteData();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    final currentPath = state.uri.path;
    final selectedIndex = currentPath.startsWith('/home/notifications') ? 1 : 0;

    return HomeScreen(
      currentPath: currentPath,
      selectedIndex: selectedIndex,
      actions: [
        IconButton(
          onPressed: () => const SettingsRoute().push<void>(context),
          icon: const Icon(Icons.settings),
          tooltip: '設定',
        ),
      ],
      onPostTap: () {
        const PostRoute().push<String>(context).then((message) {
          if (!context.mounted || message == null || message.isEmpty) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        });
      },
      onDestinationSelected: (index) {
        if (index == selectedIndex) return;

        switch (index) {
          case 0:
            const TimelineRoute().go(context);
            break;
          case 1:
            const NotificationsRoute().go(context);
            break;
        }
      },
      child: navigator,
    );
  }
}

@immutable
class TimelineRoute extends GoRouteData with $TimelineRoute {
  const TimelineRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const TimelineScreen();
}

@immutable
class NotificationsRoute extends GoRouteData with $NotificationsRoute {
  const NotificationsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const NotificationsScreen();
}

@TypedGoRoute<LegacyNotificationsRoute>(path: '/notifications')
@immutable
class LegacyNotificationsRoute extends GoRouteData
    with $LegacyNotificationsRoute {
  const LegacyNotificationsRoute();

  @override
  String? redirect(BuildContext context, GoRouterState state) =>
      const NotificationsRoute().location;
}

@TypedGoRoute<AuthRoute>(path: '/auth')
@immutable
class AuthRoute extends GoRouteData with $AuthRoute {
  const AuthRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const AuthScreen();
}

@TypedGoRoute<PostRoute>(path: '/post')
@immutable
class PostRoute extends GoRouteData with $PostRoute {
  const PostRoute({this.$extra});

  final PostScreenParam? $extra;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      CustomTransitionPage<void>(
        key: state.pageKey,
        fullscreenDialog: true,
        transitionDuration: const Duration(milliseconds: 240),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        child: PostScreen(param: $extra ?? const PostScreenParam.normal()),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          );
        },
      );
}

@TypedGoRoute<SettingsRoute>(path: '/settings')
@immutable
class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(
        authRepository: getIt<AuthRepository>(),
        themeProvider: context.read<ThemeProvider>(),
      ),
      child: const SettingsScreen(),
    );
  }
}

@TypedGoRoute<UserProfileRoute>(path: '/users/:userId')
@immutable
class UserProfileRoute extends GoRouteData with $UserProfileRoute {
  const UserProfileRoute({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider(
        authRepository: getIt<AuthRepository>(),
        profileRepository: getIt<UserProfileRepository>(),
        timelineRepository: getIt<TimelineRepository>(),
      )..load(userId),
      child: ProfileScreen(userId: userId),
    );
  }
}

@TypedGoRoute<NoteDetailRoute>(path: '/notes/:noteId')
@immutable
class NoteDetailRoute extends GoRouteData with $NoteDetailRoute {
  const NoteDetailRoute({required this.noteId});

  final String noteId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChangeNotifierProvider(
      create: (_) => NoteDetailProvider(
        authRepository: getIt<AuthRepository>(),
        timelineRepository: getIt<TimelineRepository>(),
      ),
      child: NoteDetailScreen(noteId: noteId),
    );
  }
}

@TypedGoRoute<ImageViewerRoute>(path: '/image-viewer/:initialIndex')
@immutable
class ImageViewerRoute extends GoRouteData with $ImageViewerRoute {
  const ImageViewerRoute({required this.initialIndex});

  final int initialIndex;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    final files = state.extra as List<NoteFile>? ?? [];
    final safeInitialIndex = files.isEmpty
        ? 0
        : initialIndex.clamp(0, files.length - 1);
    return CustomTransitionPage<void>(
      key: state.pageKey,
      fullscreenDialog: true,
      opaque: false,
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          child,
      child: ImageViewerScreen(files: files, initialIndex: safeInitialIndex),
    );
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  overridePlatformDefaultLocation: true,
  routes: $appRoutes,
);
