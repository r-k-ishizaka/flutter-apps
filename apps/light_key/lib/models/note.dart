import 'user.dart';

enum NoteType {
  /// 通常ノート（renote なし）
  normal,

  /// 純粋リノート（本文なし・renote あり）
  pureRenote,

  /// 引用リノート（本文あり・renote あり）
  quoteRenote,
}

class Note {
  const Note({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.user,
    this.renote,
  });

  final String id;
  final String text;
  final DateTime createdAt;
  final User user;

  /// リノート元のノート。純粋リノート・引用リノートの場合に設定される。
  final Note? renote;

  NoteType get noteType {
    if (renote == null) return NoteType.normal;
    if (text.isEmpty) return NoteType.pureRenote;
    return NoteType.quoteRenote;
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    final renoteJson = json['renote'];
    return Note(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      user: User.fromJson(
        Map<String, dynamic>.from(json['user'] as Map? ?? const {}),
      ),
      renote:
          renoteJson != null
              ? Note.fromJson(Map<String, dynamic>.from(renoteJson as Map))
              : null,
    );
  }
}
