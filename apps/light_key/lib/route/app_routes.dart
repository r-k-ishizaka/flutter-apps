import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth/auth_screen.dart';
import '../screens/post/post_screen.dart';
import '../screens/timeline/timeline_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/auth',
  overridePlatformDefaultLocation: true,
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/timeline',
      builder: (context, state) => const TimelineScreen(),
    ),
    GoRoute(
      path: '/post',
      builder: (context, state) => const PostScreen(),
    ),
  ],
);

class AppNavBar extends StatelessWidget {
  const AppNavBar({super.key, required this.currentPath});

  final String currentPath;

  int get _currentIndex {
    if (currentPath.startsWith('/timeline')) return 1;
    if (currentPath.startsWith('/post')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/auth');
            break;
          case 1:
            context.go('/timeline');
            break;
          case 2:
            context.go('/post');
            break;
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.lock_outline), label: 'Auth'),
        NavigationDestination(icon: Icon(Icons.dynamic_feed), label: 'Timeline'),
        NavigationDestination(icon: Icon(Icons.edit_note), label: 'Post'),
      ],
    );
  }
}
