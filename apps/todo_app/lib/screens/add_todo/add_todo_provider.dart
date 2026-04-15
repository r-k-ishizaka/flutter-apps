import 'package:flutter/material.dart';

class AddTodoProvider extends ChangeNotifier {
  String _todoText = '';

  String get todoText => _todoText;

  void updateText(String text) {
    _todoText = text;
    notifyListeners();
  }

  void clear() {
    _todoText = '';
    notifyListeners();
  }
}
