import 'package:freezed_annotation/freezed_annotation.dart';

import '../../utils/theme_constants.dart' as theme_constants;

part 'settings_screen_state.freezed.dart';

@freezed
sealed class SettingsScreenState with _$SettingsScreenState {
  const factory SettingsScreenState.ready({
    required theme_constants.ThemeMode themeMode,
    @Default(false) bool isSigningOut,
  }) = SettingsScreenStateReady;
}
