import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/screens/home/home_screen_state.dart';
import '../../models/todo.dart';
import '../../route/app_routes.dart';
import 'home_provider.dart';
import '../../widgets/todo_list.dart';
import 'package:core/notifications/notification_permission.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context);
    final state = provider.state;

    useEffect(() {
      provider.initialize();
      return null;
    });

    return Scaffold(
      appBar: AppBar(title: const Text('TODOアプリ')),
      body: state.when(
        loading: () => _LoadingScreen(),
        success: (todos) {
          if (todos.isEmpty) {
            return _EmptyScreen();
          } else {
            return _SuccessScreen(
              todos: todos,
              onToggle: (String id) => provider.toggleTodo(id),
              onDelete: (String id) => provider.removeTodo(id),
              onRequestNotification: (String id) async {
                await requestNotificationPermission();
                // idを使った処理が必要ならここで利用可能
              },
            );
          }
        },
        failure: (Exception error) => _FailureScreen(error: error),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await const AddTodoRoute().push<String>(context);
          if (result != null && result.isNotEmpty) {
            provider.fetchTodos();
          }
        },
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SizedBox.shrink();
}

class _SuccessScreen extends StatelessWidget {
  final List<Todo> todos;
  final void Function(String id) onToggle;
  final void Function(String id) onDelete;
  final void Function(String id) onRequestNotification;

  const _SuccessScreen({
    required this.todos,
    required this.onToggle,
    required this.onDelete,
    required this.onRequestNotification,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: TodoList(
            todos: todos,
            onToggle: onToggle,
            onDelete: onDelete,
            onRequestNotification: onRequestNotification,
          ),
        ),
      ],
    );
  }
}

class _EmptyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SizedBox.shrink();
}

class _FailureScreen extends StatelessWidget {
  final Exception error;

  const _FailureScreen({required this.error});

  @override
  Widget build(BuildContext context) => SizedBox.shrink();
}
