// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NoteFile _$NoteFileFromJson(Map<String, dynamic> json) => _NoteFile(
  id: json['id'] as String? ?? '',
  type: json['type'] as String? ?? '',
  thumbnailUrl: json['thumbnailUrl'] as String?,
  url: json['url'] as String? ?? '',
  blurhash: json['blurhash'] as String?,
  isSensitive: json['isSensitive'] as bool? ?? false,
  properties: json['properties'] == null
      ? null
      : NoteFileProperties.fromJson(json['properties'] as Map<String, dynamic>),
);

Map<String, dynamic> _$NoteFileToJson(_NoteFile instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'thumbnailUrl': instance.thumbnailUrl,
  'url': instance.url,
  'blurhash': instance.blurhash,
  'isSensitive': instance.isSensitive,
  'properties': instance.properties,
};
