import '../models/auth_session.dart';
import '../models/note.dart';
import '../models/response_with_cache_hints.dart';
import '../models/user_profile.dart';

abstract interface class UserProfileDataSource {
  Future<ResponseWithCacheHints<UserProfile>> fetchUserProfile(
    AuthSession session,
    String userId,
  );

  Future<ResponseWithCacheHints<List<Note>>> fetchUserNotes(
    AuthSession session,
    String userId, {
    int limit = 50,
    bool withReplies = true,
    bool withRenotes = true,
    bool withFiles = false,
    bool withChannelNotes = true,
    bool allowPartial = false,
  });
}
