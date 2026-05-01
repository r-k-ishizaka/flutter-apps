import '../models/auth_session.dart';
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
}
