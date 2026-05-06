import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/note.dart';

part 'note_detail_screen_state.freezed.dart';

@freezed
sealed class NoteDetailScreenState with _$NoteDetailScreenState {
  const factory NoteDetailScreenState.idle() = NoteDetailScreenStateIdle;

  const factory NoteDetailScreenState.loading() = NoteDetailScreenStateLoading;

  const factory NoteDetailScreenState.loaded({
    required Note note,
    String? message,
  }) = NoteDetailScreenStateLoaded;

  const factory NoteDetailScreenState.error({String? message}) =
      NoteDetailScreenStateError;
}
