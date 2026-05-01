import 'package:flutter/foundation.dart';

import '../../models/note.dart';
import '../../models/note_type.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/timeline_repository.dart';
import '../../repositories/user_profile_repository.dart';
import 'profile_screen_state.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({
    required AuthRepository authRepository,
    required UserProfileRepository profileRepository,
    required TimelineRepository timelineRepository,
  }) : _authRepository = authRepository,
       _profileRepository = profileRepository,
       _timelineRepository = timelineRepository;

  final AuthRepository _authRepository;
  final UserProfileRepository _profileRepository;
  final TimelineRepository _timelineRepository;

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

  Future<String?> createReaction(Note note, String reaction) async {
    final normalizedReaction = reaction.trim();
    if (normalizedReaction.isEmpty) {
      return 'リアクションが選択されていません。';
    }

    final targetNote = note.noteType == NoteType.pureRenote
        ? note.renote ?? note
        : note;
    if (targetNote.id.isEmpty) {
      return 'リアクション対象のノートIDが見つかりません。';
    }

    final sessionResult = await _authRepository.restoreSession();
    return sessionResult.when(
      success: (session) async {
        if (session == null) {
          return '先に認証してください。';
        }

        final reactionResult = await _timelineRepository.createReaction(
          session,
          noteId: targetNote.id,
          reaction: normalizedReaction,
        );
        return reactionResult.when(
          success: (_) {
            _applyMyReaction(targetNote.id, normalizedReaction);
            return null;
          },
          failure: (error, _) => 'リアクション送信に失敗しました: $error',
        );
      },
      failure: (error, _) async => 'セッション取得に失敗しました: $error',
    );
  }

  void _applyMyReaction(String targetNoteId, String reaction) {
    List<Note> updateList(List<Note> notes) => notes
        .map((item) {
          if (item.id == targetNoteId) {
            return _updateNoteReaction(item, reaction);
          }
          final renote = item.renote;
          if (renote != null && renote.id == targetNoteId) {
            return item.copyWith(renote: _updateNoteReaction(renote, reaction));
          }
          return item;
        })
        .toList(growable: false);

    _state = _state.copyWith(
      allNotes: List<Note>.unmodifiable(updateList(_state.allNotes)),
      noteOnlyNotes: List<Note>.unmodifiable(updateList(_state.noteOnlyNotes)),
      mediaNotes: List<Note>.unmodifiable(updateList(_state.mediaNotes)),
    );
    notifyListeners();
  }

  Note _updateNoteReaction(Note note, String reaction) {
    final previousReaction = note.myReaction;
    if (previousReaction == reaction) {
      return note.copyWith(myReaction: reaction);
    }

    var updated = note;
    if (previousReaction != null && previousReaction.isNotEmpty) {
      updated = updated.applyReactionDelta(previousReaction, -1);
    }
    updated = updated.applyReactionDelta(reaction, 1);
    return updated.copyWith(myReaction: reaction);
  }
}
