import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:light_key/datasources/timeline_connection.dart';
import 'package:light_key/datasources/timeline_data_source.dart';
import 'package:light_key/datasources/timeline_stream_event.dart';
import 'package:light_key/models/auth_session.dart';
import 'package:light_key/models/note.dart';
import 'package:light_key/models/user.dart';
import 'package:light_key/repositories/timeline_repository.dart';

void main() {
  const session = AuthSession(
    baseUrl: 'https://misskey.example',
    accessToken: 'token-123',
  );

  group('TimelineRepository.parseStreamEvent', () {
    test('IDだけの note イベントは fetchNote で補完する', () async {
      final dataSource = _FakeTimelineDataSource(
        onFetchNote: (s, noteId) async {
          expect(s.baseUrl, session.baseUrl);
          expect(noteId, 'alkt4q1jnrp406d5');
          return Note(
            id: 'alkt4q1jnrp406d5',
            text: 'hello stream',
            createdAt: DateTime(2026, 4, 27),
            user: const User(id: 'user-1', username: 'alice', name: 'Alice'),
            reactions: const {':iinaa2@.:': 1},
          );
        },
      );
      final repository = TimelineRepository(dataSource);

      final event = await repository.parseStreamEvent(
        session,
        jsonEncode({
          'type': 'channel',
          'body': {
            'id': '2',
            'type': 'note',
            'body': {'id': 'alkt4q1jnrp406d5'},
          },
        }),
        '2',
      );

      expect(event, isA<TimelineNoteReceived>());
      final note = (event as TimelineNoteReceived).note;
      expect(note.id, 'alkt4q1jnrp406d5');
      expect(note.text, 'hello stream');
      expect(note.user.username, 'alice');
      expect(dataSource.fetchNoteCalls, hasLength(1));
    });

    test('完全な note payload はそのまま Note に変換する', () async {
      final dataSource = _FakeTimelineDataSource();
      final repository = TimelineRepository(dataSource);

      final event = await repository.parseStreamEvent(
        session,
        {
          'type': 'channel',
          'body': {
            'id': '2',
            'type': 'note',
            'body': {
              'id': 'note-1',
              'text': 'full payload',
              'createdAt': '2026-04-27T00:00:00.000Z',
              'user': {
                'id': 'user-1',
                'username': 'alice',
                'name': 'Alice',
              },
            },
          },
        },
        '2',
      );

      expect(event, isA<TimelineNoteReceived>());
      final note = (event as TimelineNoteReceived).note;
      expect(note.id, 'note-1');
      expect(note.text, 'full payload');
      expect(dataSource.fetchNoteCalls, isEmpty);
    });

    test('トップレベルの noteUpdated/reacted を解析できる', () async {
      final dataSource = _FakeTimelineDataSource();
      final repository = TimelineRepository(dataSource);

      final event = await repository.parseStreamEvent(
        session,
        jsonEncode({
          'type': 'noteUpdated',
          'body': {
            'id': 'alkm6x9nsgfz07g1',
            'type': 'reacted',
            'body': {
              'reaction': ':iinaa2@.:',
              'emoji': {
                'name': 'iinaa2@.',
                'url': 'https://media.misskeyusercontent.jp/example.png',
              },
              'userId': '9go45mlq5n',
            },
          },
        }),
        '2',
      );

      expect(event, isA<TimelineReactionUpdated>());
      final update = event as TimelineReactionUpdated;
      expect(update.noteId, 'alkm6x9nsgfz07g1');
      expect(update.reaction, ':iinaa2@.:');
      expect(update.delta, 1);
      expect(dataSource.fetchNoteCalls, isEmpty);
    });
  });
}

typedef _FetchNoteHandler = Future<Note> Function(AuthSession, String);

class _FakeTimelineDataSource implements TimelineDataSource {
  _FakeTimelineDataSource({this.onFetchNote});

  final _FetchNoteHandler? onFetchNote;
  final List<String> fetchNoteCalls = [];

  @override
  Future<List<Note>> fetchTimeline(AuthSession session, {int limit = 20}) {
    throw UnimplementedError();
  }

  @override
  Future<Note> fetchNote(AuthSession session, String noteId) async {
    fetchNoteCalls.add(noteId);
    final handler = onFetchNote;
    if (handler == null) {
      throw UnimplementedError('fetchNote was not expected in this test.');
    }
    return handler(session, noteId);
  }

  @override
  TimelineConnection openConnection(AuthSession session) {
    throw UnimplementedError();
  }
}
