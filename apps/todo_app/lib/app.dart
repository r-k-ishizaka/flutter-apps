// ...existing code...
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route/app_routes.dart';
import 'package:provider/provider.dart';
import 'di/di.dart';
import 'repositories/todo_repository.dart';
import 'screens/home/home_provider.dart';
import 'screens/add_todo/add_todo_provider.dart';

final GoRouter _router = GoRouter(routes: $appRoutes);

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => HomeProvider(getIt<TodoRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => AddTodoProvider(getIt<TodoRepository>()),
        ),
      ],
      child: MaterialApp.router(
        title: 'TODOアプリ',
        theme: ThemeData(primarySwatch: Colors.blue),
        routerConfig: _router,
      ),
    );
  }
}
