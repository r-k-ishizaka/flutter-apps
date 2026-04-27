import 'note_file.dart';
import 'note_type.dart';
import 'user.dart';

class Note {
  const Note({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.user,
    this.files = const [],
    this.renote,
  });

  final String id;
  final String text;
  final DateTime createdAt;
  final User user;
  final List<NoteFile> files;

  /// リノート元のノート。純粋リノート・引用リノートの場合に設定される。
  final Note? renote;

  NoteType get noteType {
    if (renote == null) return NoteType.normal;
    if (text.isEmpty) return NoteType.pureRenote;
    return NoteType.quoteRenote;
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    final renoteJson = json['renote'];
    final filesJson = json['files'] as List? ?? const [];
    return Note(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      user: User.fromJson(
        Map<String, dynamic>.from(json['user'] as Map? ?? const {}),
      ),
      files: filesJson
          .whereType<Map>()
          .map((file) => NoteFile.fromJson(Map<String, dynamic>.from(file)))
          .toList(growable: false),
      renote: renoteJson != null
          ? Note.fromJson(Map<String, dynamic>.from(renoteJson as Map))
          : null,
    );
  }
}
