import 'package:core/models/result.dart';

import '../datasources/auth_data_source.dart';
import '../models/auth_session.dart';
import '../models/user.dart';
import 'emoji_repository.dart';

class AuthRepository {
  AuthRepository(this._dataSource, {EmojiRepository? emojiRepository})
      : _emojiRepository = emojiRepository;

  final AuthDataSource _dataSource;
  final EmojiRepository? _emojiRepository;

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
      final response = await _dataSource.verify(baseUrl, accessToken);
      if (_emojiRepository != null && response.emojisToCache.isNotEmpty) {
        await _emojiRepository.cacheEmojiHints(response.emojisToCache);
      }
      final user = response.data;
      final session = AuthSession(
        baseUrl: baseUrl,
        accessToken: accessToken,
        user: user,
      );
      await _dataSource.saveSession(session);

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

  Future<Result<AuthSession?>> restoreSessionWithUserRefresh() async {
    try {
      final restoredSession = await _dataSource.loadSession();
      if (restoredSession == null) {
        return const Success(null);
      }

      try {
        final response = await _dataSource.verify(
          restoredSession.baseUrl,
          restoredSession.accessToken,
        );
        if (_emojiRepository != null && response.emojisToCache.isNotEmpty) {
          await _emojiRepository.cacheEmojiHints(response.emojisToCache);
        }

        final refreshedSession = AuthSession(
          baseUrl: restoredSession.baseUrl,
          accessToken: restoredSession.accessToken,
          user: response.data,
        );
        await _dataSource.saveSession(refreshedSession);
        return Success(refreshedSession);
      } on Exception {
        // ネットワーク不調時は保存済みセッションで継続する。
        return Success(restoredSession);
      }
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
