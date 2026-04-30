import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth/auth_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/post/post_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/timeline/timeline_screen.dart';
import '../widgets/theme_switch_button.dart';

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
      actions: const [ThemeSwitchButton()],
      onPostTap: () => const PostRoute().push(context),
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
  const PostRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const PostScreen();
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  overridePlatformDefaultLocation: true,
  routes: $appRoutes,
);
