import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_effect_state.freezed.dart';

@freezed
sealed class SettingsEffectState with _$SettingsEffectState {
  const factory SettingsEffectState.none() = SettingsEffectStateNone;

  const factory SettingsEffectState.showMessage(String message) =
      SettingsEffectStateShowMessage;

  const factory SettingsEffectState.showError(String message) =
      SettingsEffectStateShowError;

  const factory SettingsEffectState.loggedOut() = SettingsEffectStateLoggedOut;
}
