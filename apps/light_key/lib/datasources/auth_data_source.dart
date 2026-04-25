import '../models/auth_session.dart';
import '../models/user.dart';

abstract interface class AuthDataSource {
  Future<User> verify(String baseUrl, String accessToken);
  Future<void> saveSession(AuthSession session);
  Future<AuthSession?> loadSession();
  Future<void> clearSession();
}
