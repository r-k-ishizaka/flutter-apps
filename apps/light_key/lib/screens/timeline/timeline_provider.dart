import 'package:flutter/foundation.dart';

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

  TimelineScreenState _state = const TimelineScreenState.idle();
  TimelineScreenState get state => _state;

  Future<void> fetch() async {
    _state = _state.copyWith(status: TimelineStatus.loading, clearMessage: true);
    notifyListeners();

    final sessionResult = await _authRepository.restoreSession();
    await sessionResult.when(
      success: (session) async {
        if (session == null) {
          _state = _state.copyWith(
            status: TimelineStatus.error,
            message: '先に認証してください。',
          );
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
            _state = _state.copyWith(
              status: TimelineStatus.error,
              message: 'タイムライン取得に失敗しました: $error',
            );
          },
        );
      },
      failure: (error, _) {
        _state = _state.copyWith(
          status: TimelineStatus.error,
          message: 'セッション取得に失敗しました: $error',
        );
      },
    );

    notifyListeners();
  }
}
