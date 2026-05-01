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
    bool includeReplies = true,
    bool includeRenotes = true,
    bool withFiles = false,
  }) async {
    final response = await _client.postJsonList(
      baseUrl: session.baseUrl,
      path: '/api/users/notes',
      body: {
        'i': session.accessToken,
        'userId': userId,
        'limit': limit,
        'includeReplies': includeReplies,
        'includeMyRenotes': includeRenotes,
        'includeRenotedMyNotes': includeRenotes,
        'includeLocalRenotes': includeRenotes,
        'withChannelNotes': true,
        'withFiles': withFiles,
      },
    );
    return response.map(Note.fromJson).toList(growable: false);
  }

  @override
  Future<List<Note>> fetchUserPinnedNotes(
    AuthSession session,
    String userId,
  ) async {
    final response = await _client.postJsonList(
      baseUrl: session.baseUrl,
      path: '/api/users/featured-notes',
      body: {'i': session.accessToken, 'userId': userId},
    );
    return response.map(Note.fromJson).toList(growable: false);
  }
}
