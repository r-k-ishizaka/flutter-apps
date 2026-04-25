import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_session.dart';
import '../models/user.dart';
import '../utils/misskey_http_client.dart';
import 'auth_data_source.dart';

class MisskeyAuthDataSource implements AuthDataSource {
  MisskeyAuthDataSource({required this.client, required this.prefs});

  static const _baseUrlKey = 'base_url';
  static const _accessTokenKey = 'access_token';

  final MisskeyHttpClient client;
  final SharedPreferences prefs;

  @override
  Future<User> verify(String baseUrl, String accessToken) async {
    final response = await client.postJson(
      baseUrl: baseUrl,
      path: '/api/i',
      body: {'i': accessToken},
    );
    return User.fromJson(response);
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    await prefs.setString(_baseUrlKey, session.baseUrl);
    await prefs.setString(_accessTokenKey, session.accessToken);
  }

  @override
  Future<AuthSession?> loadSession() async {
    final baseUrl = prefs.getString(_baseUrlKey);
    final accessToken = prefs.getString(_accessTokenKey);
    if (baseUrl == null || accessToken == null) {
      return null;
    }
    return AuthSession(baseUrl: baseUrl, accessToken: accessToken);
  }

  @override
  Future<void> clearSession() async {
    await prefs.remove(_baseUrlKey);
    await prefs.remove(_accessTokenKey);
  }

  @override
  Future<String> getOAuthToken(
    String baseUrl,
    String clientId,
    String code,
    String redirectUri, {
    String? codeVerifier,
  }) async {
    final body = <String, dynamic>{
      'grant_type': 'authorization_code',
      'client_id': clientId,
      'code': code,
      'redirect_uri': redirectUri,
    };

    if (codeVerifier != null) {
      body['code_verifier'] = codeVerifier;
    }

    final response = await client.postJson(
      baseUrl: baseUrl,
      path: '/oauth/token',
      body: body,
    );

    final accessToken = response['access_token'] as String;
    return accessToken;
  }
}
