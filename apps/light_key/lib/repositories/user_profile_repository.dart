import 'package:core/models/result.dart';

import '../datasources/user_profile_data_source.dart';
import '../models/auth_session.dart';
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
}
