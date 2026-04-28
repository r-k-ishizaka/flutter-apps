import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:core/models/result.dart';
import 'package:flutter/foundation.dart';

import '../datasources/timeline_connection.dart';
import '../datasources/timeline_data_source.dart';
import '../datasources/timeline_stream_event.dart';
import '../models/auth_session.dart';
import '../models/note.dart';

class TimelineRepository {
  TimelineRepository(this._dataSource);

  final TimelineDataSource _dataSource;
  static const int _maxSubscribedNotes = 200;

  Future<Result<void>> createReaction(
    AuthSession session, {
    required String noteId,
    required String reaction,
  }) async {
    try {
      await _dataSource.createReaction(
        session,
        noteId: noteId,
        reaction: reaction,
      );
      return const Success(null);
    } on Exception catch (e, st) {
      return Failure(e, st);
    }
  }

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
    var subscribedNoteIds = LinkedHashSet<String>();
    initial.when(
      success: (notes) {
        current = notes;
        subscribedNoteIds = _extractSubscribableNoteIds(current);
      },
      failure: (_, _) {},
    );

    while (true) {
      final channelId = DateTime.now().microsecondsSinceEpoch.toString();
      final connection = _dataSource.openConnection(session);

      try {
        connection.connectChannel(channelId);
        for (final id in subscribedNoteIds) {
          connection.subscribeNote(id);
        }

        await for (final message in connection.messages) {
          final event = await parseStreamEvent(session, message, channelId);
          if (event == null) continue;

          switch (event) {
            case TimelineNoteReceived(:final note):
              if (current.any((item) => item.id == note.id)) {
                continue;
              }

              current = [note, ...current];
              if (current.length > limit) {
                current = current.sublist(0, limit);
              }

              final nextIds = _extractSubscribableNoteIds(current);
              _syncSubscriptions(connection, subscribedNoteIds, nextIds);
              subscribedNoteIds = nextIds;

              yield Success(List<Note>.unmodifiable(current));

            case TimelineReactionUpdated(
              :final noteId,
              :final reaction,
              :final delta,
            ):
              final updated = <Note>[];
              var hasChanged = false;

              for (final item in current) {
                if (item.id == noteId) {
                  final updatedNote = item.applyReactionDelta(reaction, delta);
                  updated.add(updatedNote);
                  hasChanged = true;
                  continue;
                }

                final renote = item.renote;
                if (renote != null && renote.id == noteId) {
                  final updatedRenote = renote.applyReactionDelta(reaction, delta);
                  updated.add(
                    item.copyWith(renote: updatedRenote),
                  );
                  hasChanged = true;
                  continue;
                }

                updated.add(item);
              }

              if (!hasChanged) {
                continue;
              }

              current = List<Note>.unmodifiable(updated);
              yield Success(current);
          }
        }
      } on Exception catch (e, st) {
        yield Failure(e, st);
      } finally {
        for (final id in subscribedNoteIds) {
          connection.unsubscribeNote(id);
        }
        connection.disconnectChannel(channelId);
        await connection.close();
      }

      await Future<void>.delayed(reconnectDelay);
    }
  }

  /// Visible for testing.
  @visibleForTesting
  Future<TimelineStreamEvent?> parseStreamEvent(
    AuthSession session,
    dynamic message,
    String channelId,
  ) async {
    final decoded = _decodeMessage(message);
    if (decoded is! Map) return null;

    final root = Map<String, dynamic>.from(decoded);
    final type = root['type'] as String?;

    // Misskey generally wraps channel payloads in {type: channel, body: {...}}.
    // Some environments emit noteUpdated at the top level, so both are handled.
    switch (type) {
      case 'channel':
        final channelBody = _asMap(root['body']);
        if (channelBody['id'] != channelId) return null;
        return _parseChannelEvent(session, channelBody);
      case 'noteUpdated':
        return _parseNoteUpdatedEvent(root);
      default:
        return _parseChannelEvent(session, root);
    }
  }

  Future<TimelineStreamEvent?> _parseChannelEvent(
    AuthSession session,
    Map<String, dynamic> payload,
  ) async {
    final type = payload['type'] as String?;
    if (type == null) return null;

    switch (type) {
      case 'note':
        return _parseNoteReceived(session, payload);
      default:
        return null;
    }
  }

  TimelineStreamEvent? _parseNoteUpdatedEvent(Map<String, dynamic> payload) {
    if (payload['type'] != 'noteUpdated') return null;

    final body = _asMap(payload['body']);
    final noteId = body['id'] as String? ?? '';
    if (noteId.isEmpty) return null;

    final updateType = body['type'] as String?;
    switch (updateType) {
      case 'reacted':
      case 'unreacted':
        final updateBody = _asMap(body['body']);
        final reaction = updateBody['reaction'] as String? ?? '';
        if (reaction.isEmpty) return null;

        final delta = updateType == 'reacted' ? 1 : -1;
        return TimelineReactionUpdated(
          noteId: noteId,
          reaction: reaction,
          delta: delta,
        );
      default:
        return null;
    }
  }

  Future<TimelineStreamEvent?> _parseNoteReceived(
    AuthSession session,
    Map<String, dynamic> payload,
  ) async {
    final body = _asMap(payload['body']);
    final noteJson = body['note'] is Map ? _asMap(body['note']) : body;
    final noteId = noteJson['id'] as String? ?? '';
    if (noteId.isEmpty) return null;

    if (_hasFullNotePayload(noteJson)) {
      return TimelineNoteReceived(Note.fromJson(noteJson));
    }

    final fetched = await _dataSource.fetchNote(session, noteId);
    return TimelineNoteReceived(fetched);
  }

  void _syncSubscriptions(
    TimelineConnection connection,
    LinkedHashSet<String> current,
    LinkedHashSet<String> next,
  ) {
    for (final id in next) {
      if (!current.contains(id)) connection.subscribeNote(id);
    }
    for (final id in current) {
      if (!next.contains(id)) connection.unsubscribeNote(id);
    }
  }

  LinkedHashSet<String> _extractSubscribableNoteIds(List<Note> notes) {
    final ids = LinkedHashSet<String>();
    for (final note in notes) {
      if (note.id.isNotEmpty) ids.add(note.id);
      final renoteId = note.renote?.id;
      if (renoteId != null && renoteId.isNotEmpty) ids.add(renoteId);
      if (ids.length >= _maxSubscribedNotes) break;
    }
    return ids;
  }

  bool _hasFullNotePayload(Map<String, dynamic> noteJson) {
    return noteJson['createdAt'] is String && noteJson['user'] is Map;
  }

  Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const <String, dynamic>{};
  }

  dynamic _decodeMessage(dynamic message) {
    if (message is Map<String, dynamic>) return message;
    if (message is Map) return Map<String, dynamic>.from(message);
    if (message is String) return jsonDecode(message);
    if (message is List<int>) return jsonDecode(utf8.decode(message));
    return null;
  }
}
