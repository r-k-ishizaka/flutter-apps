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

  static const int _notesPageSize = 10;

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
              limit: 10,
              withReplies: true,
              withRenotes: true,
              withFiles: false,
              withChannelNotes: true,
              allowPartial: true,
            );
            final noteOnlyResult = await _profileRepository.fetchUserNotes(
              session,
              userId,
              limit: 10,
              withReplies: false,
              withRenotes: false,
              withFiles: false,
              withChannelNotes: true,
              allowPartial: true,
            );
            final mediaResult = await _profileRepository.fetchUserNotes(
              session,
              userId,
              limit: 10,
              withReplies: false,
              withRenotes: false,
              withFiles: true,
              withChannelNotes: true,
              allowPartial: true,
            );

            await allNotesResult.when(
              success: (allNotes) async {
                final mergedAll = _mergePinnedNotes(
                  profile.pinnedNotes,
                  allNotes,
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
                          allNotesUntilId: mergedAll.isNotEmpty
                              ? mergedAll.last.id
                              : null,
                          noteOnlyNotesUntilId: noteOnlyNotes.isNotEmpty
                              ? noteOnlyNotes.last.id
                              : null,
                          mediaNotesUntilId: mediaNotes.isNotEmpty
                              ? mediaNotes.last.id
                              : null,
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
    final requestedReaction = reaction.trim();
    if (requestedReaction.isEmpty) {
      return 'リアクションが選択されていません。';
    }

    final targetNote = note.noteType == NoteType.pureRenote
        ? note.renote ?? note
        : note;
    if (targetNote.id.isEmpty) {
      return 'リアクション対象のノートIDが見つかりません。';
    }

    final sessionResult = await _authRepository.restoreSession();
    final outgoingReaction = _normalizeOutgoingReaction(requestedReaction);
    return sessionResult.when(
      success: (session) async {
        if (session == null) {
          return '先に認証してください。';
        }

        final reactionResult = await _timelineRepository.createReaction(
          session,
          noteId: targetNote.id,
          reaction: outgoingReaction,
        );
        return reactionResult.when(
          success: (_) {
            _applyMyReaction(targetNote.id, outgoingReaction);
            return null;
          },
          failure: (error, _) => 'リアクション送信に失敗しました: $error',
        );
      },
      failure: (error, _) async => 'セッション取得に失敗しました: $error',
    );
  }

  String _normalizeOutgoingReaction(String reaction) {
    final sameServerDot = RegExp(
      r'^:([a-zA-Z0-9_.-]+)@\.:$',
    ).firstMatch(reaction);
    if (sameServerDot != null) {
      return ':${sameServerDot.group(1)}:';
    }

    return reaction;
  }

  Future<String?> createRenote(Note note) async {
    final targetNote = note.noteType == NoteType.pureRenote
        ? note.renote ?? note
        : note;
    if (targetNote.id.isEmpty) {
      return 'リノート対象のノートIDが見つかりません。';
    }

    final sessionResult = await _authRepository.restoreSession();
    return sessionResult.when(
      success: (session) async {
        if (session == null) {
          return '先に認証してください。';
        }

        final renoteResult = await _timelineRepository.createRenote(
          session,
          noteId: targetNote.id,
        );
        return renoteResult.when(
          success: (_) => null,
          failure: (error, _) => 'リノート送信に失敗しました: $error',
        );
      },
      failure: (error, _) async => 'セッション取得に失敗しました: $error',
    );
  }

  Future<String?> createFavorite(Note note) async {
    final targetNote = note.noteType == NoteType.pureRenote
        ? note.renote ?? note
        : note;
    if (targetNote.id.isEmpty) {
      return 'お気に入り対象のノートIDが見つかりません。';
    }

    final sessionResult = await _authRepository.restoreSession();
    return sessionResult.when(
      success: (session) async {
        if (session == null) {
          return '先に認証してください。';
        }

        final favoriteResult = await _timelineRepository.createFavorite(
          session,
          noteId: targetNote.id,
        );
        return favoriteResult.when(
          success: (_) => null,
          failure: (error, _) => 'お気に入り追加に失敗しました: $error',
        );
      },
      failure: (error, _) async => 'セッション取得に失敗しました: $error',
    );
  }

  Future<String?> createPin(Note note) async {
    final targetNote = note.noteType == NoteType.pureRenote
        ? note.renote ?? note
        : note;
    if (targetNote.id.isEmpty) {
      return 'ピン留め対象のノートIDが見つかりません。';
    }

    final sessionResult = await _authRepository.restoreSession();
    return sessionResult.when(
      success: (session) async {
        if (session == null) {
          return '先に認証してください。';
        }

        final pinResult = await _timelineRepository.createPin(
          session,
          noteId: targetNote.id,
        );
        return pinResult.when(
          success: (_) => null,
          failure: (error, _) => 'ピン留めに失敗しました: $error',
        );
      },
      failure: (error, _) async => 'セッション取得に失敗しました: $error',
    );
  }

  Future<String?> createMute(String userId) async {
    if (userId.isEmpty) {
      return 'ミュート対象のユーザーIDが見つかりません。';
    }

    final sessionResult = await _authRepository.restoreSession();
    return sessionResult.when(
      success: (session) async {
        if (session == null) {
          return '先に認証してください。';
        }

        final muteResult = await _timelineRepository.createMute(
          session,
          userId: userId,
        );
        return muteResult.when(
          success: (_) => null,
          failure: (error, _) => 'ユーザーミュートに失敗しました: $error',
        );
      },
      failure: (error, _) async => 'セッション取得に失敗しました: $error',
    );
  }

  Future<String?> createRenoteMute(String userId) async {
    if (userId.isEmpty) {
      return 'リノートミュート対象のユーザーIDが見つかりません。';
    }

    final sessionResult = await _authRepository.restoreSession();
    return sessionResult.when(
      success: (session) async {
        if (session == null) {
          return '先に認証してください。';
        }

        final muteResult = await _timelineRepository.createRenoteMute(
          session,
          userId: userId,
        );
        return muteResult.when(
          success: (_) => null,
          failure: (error, _) => 'リノートミュートに失敗しました: $error',
        );
      },
      failure: (error, _) async => 'セッション取得に失敗しました: $error',
    );
  }

  Future<String?> createBlock(String userId) async {
    if (userId.isEmpty) {
      return 'ブロック対象のユーザーIDが見つかりません。';
    }

    final sessionResult = await _authRepository.restoreSession();
    return sessionResult.when(
      success: (session) async {
        if (session == null) {
          return '先に認証してください。';
        }

        final blockResult = await _timelineRepository.createBlock(
          session,
          userId: userId,
        );
        return blockResult.when(
          success: (_) => null,
          failure: (error, _) => 'ユーザーブロックに失敗しました: $error',
        );
      },
      failure: (error, _) async => 'セッション取得に失敗しました: $error',
    );
  }

  Future<String?> createReport(
    Note note,
    String category,
    String userComment,
  ) async {
    final targetNote = note.noteType == NoteType.pureRenote
        ? note.renote ?? note
        : note;
    if (targetNote.id.isEmpty) {
      return '通報対象のノートIDが見つかりません。';
    }
    if (targetNote.user.id.isEmpty) {
      return '通報対象のユーザーIDが見つかりません。';
    }

    final sessionResult = await _authRepository.restoreSession();
    return sessionResult.when(
      success: (session) async {
        if (session == null) {
          return '先に認証してください。';
        }

        final reportResult = await _timelineRepository.createReport(
          session,
          userId: targetNote.user.id,
          noteId: targetNote.id,
          category: category,
          userComment: userComment,
          noteUrl: targetNote.url,
        );
        return reportResult.when(
          success: (_) => null,
          failure: (error, _) => '通報に失敗しました: $error',
        );
      },
      failure: (error, _) async => 'セッション取得に失敗しました: $error',
    );
  }

  Future<String?> deleteNote(Note note) async {
    final targetNote = note.noteType == NoteType.pureRenote
        ? note.renote ?? note
        : note;
    if (targetNote.id.isEmpty) {
      return '削除対象のノートIDが見つかりません。';
    }

    final sessionResult = await _authRepository.restoreSession();
    return sessionResult.when(
      success: (session) async {
        if (session == null) {
          return '先に認証してください。';
        }

        final deleteResult = await _timelineRepository.deleteNote(
          session,
          noteId: targetNote.id,
        );
        return deleteResult.when(
          success: (_) {
            _removeDeletedNote(targetNote.id);
            return null;
          },
          failure: (error, _) => '投稿の削除に失敗しました: $error',
        );
      },
      failure: (error, _) async => 'セッション取得に失敗しました: $error',
    );
  }

  /// 純粋リノートを解除する。
  ///
  /// ラッパーノード（[note].id）を対象に削除APIを呼び、
  /// 成功後にプロフィールのノート一覧から該当カードを除去する。
  Future<String?> undoRenote(Note note) async {
    if (note.id.isEmpty) {
      return 'リノート解除対象のノートIDが見つかりません。';
    }

    final sessionResult = await _authRepository.restoreSession();
    return sessionResult.when(
      success: (session) async {
        if (session == null) {
          return '先に認証してください。';
        }

        final deleteResult = await _timelineRepository.deleteNote(
          session,
          noteId: note.id,
        );
        return deleteResult.when(
          success: (_) {
            _removeDeletedNote(note.id);
            return null;
          },
          failure: (error, _) => 'リノートの解除に失敗しました: $error',
        );
      },
      failure: (error, _) async => 'セッション取得に失敗しました: $error',
    );
  }

  void _removeDeletedNote(String targetNoteId) {
    bool keep(Note note) =>
        note.id != targetNoteId && note.renote?.id != targetNoteId;

    _state = _state.copyWith(
      allNotes: List<Note>.unmodifiable(
        _state.allNotes.where(keep).toList(growable: false),
      ),
      noteOnlyNotes: List<Note>.unmodifiable(
        _state.noteOnlyNotes.where(keep).toList(growable: false),
      ),
      mediaNotes: List<Note>.unmodifiable(
        _state.mediaNotes.where(keep).toList(growable: false),
      ),
    );
    notifyListeners();
  }

  /// 「全て」タブの追加読み込みを実行する
  Future<void> loadMoreAllNotes(String userId) =>
      _loadMoreByTab(userId, _ProfileNotesTab.all);

  /// 「ノート」タブの追加読み込みを実行する
  Future<void> loadMoreNoteOnlyNotes(String userId) =>
      _loadMoreByTab(userId, _ProfileNotesTab.noteOnly);

  /// 「メディア」タブの追加読み込みを実行する
  Future<void> loadMoreMediaNotes(String userId) =>
      _loadMoreByTab(userId, _ProfileNotesTab.media);

  Future<void> _loadMoreByTab(String userId, _ProfileNotesTab tab) async {
    final currentState = _state;
    if (currentState.status != ProfileStatus.loaded) {
      return;
    }

    final tabState = _tabState(currentState, tab);
    if (tabState.isLoadingMore ||
        tabState.untilId == null ||
        tabState.notes.isEmpty) {
      return;
    }

    _state = _setLoadingMore(_state, tab, isLoading: true);
    notifyListeners();

    final sessionResult = await _authRepository.restoreSession();
    await sessionResult.when(
      success: (session) async {
        if (session == null) {
          _state = _setLoadingMore(_state, tab, isLoading: false);
          return;
        }

        final options = _fetchOptionsFor(tab);
        final result = await _profileRepository.fetchUserNotes(
          session,
          userId,
          limit: _notesPageSize,
          withReplies: options.withReplies,
          withRenotes: options.withRenotes,
          withFiles: options.withFiles,
          withChannelNotes: true,
          allowPartial: true,
          untilId: tabState.untilId,
        );

        result.when(
          success: (newNotes) {
            if (newNotes.isNotEmpty) {
              _state = _appendNotes(_state, tab, newNotes);
            }
          },
          failure: (error, _) {},
        );
        _state = _setLoadingMore(_state, tab, isLoading: false);
      },
      failure: (error, _) {
        _state = _setLoadingMore(_state, tab, isLoading: false);
      },
    );

    notifyListeners();
  }

  _PagedTabState _tabState(ProfileScreenState state, _ProfileNotesTab tab) {
    return switch (tab) {
      _ProfileNotesTab.all => _PagedTabState(
        notes: state.allNotes,
        untilId: state.allNotesUntilId,
        isLoadingMore: state.isLoadingMoreAllNotes,
      ),
      _ProfileNotesTab.noteOnly => _PagedTabState(
        notes: state.noteOnlyNotes,
        untilId: state.noteOnlyNotesUntilId,
        isLoadingMore: state.isLoadingMoreNoteOnlyNotes,
      ),
      _ProfileNotesTab.media => _PagedTabState(
        notes: state.mediaNotes,
        untilId: state.mediaNotesUntilId,
        isLoadingMore: state.isLoadingMoreMediaNotes,
      ),
    };
  }

  ({bool withReplies, bool withRenotes, bool withFiles}) _fetchOptionsFor(
    _ProfileNotesTab tab,
  ) {
    return switch (tab) {
      _ProfileNotesTab.all => (
        withReplies: true,
        withRenotes: true,
        withFiles: false,
      ),
      _ProfileNotesTab.noteOnly => (
        withReplies: false,
        withRenotes: false,
        withFiles: false,
      ),
      _ProfileNotesTab.media => (
        withReplies: false,
        withRenotes: false,
        withFiles: true,
      ),
    };
  }

  ProfileScreenState _setLoadingMore(
    ProfileScreenState state,
    _ProfileNotesTab tab, {
    required bool isLoading,
  }) {
    return switch (tab) {
      _ProfileNotesTab.all => state.copyWith(isLoadingMoreAllNotes: isLoading),
      _ProfileNotesTab.noteOnly => state.copyWith(
        isLoadingMoreNoteOnlyNotes: isLoading,
      ),
      _ProfileNotesTab.media => state.copyWith(
        isLoadingMoreMediaNotes: isLoading,
      ),
    };
  }

  ProfileScreenState _appendNotes(
    ProfileScreenState state,
    _ProfileNotesTab tab,
    List<Note> newNotes,
  ) {
    final currentNotes = _tabState(state, tab).notes;
    final merged = List<Note>.unmodifiable([...currentNotes, ...newNotes]);
    return switch (tab) {
      _ProfileNotesTab.all => state.copyWith(
        allNotes: merged,
        allNotesUntilId: newNotes.last.id,
      ),
      _ProfileNotesTab.noteOnly => state.copyWith(
        noteOnlyNotes: merged,
        noteOnlyNotesUntilId: newNotes.last.id,
      ),
      _ProfileNotesTab.media => state.copyWith(
        mediaNotes: merged,
        mediaNotesUntilId: newNotes.last.id,
      ),
    };
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

enum _ProfileNotesTab { all, noteOnly, media }

class _PagedTabState {
  const _PagedTabState({
    required this.notes,
    required this.untilId,
    required this.isLoadingMore,
  });

  final List<Note> notes;
  final String? untilId;
  final bool isLoadingMore;
}
