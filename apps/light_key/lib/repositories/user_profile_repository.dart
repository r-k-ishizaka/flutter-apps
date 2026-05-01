import 'package:core/models/result.dart';

import '../datasources/user_profile_data_source.dart';
import '../models/auth_session.dart';
import '../models/note.dart';
import '../models/user_profile.dart';

class UserProfileRepository {
  UserProfileRepository(this._dataSource);

  final UserProfileDataSource _dataSource;

  Future<Result<UserProfile>> fetchUserProfile(
    AuthSession session,
    String userId,
  ) async {
    try {
      final profile = await _dataSource.fetchUserProfile(session, userId);
      return Success(profile);
    } on Exception catch (error, stackTrace) {
      return Failure(error, stackTrace);
    }
  }

  Future<Result<List<Note>>> fetchUserNotes(
    AuthSession session,
    String userId, {
    int limit = 50,
    bool includeReplies = true,
    bool includeRenotes = true,
    bool withFiles = false,
  }) async {
    try {
      final notes = await _dataSource.fetchUserNotes(
        session,
        userId,
        limit: limit,
        includeReplies: includeReplies,
        includeRenotes: includeRenotes,
        withFiles: withFiles,
      );
      return Success(notes);
    } on Exception catch (error, stackTrace) {
      return Failure(error, stackTrace);
    }
  }

  Future<Result<List<Note>>> fetchUserPinnedNotes(
    AuthSession session,
    String userId,
  ) async {
    try {
      final notes = await _dataSource.fetchUserPinnedNotes(session, userId);
      return Success(notes);
    } on Exception catch (error, stackTrace) {
      return Failure(error, stackTrace);
    }
  }
}
