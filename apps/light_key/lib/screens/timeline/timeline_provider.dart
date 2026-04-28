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

  Future<void> fetch({bool showLoading = true}) async {
    final shouldShowLoading = showLoading || _state.notes.isEmpty;

    if (shouldShowLoading) {
      _state = _state.copyWith(
        status: TimelineStatus.loading,
        isRefreshing: false,
        clearMessage: true,
      );
      notifyListeners();
    } else {
      _state = _state.copyWith(isRefreshing: true, clearMessage: true);
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
            _state = _state.copyWith(
              status: TimelineStatus.loaded,
              notes: notes,
              isRefreshing: false,
              clearMessage: true,
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
    if (_state.notes.isEmpty) {
      _state = _state.copyWith(
        status: TimelineStatus.loading,
        isRefreshing: false,
        clearMessage: true,
      );
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
                    _state = _state.copyWith(
                      status: TimelineStatus.loaded,
                      notes: notes,
                      isRefreshing: false,
                      clearMessage: true,
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
          success: (_) => null,
          failure: (error, _) => 'リアクション送信に失敗しました: $error',
        );
      },
      failure: (error, _) async => 'セッション取得に失敗しました: $error',
    );
  }

  @override
  void dispose() {
    unawaited(stopRealtime());
    super.dispose();
  }

  void _setTimelineError(String message) {
    _state = _state.copyWith(
      status: _state.notes.isEmpty
          ? TimelineStatus.error
          : TimelineStatus.loaded,
      isRefreshing: false,
      message: message,
    );
  }
}
