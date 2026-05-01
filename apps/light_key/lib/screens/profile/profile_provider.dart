import 'package:flutter/foundation.dart';

import '../../repositories/auth_repository.dart';
import '../../repositories/user_profile_repository.dart';
import 'profile_screen_state.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({
    required AuthRepository authRepository,
    required UserProfileRepository profileRepository,
  }) : _authRepository = authRepository,
       _profileRepository = profileRepository;

  final AuthRepository _authRepository;
  final UserProfileRepository _profileRepository;

  ProfileScreenState _state = const ProfileScreenState.idle();

  ProfileScreenState get state => _state;

  Future<void> load(String userId) async {
    if (userId.isEmpty) {
      _state = _state.copyWith(
        status: ProfileStatus.error,
        message: 'ユーザーIDが不正です。',
        clearProfile: true,
      );
      notifyListeners();
      return;
    }

    _state = _state.copyWith(
      status: ProfileStatus.loading,
      clearMessage: true,
      clearProfile: true,
    );
    notifyListeners();

    final sessionResult = await _authRepository.restoreSession();
    await sessionResult.when(
      success: (session) async {
        if (session == null) {
          _state = _state.copyWith(
            status: ProfileStatus.error,
            message: '先に認証してください。',
          );
          return;
        }

        final profileResult = await _profileRepository.fetchUserProfile(
          session,
          userId,
        );
        profileResult.when(
          success: (profile) {
            _state = _state.copyWith(
              status: ProfileStatus.loaded,
              profile: profile,
            );
          },
          failure: (error, _) {
            _state = _state.copyWith(
              status: ProfileStatus.error,
              message: 'プロフィールの取得に失敗しました: $error',
            );
          },
        );
      },
      failure: (error, _) {
        _state = _state.copyWith(
          status: ProfileStatus.error,
          message: 'セッション取得に失敗しました: $error',
        );
      },
    );

    notifyListeners();
  }
}
