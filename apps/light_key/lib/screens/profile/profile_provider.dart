import 'package:flutter/foundation.dart';

import '../../models/note.dart';
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
      clearNotes: true,
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
        await profileResult.when(
          success: (profile) async {
            final allNotesResult = await _profileRepository.fetchUserNotes(
              session,
              userId,
              includeReplies: true,
              includeRenotes: true,
            );
            final noteOnlyResult = await _profileRepository.fetchUserNotes(
              session,
              userId,
              includeReplies: false,
              includeRenotes: false,
            );
            final mediaResult = await _profileRepository.fetchUserNotes(
              session,
              userId,
              includeReplies: false,
              includeRenotes: false,
              withFiles: true,
            );

            await allNotesResult.when(
              success: (allNotes) async {
                final pinnedResult = await _profileRepository.fetchUserPinnedNotes(
                  session,
                  userId,
                );
                final mergedAll = pinnedResult.when(
                  success: (pinnedNotes) => _mergePinnedNotes(
                    pinnedNotes,
                    allNotes,
                  ),
                  failure: (_, _) => allNotes,
                );

                noteOnlyResult.when(
                  success: (noteOnlyNotes) {
                    mediaResult.when(
                      success: (mediaNotes) {
                        _state = _state.copyWith(
                          status: ProfileStatus.loaded,
                          profile: profile,
                          allNotes: List<Note>.unmodifiable(mergedAll),
                          noteOnlyNotes: List<Note>.unmodifiable(noteOnlyNotes),
                          mediaNotes: List<Note>.unmodifiable(mediaNotes),
                        );
                      },
                      failure: (error, _) {
                        _state = _state.copyWith(
                          status: ProfileStatus.error,
                          message: 'メディアノートの取得に失敗しました: $error',
                        );
                      },
                    );
                  },
                  failure: (error, _) {
                    _state = _state.copyWith(
                      status: ProfileStatus.error,
                      message: 'ノートの取得に失敗しました: $error',
                    );
                  },
                );
              },
              failure: (error, _) {
                _state = _state.copyWith(
                  status: ProfileStatus.error,
                  message: 'ノートの取得に失敗しました: $error',
                );
              },
            );
          },
          failure: (error, _) async {
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

  List<Note> _mergePinnedNotes(List<Note> pinned, List<Note> notes) {
    if (pinned.isEmpty) {
      return notes;
    }

    final merged = <Note>[];
    final seenIds = <String>{};

    for (final note in pinned) {
      if (note.id.isEmpty || seenIds.add(note.id)) {
        merged.add(note);
      }
    }
    for (final note in notes) {
      if (note.id.isEmpty || seenIds.add(note.id)) {
        merged.add(note);
      }
    }
    return merged;
  }
}
