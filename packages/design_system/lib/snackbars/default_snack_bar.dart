import 'package:flutter/material.dart';

/// アプリ共通のSnackBarラッパー
class DefaultSnackBar extends SnackBar {
  DefaultSnackBar({
    super.key,
    required String message,
    super.backgroundColor,
    super.action,
    super.duration = const Duration(seconds: 3),
    super.elevation,
    super.shape,
    super.margin,
    super.padding,
    super.behavior,
  }) : super(content: Text(message));
}
