import '../models/auth_session.dart';
import '../models/note.dart';
import '../models/response_with_cache_hints.dart';
import '../models/user_profile.dart';
import '../utils/misskey_http_client.dart';
import 'user_profile_data_source.dart';

class MisskeyUserProfileDataSource implements UserProfileDataSource {
  MisskeyUserProfileDataSource(this._client);

  final MisskeyHttpClient _client;

  @override
  Future<ResponseWithCacheHints<UserProfile>> fetchUserProfile(
    AuthSession session,
    String userId,
  ) async {
    final response = await _client.postJsonWithCacheHints(
      baseUrl: session.baseUrl,
      path: '/api/users/show',
      body: {'i': session.accessToken, 'userId': userId},
    );
    return ResponseWithCacheHints(
      data: UserProfile.fromJson(response.data),
      emojisToCache: response.emojisToCache,
    );
  }

  @override
  Future<ResponseWithCacheHints<List<Note>>> fetchUserNotes(
    AuthSession session,
    String userId, {
    int limit = 50,
    bool withReplies = true,
    bool withRenotes = true,
    bool withFiles = false,
    bool withChannelNotes = true,
    bool allowPartial = false,
    String? untilId,
  }) async {
    final body = <String, dynamic>{
      'i': session.accessToken,
      'userId': userId,
      'limit': limit,
      'withRenotes': withRenotes,
      'withReplies': withReplies,
      'withFiles': withFiles,
      'withChannelNotes': withChannelNotes,
      'allowPartial': allowPartial,
    };
    if (untilId != null) {
      body['untilId'] = untilId;
    }
    final response = await _client.postJsonListWithCacheHints(
      baseUrl: session.baseUrl,
      path: '/api/users/notes',
      body: body,
    );
    return ResponseWithCacheHints(
      data: response.data.map(Note.fromJson).toList(growable: false),
      emojisToCache: response.emojisToCache,
    );
  }
}
