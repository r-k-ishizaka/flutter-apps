import '../models/auth_session.dart';
import '../models/user_profile.dart';

abstract interface class UserProfileDataSource {
  Future<UserProfile> fetchUserProfile(AuthSession session, String userId);
}
