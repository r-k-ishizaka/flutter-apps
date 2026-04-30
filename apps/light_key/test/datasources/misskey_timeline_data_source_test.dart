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

      final event = await repository.parseStreamEvent(session, {
        'type': 'channel',
        'body': {
          'id': '2',
          'type': 'note',
          'body': {
            'id': 'note-1',
            'text': 'full payload',
            'createdAt': '2026-04-27T00:00:00.000Z',
            'user': {'id': 'user-1', 'username': 'alice', 'name': 'Alice'},
          },
        },
      }, '2');

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

  group('TimelineRepository.watchTimeline', () {
    test('新着保留中でも初期表示ノートのリアクション更新を維持する', () async {
      final controller = StreamController<dynamic>();
      final connection = _FakeTimelineConnection(controller.stream);
      final dataSource = _FakeTimelineDataSource(
        onFetchTimeline: (_, {limit = 20}) async => [
          Note(
            id: 'note-2',
            text: 'older-2',
            createdAt: DateTime(2026, 4, 27, 0, 1),
            user: const User(id: 'user-1', username: 'alice', name: 'Alice'),
          ),
          Note(
            id: 'note-1',
            text: 'older-1',
            createdAt: DateTime(2026, 4, 27),
            user: const User(id: 'user-1', username: 'alice', name: 'Alice'),
          ),
        ],
        connection: connection,
      );
      final repository = TimelineRepository(dataSource);

      final emissions = <List<Note>>[];
      final emissionCompleter = Completer<void>();

      final subscription = repository
          .watchTimeline(
            session,
            limit: 2,
            reconnectDelay: const Duration(milliseconds: 1),
          )
          .listen((result) {
            result.when(
              success: (notes) {
                emissions.add(notes);
                if (emissions.length >= 3 && !emissionCompleter.isCompleted) {
                  emissionCompleter.complete();
                }
              },
              failure: (error, stackTrace) {
                if (!emissionCompleter.isCompleted) {
                  emissionCompleter.completeError(error, stackTrace);
                }
              },
            );
          });

      await Future<void>.delayed(const Duration(milliseconds: 10));
      controller.add({
        'type': 'channel',
        'body': {
          'id': connection.connectedChannelId,
          'type': 'note',
          'body': {
            'id': 'note-3',
            'text': 'new',
            'createdAt': '2026-04-27T00:02:00.000Z',
            'user': {'id': 'user-2', 'username': 'bob', 'name': 'Bob'},
          },
        },
      });

      await Future<void>.delayed(const Duration(milliseconds: 10));
      controller.add({
        'type': 'noteUpdated',
        'body': {
          'id': 'note-1',
          'type': 'reacted',
          'body': {'reaction': '👍'},
        },
      });

      await emissionCompleter.future;
      await subscription.cancel();
      await controller.close();

      expect(emissions[0].map((note) => note.id), ['note-2', 'note-1']);
      expect(emissions[1].map((note) => note.id), ['note-3', 'note-2', 'note-1']);
      expect(emissions[2].last.id, 'note-1');
      expect(emissions[2].last.reactions, const {'👍': 1});
    });
  });
}

typedef _FetchNoteHandler = Future<Note> Function(AuthSession, String);
typedef _FetchTimelineHandler = Future<List<Note>> Function(
  AuthSession session, {
  int limit,
});

class _FakeTimelineDataSource implements TimelineDataSource {
  _FakeTimelineDataSource({
    this.onFetchNote,
    this.onFetchTimeline,
    this.connection,
  });

  final _FetchNoteHandler? onFetchNote;
  final _FetchTimelineHandler? onFetchTimeline;
  final TimelineConnection? connection;
  final List<String> fetchNoteCalls = [];

  @override
  Future<void> createReaction(
    AuthSession session, {
    required String noteId,
    required String reaction,
  }) async {}

  @override
  Future<void> createRenote(
    AuthSession session, {
    required String noteId,
  }) async {}

  @override
  Future<List<Note>> fetchTimeline(AuthSession session, {int limit = 20}) async {
    final handler = onFetchTimeline;
    if (handler == null) {
      throw UnimplementedError('fetchTimeline was not expected in this test.');
    }
    return handler(session, limit: limit);
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
    final value = connection;
    if (value == null) {
      throw UnimplementedError('openConnection was not expected in this test.');
    }
    return value;
  }
}

class _FakeTimelineConnection implements TimelineConnection {
  _FakeTimelineConnection(this._messages);

  final Stream<dynamic> _messages;
  final List<String> subscribedNoteIds = [];
  String? connectedChannelId;

  @override
  Future<void> close() async {}

  @override
  void connectChannel(String channelId) {
    connectedChannelId = channelId;
  }

  @override
  void disconnectChannel(String channelId) {}

  @override
  Stream<dynamic> get messages => _messages;

  @override
  void subscribeNote(String noteId) {
    subscribedNoteIds.add(noteId);
  }

  @override
  void unsubscribeNote(String noteId) {
    subscribedNoteIds.remove(noteId);
  }
}
