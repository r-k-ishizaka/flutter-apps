import '../models/auth_session.dart';
import '../models/note.dart';
import '../models/user_profile.dart';

abstract interface class UserProfileDataSource {
  Future<UserProfile> fetchUserProfile(AuthSession session, String userId);

  Future<List<Note>> fetchUserNotes(
    AuthSession session,
    String userId, {
    int limit = 50,
    bool includeReplies = true,
    bool includeRenotes = true,
    bool withFiles = false,
  });

  Future<List<Note>> fetchUserPinnedNotes(AuthSession session, String userId);
}
