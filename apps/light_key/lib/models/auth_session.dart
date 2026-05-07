import 'user.dart';

class AuthSession {
  const AuthSession({
    required this.baseUrl,
    required this.accessToken,
    this.user,
  });

  final String baseUrl;
  final String accessToken;
  final User? user;
}
