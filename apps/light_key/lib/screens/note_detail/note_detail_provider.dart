import 'package:flutter/foundation.dart';

import '../../models/note.dart';
import '../../models/note_type.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/timeline_repository.dart';
import 'note_detail_screen_state.dart';

class NoteDetailProvider extends ChangeNotifier {
  NoteDetailProvider({
    required AuthRepository authRepository,
    required TimelineRepository timelineRepository,
  }) : _authRepository = authRepository,
       _timelineRepository = timelineRepository;

  final AuthRepository _authRepository;
  final TimelineRepository _timelineRepository;

  NoteDetailScreenState _state = const NoteDetailScreenState.idle();

  NoteDetailScreenState get state => _state;

  Future<void> load(String noteId) async {
    if (noteId.isEmpty) {
      _state = const NoteDetailScreenState.error(message: 'ノートIDが不正です。');
      notifyListeners();
      return;
    }

    _state = const NoteDetailScreenState.loading();
    notifyListeners();

    final sessionResult = await _authRepository.restoreSession();
    await sessionResult.when(
      success: (session) async {
        if (session == null) {
          _state = const NoteDetailScreenState.error(message: '先に認証してください。');
          return;
        }

        final noteResult = await _timelineRepository.fetchNote(
          session,
          noteId: noteId,
        );
        noteResult.when(
          success: (note) {
            _state = NoteDetailScreenState.loaded(note: note);
          },
          failure: (error, _) {
            _state = NoteDetailScreenState.error(
              message: 'ノート詳細の取得に失敗しました: $error',
            );
          },
        );
      },
      failure: (error, _) {
        _state = NoteDetailScreenState.error(message: 'セッション取得に失敗しました: $error');
      },
    );

    notifyListeners();
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

    final outgoingReaction = _normalizeOutgoingReaction(requestedReaction);
    final sessionResult = await _authRepository.restoreSession();
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
            final currentState = _state;
            if (currentState is! NoteDetailScreenStateLoaded) {
              return null;
            }

            final updated = _updateMyReaction(
              currentState.note,
              targetNote.id,
              outgoingReaction,
            );
            _state = currentState.copyWith(note: updated);
            notifyListeners();
            return null;
          },
          failure: (error, _) => 'リアクション送信に失敗しました: $error',
        );
      },
      failure: (error, _) async => 'セッション取得に失敗しました: $error',
    );
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
          success: (_) => null,
          failure: (error, _) => '投稿の削除に失敗しました: $error',
        );
      },
      failure: (error, _) async => 'セッション取得に失敗しました: $error',
    );
  }

  Note _updateMyReaction(Note note, String targetNoteId, String reaction) {
    if (note.id == targetNoteId) {
      return _updateNoteReaction(note, reaction);
    }

    final renote = note.renote;
    if (renote != null && renote.id == targetNoteId) {
      return note.copyWith(renote: _updateNoteReaction(renote, reaction));
    }

    return note;
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

  String _normalizeOutgoingReaction(String reaction) {
    final sameServerDot = RegExp(
      r'^:([a-zA-Z0-9_.-]+)@\.:$',
    ).firstMatch(reaction);
    if (sameServerDot != null) {
      return ':${sameServerDot.group(1)}:';
    }

    return reaction;
  }
}
