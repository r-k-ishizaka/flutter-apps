import 'user.dart';

class Note {
  const Note({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.user,
  });

  final String id;
  final String text;
  final DateTime createdAt;
  final User user;

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      user: User.fromJson(
        Map<String, dynamic>.from(json['user'] as Map? ?? const {}),
      ),
    );
  }
}
