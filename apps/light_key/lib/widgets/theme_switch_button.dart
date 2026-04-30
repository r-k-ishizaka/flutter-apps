import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../utils/theme_constants.dart' as theme_constants;

/// テーマ切り替えボタン
/// AppBarのactionsに追加して使用
class ThemeSwitchButton extends StatelessWidget {
  const ThemeSwitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return PopupMenuButton<theme_constants.ThemeMode>(
          onSelected: (mode) {
            themeProvider.setThemeMode(mode);
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<theme_constants.ThemeMode>(
              value: theme_constants.ThemeMode.light,
              child: const Text('ライトモード'),
            ),
            PopupMenuItem<theme_constants.ThemeMode>(
              value: theme_constants.ThemeMode.dark,
              child: const Text('ダークモード'),
            ),
            PopupMenuItem<theme_constants.ThemeMode>(
              value: theme_constants.ThemeMode.system,
              child: const Text('システム設定に従う'),
            ),
          ],
          icon: Icon(switch (themeProvider.themeMode) {
            theme_constants.ThemeMode.light => Icons.light_mode,
            theme_constants.ThemeMode.dark => Icons.dark_mode,
            theme_constants.ThemeMode.system => Icons.brightness_auto,
          }),
        );
      },
    );
  }
}
