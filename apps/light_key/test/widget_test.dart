import 'package:flutter_test/flutter_test.dart';
import 'package:light_key/models/note.dart';

void main() {
  test('Note.fromJson maps key fields', () {
    final note = Note.fromJson({
      'id': 'note-1',
      'text': 'hello',
      'createdAt': '2026-04-25T00:00:00.000Z',
      'user': {
        'id': 'user-1',
        'username': 'kikuchi',
        'name': 'Kikuchi',
      },
    });

    expect(note.id, 'note-1');
    expect(note.text, 'hello');
    expect(note.user.username, 'kikuchi');
  });
}
