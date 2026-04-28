import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/note.dart';

part 'timeline_screen_state.freezed.dart';

@freezed
sealed class TimelineScreenState with _$TimelineScreenState {
  const factory TimelineScreenState.idle() = TimelineScreenStateIdle;

  const factory TimelineScreenState.loading() = TimelineScreenStateLoading;

  const factory TimelineScreenState.loaded({
    @Default(<Note>[]) List<Note> notes,
    @Default(false) bool isRefreshing,
    String? message,
  }) = TimelineScreenStateLoaded;

  const factory TimelineScreenState.error({String? message}) =
      TimelineScreenStateError;
}
