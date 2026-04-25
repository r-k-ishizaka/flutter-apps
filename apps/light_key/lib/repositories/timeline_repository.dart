import 'package:core/models/result.dart';

import '../datasources/timeline_data_source.dart';
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
}
