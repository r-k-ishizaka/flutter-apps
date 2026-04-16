import 'package:flutter/material.dart';
import 'app.dart';
import 'di/di.dart';

void main() {
  configureDependencies();
  runApp(const TodoApp());
}
