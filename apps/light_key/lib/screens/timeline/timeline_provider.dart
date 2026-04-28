import 'dart:async';

import 'package:core/models/result.dart';
import 'package:flutter/foundation.dart';

import '../../models/note.dart';
import '../../models/note_type.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/timeline_repository.dart';
import 'timeline_screen_state.dart';

class TimelineProvider extends ChangeNotifier {
  TimelineProvider({
    required AuthRepository authRepository,
    required TimelineRepository timelineRepository,
  }) : _authRepository = authRepository,
       _timelineRepository = timelineRepository;

  final AuthRepository _authRepository;
  final TimelineRepository _timelineRepository;

  StreamSubscription<Result<List<Note>>>? _timelineSubscription;

  TimelineScreenState _state = const TimelineScreenState.idle();
  TimelineScreenState get state => _state;

  List<Note> get _loadedNotes => switch (_state) {
    TimelineScreenStateLoaded(:final notes) => notes,
    _ => const <Note>[],
  };

  Future<void> fetch({bool showLoading = true}) async {
    final previousNotes = _loadedNotes;
    final shouldShowLoading = showLoading || previousNotes.isEmpty;

    if (shouldShowLoading) {
      _state = const TimelineScreenState.loading();
      notifyListeners();
    } else {
      _state = TimelineScreenState.loaded(
        notes: previousNotes,
        isRefreshing: true,
      );
      notifyListeners();
    }

    await Future<void>.delayed(const Duration(milliseconds: 500));

    final sessionResult = await _authRepository.restoreSession();
    await sessionResult.when(
      success: (session) async {
        if (session == null) {
          _setTimelineError('先に認証してください。');
          return;
        }

        final timelineResult = await _timelineRepository.fetchTimeline(session);
        timelineResult.when(
          success: (notes) {
            final currentNotes = _loadedNotes;
            _state = TimelineScreenState.loaded(
              notes: _mergeNotesPreservingMyReaction(currentNotes, notes),
              isRefreshing: false,
            );
          },
          failure: (error, _) {
            _setTimelineError('タイムライン取得に失敗しました: $error');
          },
        );
      },
      failure: (error, _) {
        _setTimelineError('セッション取得に失敗しました: $error');
      },
    );

    notifyListeners();
  }

  Future<void> startRealtime() async {
    await stopRealtime();

    // 前のデータがない場合のみ loading 状態をセット
    if (_loadedNotes.isEmpty) {
      _state = const TimelineScreenState.loading();
      notifyListeners();
    }

    final sessionResult = await _authRepository.restoreSession();
    await sessionResult.when(
      success: (session) async {
        if (session == null) {
          _setTimelineError('先に認証してください。');
          notifyListeners();
          return;
        }

        _timelineSubscription = _timelineRepository
            .watchTimeline(session)
            .listen(
              (timelineResult) {
                timelineResult.when(
                  success: (notes) {
                    final currentNotes = _loadedNotes;
                    _state = TimelineScreenState.loaded(
                      notes: _mergeNotesPreservingMyReaction(
                        currentNotes,
                        notes,
                      ),
                      isRefreshing: false,
                    );
                  },
                  failure: (error, _) {
                    _setTimelineError('タイムライン取得に失敗しました: $error');
                  },
                );
                notifyListeners();
              },
              onError: (error) {
                _setTimelineError('リアルタイム購読でエラーが発生しました: $error');
                notifyListeners();
              },
              cancelOnError: true, // エラー発生時にサブスクリプションを自動解除
            );
      },
      failure: (error, _) {
        _setTimelineError('セッション取得に失敗しました: $error');
        notifyListeners();
      },
    );
  }

  Future<void> stopRealtime() async {
    await _timelineSubscription?.cancel();
    _timelineSubscription = null;
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
            _applyMyReaction(note, targetNote.id, normalizedReaction);
            return null;
          },
          failure: (error, _) => 'リアクション送信に失敗しました: $error',
        );
      },
      failure: (error, _) async => 'セッション取得に失敗しました: $error',
    );
  }

  /// リアクション送信成功後にローカル状態の myReaction を更新する。
  void _applyMyReaction(Note note, String targetNoteId, String reaction) {
    final loadedState = switch (_state) {
      TimelineScreenStateLoaded() => _state as TimelineScreenStateLoaded,
      _ => null,
    };
    if (loadedState == null) {
      return;
    }

    final updatedNotes = loadedState.notes.map((item) {
      // 直接の note に一致する場合
      if (item.id == targetNoteId) {
        return item.copyWith(myReaction: reaction);
      }
      // 純粋リノートのリノート元に一致する場合
      final renote = item.renote;
      if (renote != null && renote.id == targetNoteId) {
        return item.copyWith(renote: renote.copyWith(myReaction: reaction));
      }
      return item;
    }).toList(growable: false);

    _state = loadedState.copyWith(
      notes: List<Note>.unmodifiable(updatedNotes),
    );
    notifyListeners();
  }

  List<Note> _mergeNotesPreservingMyReaction(
    List<Note> current,
    List<Note> incoming,
  ) {
    final currentById = <String, Note>{};
    for (final note in current) {
      if (note.id.isNotEmpty) {
        currentById[note.id] = note;
      }

      final renote = note.renote;
      if (renote != null && renote.id.isNotEmpty) {
        currentById[renote.id] = renote;
      }
    }

    return List<Note>.unmodifiable(
      incoming
          .map(
            (note) => _mergeNotePreservingMyReaction(
              note,
              currentById[note.id],
              currentById,
            ),
          )
          .toList(growable: false),
    );
  }

  Note _mergeNotePreservingMyReaction(
    Note incoming,
    Note? current,
    Map<String, Note> currentById,
  ) {
    final matchedCurrent = current ?? currentById[incoming.id];
    final mergedRenote = switch (incoming.renote) {
      final renote? => _mergeNotePreservingMyReaction(
        renote,
        matchedCurrent?.renote,
        currentById,
      ),
      null => null,
    };

    return incoming.copyWith(
      myReaction: incoming.myReaction ?? matchedCurrent?.myReaction,
      renote: mergedRenote,
    );
  }

  @override
  void dispose() {
    unawaited(stopRealtime());
    super.dispose();
  }

  void _setTimelineError(String message) {
    final currentState = _state;
    if (currentState is! TimelineScreenStateLoaded) {
      _state = TimelineScreenState.error(message: message);
      return;
    }

    _state = currentState.copyWith(isRefreshing: false, message: message);
  }
}
