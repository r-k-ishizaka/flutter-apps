import 'dart:async';

import 'package:core/models/result.dart';
import 'package:flutter/foundation.dart';

import '../../models/note.dart';
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

  Future<void> fetch() async {
    _state = _state.copyWith(status: TimelineStatus.loading, clearMessage: true);
    notifyListeners();

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

    _state = _state.copyWith(status: TimelineStatus.loading, clearMessage: true);
    notifyListeners();

    final sessionResult = await _authRepository.restoreSession();
    await sessionResult.when(
      success: (session) async {
        if (session == null) {
          _setTimelineError('先に認証してください。');
          notifyListeners();
          return;
        }

        _timelineSubscription = _timelineRepository.watchTimeline(session).listen(
          (timelineResult) {
            timelineResult.when(
              success: (notes) {
                _state = _state.copyWith(
                  status: TimelineStatus.loaded,
                  notes: notes,
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

  @override
  void dispose() {
    unawaited(stopRealtime());
    super.dispose();
  }

  void _setTimelineError(String message) {
    _state = _state.copyWith(
      status: _state.notes.isEmpty ? TimelineStatus.error : TimelineStatus.loaded,
      message: message,
    );
  }
}
