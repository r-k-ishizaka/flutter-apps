import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/todo_provider.dart';
import 'screens/home_screen.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TodoProvider(),
      child: MaterialApp(
        title: 'TODOアプリ',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
