// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Note _$NoteFromJson(Map<String, dynamic> json) => _Note(
  id: json['id'] as String? ?? '',
  text: json['text'] as String? ?? '',
  createdAt: DateTime.parse(json['createdAt'] as String),
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  files:
      (json['files'] as List<dynamic>?)
          ?.map((e) => NoteFile.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <NoteFile>[],
  reactions: json['reactions'] == null
      ? const <String, int>{}
      : _reactionsFromJson(json['reactions']),
  myReaction: json['myReaction'] as String?,
  renote: json['renote'] == null
      ? null
      : Note.fromJson(json['renote'] as Map<String, dynamic>),
);

Map<String, dynamic> _$NoteToJson(_Note instance) => <String, dynamic>{
  'id': instance.id,
  'text': instance.text,
  'createdAt': instance.createdAt.toIso8601String(),
  'user': instance.user,
  'files': instance.files,
  'reactions': instance.reactions,
  'myReaction': instance.myReaction,
  'renote': instance.renote,
};
