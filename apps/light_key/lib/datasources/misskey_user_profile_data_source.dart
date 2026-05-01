import '../models/auth_session.dart';
import '../models/note.dart';
import '../models/user_profile.dart';
import '../utils/misskey_http_client.dart';
import 'user_profile_data_source.dart';

class MisskeyUserProfileDataSource implements UserProfileDataSource {
  MisskeyUserProfileDataSource(this._client);

  final MisskeyHttpClient _client;

  @override
  Future<UserProfile> fetchUserProfile(
    AuthSession session,
    String userId,
  ) async {
    final response = await _client.postJson(
      baseUrl: session.baseUrl,
      path: '/api/users/show',
      body: {'i': session.accessToken, 'userId': userId},
    );
    return UserProfile.fromJson(response);
  }

  @override
  Future<List<Note>> fetchUserNotes(
    AuthSession session,
    String userId, {
    int limit = 50,
    bool withReplies = true,
    bool withRenotes = true,
    bool withFiles = false,
    bool withChannelNotes = true,
    bool allowPartial = false,
  }) async {
    final response = await _client.postJsonList(
      baseUrl: session.baseUrl,
      path: '/api/users/notes',
      body: {
        'i': session.accessToken,
        'userId': userId,
        'limit': limit,
        'withRenotes': withRenotes,
        'withReplies': withReplies,
        'withFiles': withFiles,
        'withChannelNotes': withChannelNotes,
        'allowPartial': allowPartial,
      },
    );
    return response.map(Note.fromJson).toList(growable: false);
  }
}
