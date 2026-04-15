import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';

final GoRouter _router = GoRouter(routes: $appRoutes);

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TODOアプリ',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: _router,
    );
  }
}
