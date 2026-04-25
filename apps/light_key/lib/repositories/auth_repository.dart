import 'package:core/models/result.dart';

import '../datasources/auth_data_source.dart';
import '../models/auth_session.dart';
import '../models/user.dart';

class AuthRepository {
  AuthRepository(this._dataSource);

  final AuthDataSource _dataSource;

  Future<Result<User>> signIn(String baseUrl, String accessToken) async {
    try {
      final user = await _dataSource.verify(baseUrl, accessToken);
      await _dataSource.saveSession(
        AuthSession(baseUrl: baseUrl, accessToken: accessToken),
      );
      return Success(user);
    } on Exception catch (e, st) {
      return Failure(e, st);
    }
  }

  Future<Result<User>> signInWithOAuth(
    String baseUrl,
    String clientId,
    String code,
    String redirectUri, {
    String? codeVerifier,
  }) async {
    try {
      final accessToken = await _dataSource.getOAuthToken(
        baseUrl,
        clientId,
        code,
        redirectUri,
        codeVerifier: codeVerifier,
      );
      final user = await _dataSource.verify(baseUrl, accessToken);
      await _dataSource.saveSession(
        AuthSession(baseUrl: baseUrl, accessToken: accessToken),
      );
      return Success(user);
    } on Exception catch (e, st) {
      return Failure(e, st);
    }
  }

  Future<Result<AuthSession?>> restoreSession() async {
    try {
      final session = await _dataSource.loadSession();
      return Success(session);
    } on Exception catch (e, st) {
      return Failure(e, st);
    }
  }

  Future<Result<void>> signOut() async {
    try {
      await _dataSource.clearSession();
      return const Success(null);
    } on Exception catch (e, st) {
      return Failure(e, st);
    }
  }
}
