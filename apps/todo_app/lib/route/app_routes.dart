import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
// ...existing code...
import 'screens/home/home_screen.dart';
import 'screens/add_todo/add_todo_screen.dart';

part 'app_routes.g.dart';

@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: [TypedGoRoute<AddTodoRoute>(path: 'add')],
)
@immutable
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const HomeScreen();
}

@immutable
class AddTodoRoute extends GoRouteData with $AddTodoRoute {
  const AddTodoRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const AddTodoScreen();
}
