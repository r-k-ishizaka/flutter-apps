import 'dart:async';

import 'package:core/models/result.dart';

import '../datasources/timeline_data_source.dart';
import '../datasources/timeline_stream_event.dart';
import '../models/auth_session.dart';
import '../models/note.dart';

class TimelineRepository {
  TimelineRepository(this._dataSource);

  final TimelineDataSource _dataSource;

  Future<Result<List<Note>>> fetchTimeline(
    AuthSession session, {
    int limit = 20,
  }) async {
    try {
      final notes = await _dataSource.fetchTimeline(session, limit: limit);
      return Success(notes);
    } on Exception catch (e, st) {
      return Failure(e, st);
    }
  }

  Stream<Result<List<Note>>> watchTimeline(
    AuthSession session, {
    int limit = 20,
    Duration reconnectDelay = const Duration(seconds: 2),
  }) async* {
    final initial = await fetchTimeline(session, limit: limit);
    yield initial;

    var current = <Note>[];
    initial.when(
      success: (notes) => current = notes,
      failure: (_, _) {},
    );

    while (true) {
      try {
        await for (final event in _dataSource.watchTimeline(session)) {
          switch (event) {
            case TimelineNoteReceived(:final note):
              if (current.any((item) => item.id == note.id)) {
                continue;
              }

              current = [note, ...current];
              if (current.length > limit) {
                current = current.sublist(0, limit);
              }

              yield Success(List<Note>.unmodifiable(current));
            case TimelineReactionUpdated(:final noteId, :final reaction, :final delta):
              final index = current.indexWhere((item) => item.id == noteId);
              if (index == -1) {
                continue;
              }

              final updated = List<Note>.from(current);
              updated[index] = updated[index].applyReactionDelta(reaction, delta);
              current = List<Note>.unmodifiable(updated);
              yield Success(current);
          }
        }
      } on Exception catch (e, st) {
        yield Failure(e, st);
      }

      await Future<void>.delayed(reconnectDelay);
    }
  }
}
