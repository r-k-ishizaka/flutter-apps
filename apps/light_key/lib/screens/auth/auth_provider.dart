import 'package:flutter/foundation.dart';

import '../../models/auth_session.dart';
import '../../repositories/auth_repository.dart';
import 'auth_screen_state.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authRepository);

  final AuthRepository _authRepository;

  AuthScreenState _state = const AuthScreenState.idle();
  AuthScreenState get state => _state;

  Future<void> signIn({required String baseUrl, required String accessToken}) async {
    _state = _state.copyWith(status: AuthStatus.loading, clearMessage: true);
    notifyListeners();

    final result = await _authRepository.signIn(baseUrl, accessToken);
    result.when(
      success: (user) {
        _state = _state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          session: AuthSession(baseUrl: baseUrl, accessToken: accessToken),
          message: 'ログインに成功しました。',
        );
      },
      failure: (error, _) {
        _state = _state.copyWith(
          status: AuthStatus.error,
          message: 'ログインに失敗しました: $error',
        );
      },
    );
    notifyListeners();
  }

  Future<void> signInWithOAuth({
    required String baseUrl,
    required String clientId,
    required String code,
    required String redirectUri,
    String? codeVerifier,
  }) async {
    _state = _state.copyWith(status: AuthStatus.loading, clearMessage: true);
    notifyListeners();

    final result = await _authRepository.signInWithOAuth(
      baseUrl,
      clientId,
      code,
      redirectUri,
      codeVerifier: codeVerifier,
    );
    result.when(
      success: (user) {
        _state = _state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          message: 'OAuth ログインに成功しました。',
        );
      },
      failure: (error, _) {
        _state = _state.copyWith(
          status: AuthStatus.error,
          message: 'OAuth ログインに失敗しました: $error',
        );
      },
    );
    notifyListeners();
  }

  Future<void> restoreSession() async {
    final result = await _authRepository.restoreSession();
    result.when(
      success: (session) {
        if (session == null) {
          _state = const AuthScreenState.idle();
        } else {
          _state = _state.copyWith(
            status: AuthStatus.authenticated,
            session: session,
            message: '保存済みセッションを復元しました。',
          );
        }
      },
      failure: (error, _) {
        _state = _state.copyWith(
          status: AuthStatus.error,
          message: 'セッション復元に失敗しました: $error',
        );
      },
    );
    notifyListeners();
  }

  Future<void> signOut() async {
    final result = await _authRepository.signOut();
    result.when(
      success: (_) {
        _state = const AuthScreenState.idle();
      },
      failure: (error, _) {
        _state = _state.copyWith(
          status: AuthStatus.error,
          message: 'ログアウトに失敗しました: $error',
        );
      },
    );
    notifyListeners();
  }
}
