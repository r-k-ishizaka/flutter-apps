import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:design_system/design_system.dart';

import '../utils/theme_constants.dart' as theme_constants;

/// テーマ管理用 ChangeNotifier
class ThemeProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  late theme_constants.ThemeMode _themeMode;

  ThemeProvider(this._prefs) {
    _loadThemeMode();
  }

  /// 現在のテーマモード
  theme_constants.ThemeMode get themeMode => _themeMode;

  /// 現在のThemeData（ライト）
  ThemeData get lightTheme => AppTheme.lightTheme;

  /// 現在のThemeData（ダーク）
  ThemeData get darkTheme => AppTheme.darkTheme;

  /// SharedPreferencesからテーマ設定を読み込み
  void _loadThemeMode() {
    final saved = _prefs.getString(theme_constants.ThemeConstants.themeModeKey);
    if (saved != null) {
      _themeMode = theme_constants.ThemeConstants.stringToThemeMode(saved);
    } else {
      _themeMode = theme_constants.ThemeMode.system;
    }
  }

  /// テーマモードを変更
  Future<void> setThemeMode(theme_constants.ThemeMode mode) async {
    _themeMode = mode;
    final modeString = theme_constants.ThemeConstants.themeModeToString(mode);
    await _prefs.setString(
      theme_constants.ThemeConstants.themeModeKey,
      modeString,
    );
    notifyListeners();
  }

  /// 内部向け：Flutterの ThemeMode に変換
  ThemeMode _toFlutterThemeMode() {
    return switch (_themeMode) {
      theme_constants.ThemeMode.light => ThemeMode.light,
      theme_constants.ThemeMode.dark => ThemeMode.dark,
      theme_constants.ThemeMode.system => ThemeMode.system,
    };
  }

  /// MaterialApp用のThemeMode
  ThemeMode get flutterThemeMode => _toFlutterThemeMode();
}
