/// SharedPreferencesのキー定義
class ThemeConstants {
  static const String themeModeKey = 'themeMode';

  /// ThemeMode の文字列表現
  static String themeModeToString(ThemeMode mode) {
    return mode.toString().split('.').last;
  }

  /// 文字列から ThemeMode に変換
  static ThemeMode stringToThemeMode(String str) {
    return ThemeMode.values.firstWhere(
      (mode) => mode.toString().split('.').last == str,
      orElse: () => ThemeMode.system,
    );
  }
}

enum ThemeMode {
  light,
  dark,
  system,
}
