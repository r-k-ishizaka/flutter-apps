import 'note_file_properties.dart';

class NoteFile {
  const NoteFile({
    required this.id,
    required this.type,
    this.thumbnailUrl,
    required this.url,
    this.blurhash,
    required this.isSensitive,
    this.properties,
  });

  final String id;
  final String type;
  final String? thumbnailUrl;
  final String url;
  final String? blurhash;
  final bool isSensitive;
  final NoteFileProperties? properties;

  bool get isImage => type.startsWith('image/');

  factory NoteFile.fromJson(Map<String, dynamic> json) {
    return NoteFile(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String?,
      url: json['url'] as String? ?? '',
      blurhash: json['blurhash'] as String?,
      isSensitive: json['isSensitive'] as bool? ?? false,
      properties: json['properties'] is Map
          ? NoteFileProperties.fromJson(
              Map<String, dynamic>.from(json['properties'] as Map),
            )
          : null,
    );
  }
}
