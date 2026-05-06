import 'package:flutter/foundation.dart';

import '../../providers/theme_provider.dart';
import '../../repositories/auth_repository.dart';
import '../../utils/theme_constants.dart' as theme_constants;
import 'settings_effect_state.dart';
import 'settings_screen_state.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({
    required AuthRepository authRepository,
    required ThemeProvider themeProvider,
  }) : _authRepository = authRepository,
       _themeProvider = themeProvider,
       _state = SettingsScreenState.ready(themeMode: themeProvider.themeMode);

  final AuthRepository _authRepository;
  final ThemeProvider _themeProvider;

  SettingsScreenState _state;
  SettingsEffectState _effect = const SettingsEffectState.none();

  SettingsScreenState get state => _state;
  SettingsEffectState get effect => _effect;

  Future<void> changeThemeMode(theme_constants.ThemeMode mode) async {
    final current = _state;
    if (current.themeMode == mode) {
      return;
    }

    await _themeProvider.setThemeMode(mode);
    _state = _state.copyWith(themeMode: _themeProvider.themeMode);
    _effect = const SettingsEffectState.showMessage('テーマを変更しました。');
    notifyListeners();
  }

  Future<void> signOut() async {
    if (_state.isSigningOut) {
      return;
    }

    _state = _state.copyWith(isSigningOut: true);
    _effect = const SettingsEffectState.none();
    notifyListeners();

    final result = await _authRepository.signOut();
    result.when(
      success: (_) {
        _state = _state.copyWith(isSigningOut: false);
        _effect = const SettingsEffectState.loggedOut();
      },
      failure: (error, _) {
        _state = _state.copyWith(isSigningOut: false);
        _effect = SettingsEffectState.showError('ログアウトに失敗しました: $error');
      },
    );

    notifyListeners();
  }

  void consumeEffect() {
    if (_effect == const SettingsEffectState.none()) {
      return;
    }
    _effect = const SettingsEffectState.none();
    notifyListeners();
  }
}
