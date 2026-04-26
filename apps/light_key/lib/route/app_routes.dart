import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth/auth_screen.dart';
import '../screens/post/post_screen.dart';
import '../screens/timeline/timeline_screen.dart';

part 'app_routes.g.dart';

@TypedGoRoute<TimelineRoute>(
  path: '/timeline',
)
@immutable
class TimelineRoute extends GoRouteData with $TimelineRoute {
  const TimelineRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const TimelineScreen();
}

@TypedGoRoute<AuthRoute>(
  path: '/auth',
)
@immutable
class AuthRoute extends GoRouteData with $AuthRoute {
  const AuthRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const AuthScreen();
}

@TypedGoRoute<PostRoute>(
  path: '/post',
)
@immutable
class PostRoute extends GoRouteData with $PostRoute {
  const PostRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PostScreen();
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/timeline',
  overridePlatformDefaultLocation: true,
  routes: $appRoutes,
);

class AppNavBar extends StatelessWidget {
  const AppNavBar({super.key, required this.currentPath});

  final String currentPath;

  int get _currentIndex {
    if (currentPath.startsWith('/auth')) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/timeline');
            break;
          case 1:
            context.go('/auth');
            break;
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.dynamic_feed), label: 'Timeline'),
        NavigationDestination(icon: Icon(Icons.lock_outline), label: 'Auth'),
      ],
    );
  }
}
