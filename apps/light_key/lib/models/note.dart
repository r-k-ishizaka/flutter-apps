import 'package:freezed_annotation/freezed_annotation.dart';

import 'note_file.dart';
import 'note_type.dart';
import 'user.dart';

part 'note.freezed.dart';
part 'note.g.dart';

@freezed
sealed class Note with _$Note {
  const Note._();

  const factory Note({
    @Default('') String id,
    @Default('') String text,
    required DateTime createdAt,
    required User user,
    @Default(<NoteFile>[])
    List<NoteFile> files,
    @JsonKey(fromJson: _reactionsFromJson)
    @Default(<String, int>{})
    Map<String, int> reactions,

    /// リノート元のノート。純粋リノート・引用リノートの場合に設定される。
    Note? renote,
  }) = _Note;

  factory Note.fromJson(Map<String, dynamic> json) =>
      _$NoteFromJson(_normalizeNoteJson(json));

  Note applyReactionDelta(String reaction, int delta) {
    if (reaction.isEmpty || delta == 0) {
      return this;
    }

    final next = Map<String, int>.from(reactions);
    final updated = (next[reaction] ?? 0) + delta;
    if (updated <= 0) {
      next.remove(reaction);
    } else {
      next[reaction] = updated;
    }

    return copyWith(reactions: next);
  }

  NoteType get noteType {
    if (renote == null) return NoteType.normal;
    if (text.isEmpty) return NoteType.pureRenote;
    return NoteType.quoteRenote;
  }
}

Map<String, dynamic> _normalizeNoteJson(Map<String, dynamic> json) {
  return {
    ...json,
    'id': json['id'] as String? ?? '',
    'text': json['text'] as String? ?? '',
    'createdAt': json['createdAt'] is String
        ? json['createdAt']
        : DateTime.fromMillisecondsSinceEpoch(0).toIso8601String(),
    'user': json['user'] is Map ? json['user'] : const <String, dynamic>{},
    'files': json['files'] is List ? json['files'] : const <dynamic>[],
    'renote': json['renote'] is Map ? json['renote'] : null,
  };
}

Map<String, int> _reactionsFromJson(Object? value) {
  final reactionsJson = Map<String, dynamic>.from(value as Map? ?? const {});
  return reactionsJson.map(
    (key, reactionValue) =>
        MapEntry(key, (reactionValue as num?)?.toInt() ?? 0),
  );
}
