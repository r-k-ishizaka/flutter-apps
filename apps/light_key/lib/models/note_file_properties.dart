import 'package:freezed_annotation/freezed_annotation.dart';

part 'note_file_properties.freezed.dart';

part 'note_file_properties.g.dart';

@freezed
sealed class NoteFileProperties with _$NoteFileProperties {
  const factory NoteFileProperties({
    @JsonKey(fromJson: _intFromJson) @Default(0) int width,
    @JsonKey(fromJson: _intFromJson) @Default(0) int height,
  }) = _NoteFileProperties;

  factory NoteFileProperties.fromJson(Map<String, dynamic> json) =>
      _$NoteFilePropertiesFromJson(json);
}

int _intFromJson(Object? value) => (value as num?)?.toInt() ?? 0;
