import 'package:freezed_annotation/freezed_annotation.dart';

import 'note_file_properties.dart';

part 'note_file.freezed.dart';

part 'note_file.g.dart';

@freezed
sealed class NoteFile with _$NoteFile {
  const NoteFile._();

  const factory NoteFile({
    @Default('') String id,
    @Default('') String type,
    String? thumbnailUrl,
    @Default('') String url,
    String? blurhash,
    @Default(false) bool isSensitive,
    NoteFileProperties? properties,
  }) = _NoteFile;

  bool get isImage => type.startsWith('image/');

  factory NoteFile.fromJson(Map<String, dynamic> json) =>
      _$NoteFileFromJson(_normalizeNoteFileJson(json));
}

Map<String, dynamic> _normalizeNoteFileJson(Map<String, dynamic> json) {
  return {
    ...json,
    'id': json['id'] as String? ?? '',
    'type': json['type'] as String? ?? '',
    'url': json['url'] as String? ?? '',
    'isSensitive': json['isSensitive'] as bool? ?? false,
    'properties': json['properties'] is Map ? json['properties'] : null,
  };
}
