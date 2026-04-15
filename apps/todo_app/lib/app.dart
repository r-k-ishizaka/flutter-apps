import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home/home_provider.dart';
import 'screens/add_todo/add_todo_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/add_todo/add_todo_screen.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODOアプリ',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ChangeNotifierProvider(
        create: (_) => HomeProvider(),
        child: const HomeScreen(),
      ),
      routes: {
        '/add': (context) => ChangeNotifierProvider(
          create: (_) => AddTodoProvider(),
          child: const AddTodoScreen(),
        ),
      },
    );
  }
}
