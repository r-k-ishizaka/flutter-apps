import 'package:core/models/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:light_key/models/auth_session.dart';
import 'package:light_key/models/user.dart';
import 'package:light_key/repositories/auth_repository.dart';
import 'package:light_key/screens/auth/auth_provider.dart';
import 'package:light_key/screens/auth/auth_screen_state.dart';

void main() {
  const session = AuthSession(
    baseUrl: 'https://misskey.example',
    accessToken: 'token-123',
  );
  const user = User(id: 'user-1', username: 'alice', name: 'Alice');

  group('AuthProvider', () {
    test('OAuthログイン時に認証完了へ遷移する', () async {
      final authRepository = _FakeAuthRepository(
        signInResult: const Success(user),
        restoreSessionResult: const Success(session),
      );
      final provider = AuthProvider(authRepository);

      await provider.signInWithOAuth(
        baseUrl: session.baseUrl,
        clientId: 'client-id',
        code: 'code',
        redirectUri: 'light-key://oauth',
      );

      expect(provider.state.status, AuthStatus.authenticated);
      expect(provider.state.message, 'ログイン完了。');
    });

    test('OAuthログインでセッション復元失敗時はエラー状態になる', () async {
      final authRepository = _FakeAuthRepository(
        signInResult: const Success(user),
        restoreSessionResult: const Success(null),
      );
      final provider = AuthProvider(authRepository);

      await provider.signInWithOAuth(
        baseUrl: session.baseUrl,
        clientId: 'client-id',
        code: 'code',
        redirectUri: 'light-key://oauth',
      );

      expect(provider.state.status, AuthStatus.error);
      expect(provider.state.message, 'ログイン後のセッション復元に失敗しました。');
    });
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    required this.signInResult,
    required this.restoreSessionResult,
  });

  final Result<User> signInResult;
  final Result<AuthSession?> restoreSessionResult;

  @override
  Future<Result<User>> signInWithOAuth(
    String baseUrl,
    String clientId,
    String code,
    String redirectUri, {
    String? codeVerifier,
  }) async {
    return signInResult;
  }

  @override
  Future<Result<AuthSession?>> restoreSession() async {
    return restoreSessionResult;
  }

  @override
  Future<Result<void>> signOut() async {
    return const Success(null);
  }
}
