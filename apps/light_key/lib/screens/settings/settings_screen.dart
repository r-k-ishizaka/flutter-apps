import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../route/app_routes.dart';
import '../../utils/theme_constants.dart' as theme_constants;
import '../auth/auth_provider.dart';
import 'settings_effect_state.dart';
import 'settings_provider.dart';

class SettingsScreen extends HookWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final state = provider.state;
    final effect = provider.effect;

    useEffect(() {
      if (effect == const SettingsEffectState.none()) {
        return null;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted) {
          return;
        }

        provider.consumeEffect();

        switch (effect) {
          case SettingsEffectStateNone():
            break;
          case SettingsEffectStateShowMessage(:final message):
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
            break;
          case SettingsEffectStateShowError(:final message):
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
            break;
          case SettingsEffectStateLoggedOut():
            await context.read<AuthProvider>().restoreSession();
            if (!context.mounted) {
              return;
            }
            const AuthRoute().go(context);
            break;
        }
      });

      return null;
    }, [effect]);

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          const _SectionHeader(title: 'テーマ'),
          _ThemeModeDropdownTile(
            currentMode: state.themeMode,
            onChanged: provider.changeThemeMode,
          ),
          const Divider(height: 24),
          const _SectionHeader(title: 'アカウント'),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('ログアウト'),
            subtitle: const Text('この端末のログイン情報を削除します'),
            onTap: state.isSigningOut
                ? null
                : () async {
                    final shouldSignOut = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('ログアウトしますか？'),
                        content: const Text('現在のセッションを削除してログイン画面に戻ります。'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(false),
                            child: const Text('キャンセル'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(dialogContext).pop(true),
                            child: const Text('ログアウト'),
                          ),
                        ],
                      ),
                    );
                    if (!context.mounted || shouldSignOut != true) {
                      return;
                    }
                    await provider.signOut();
                  },
            trailing: state.isSigningOut
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _ThemeModeDropdownTile extends StatelessWidget {
  const _ThemeModeDropdownTile({
    required this.currentMode,
    required this.onChanged,
  });

  final theme_constants.ThemeMode currentMode;
  final ValueChanged<theme_constants.ThemeMode> onChanged;

  static const _labels = {
    theme_constants.ThemeMode.light: 'ライトモード',
    theme_constants.ThemeMode.dark: 'ダークモード',
    theme_constants.ThemeMode.system: 'システム設定に従う',
  };

  static const _icons = {
    theme_constants.ThemeMode.light: Icons.light_mode,
    theme_constants.ThemeMode.dark: Icons.dark_mode,
    theme_constants.ThemeMode.system: Icons.brightness_auto,
  };

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_icons[currentMode]),
      title: const Text('テーマ'),
      trailing: DropdownButton<theme_constants.ThemeMode>(
        value: currentMode,
        underline: const SizedBox.shrink(),
        items: theme_constants.ThemeMode.values
            .map(
              (mode) => DropdownMenuItem(
                value: mode,
                child: Text(_labels[mode]!),
              ),
            )
            .toList(),
        onChanged: (mode) {
          if (mode == null) return;
          onChanged(mode);
        },
      ),
    );
  }
}
