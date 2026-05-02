import '../models/auth_session.dart';
import '../models/response_with_cache_hints.dart';
import '../models/user.dart';

abstract interface class AuthDataSource {
  Future<ResponseWithCacheHints<User>> verify(
    String baseUrl,
    String accessToken,
  );

  Future<void> saveSession(AuthSession session);

  Future<AuthSession?> loadSession();

  Future<void> clearSession();

  // OAuth methods
  Future<String> getOAuthToken(
    String baseUrl,
    String clientId,
    String code,
    String redirectUri, {
    String? codeVerifier,
  });
}
