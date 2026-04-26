import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../screens/auth/auth_screen.dart';
import '../screens/post/post_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/timeline/timeline_screen.dart';
import '../screens/timeline/timeline_provider.dart';
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

@TypedShellRoute<AppShellRouteData>(
  routes: [
    TypedGoRoute<TimelineRoute>(path: '/timeline'),
    TypedGoRoute<AuthRoute>(path: '/auth'),
  ],
)
@immutable
class AppShellRouteData extends ShellRouteData {
  const AppShellRouteData();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return AppShell(currentPath: state.uri.path, child: navigator);
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

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.currentPath, required this.child});

  final String currentPath;
  final Widget child;

  bool get _isAuth => currentPath.startsWith('/auth');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isAuth ? '認証' : 'タイムライン'),
        actions: _isAuth
            ? null
            : [
                IconButton(
                  onPressed: () => context.read<TimelineProvider>().fetch(),
                  icon: const Icon(Icons.refresh),
                ),
                IconButton(
                  onPressed: () => const PostRoute().go(context),
                  icon: const Icon(Icons.edit_note),
                ),
                const ThemeSwitchButton(),
              ],
      ),
      bottomNavigationBar: AppNavBar(currentPath: currentPath),
      body: child,
    );
  }
}

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
            const TimelineRoute().go(context);
            break;
          case 1:
            const AuthRoute().go(context);
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
