import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../../models/auth_session.dart';
import '../../models/user.dart';
import '../../repositories/auth_repository.dart';
import 'auth_screen_state.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authRepository);

  final AuthRepository _authRepository;

  AuthScreenState _state = const AuthScreenState.idle();

  AuthScreenState get state => _state;

  /// ログイン中のユーザー情報（セッションから取得）
  User? get currentUser => _state.session?.user;

  Future<void> signInWithOAuth({
    required String baseUrl,
    required String clientId,
    required String code,
    required String redirectUri,
    String? codeVerifier,
  }) async {
    _state = _state.copyWith(
      status: AuthStatus.loading,
      clearMessage: true,
      clearEmojiSyncProgress: true,
    );
    notifyListeners();

    final result = await _authRepository.signInWithOAuth(
      baseUrl,
      clientId,
      code,
      redirectUri,
      codeVerifier: codeVerifier,
    );
    await result.when<Future<void>>(
      success: (user) async {
        _state = _state.copyWith(
          status: AuthStatus.loading,
          user: user,
          message: 'OAuth ログインに成功しました。セッションを確認しています...',
          clearEmojiSyncProgress: true,
        );
        notifyListeners();

        AuthSession? session;
        final restored = await _authRepository.restoreSession();
        restored.when(
          success: (value) => session = value,
          failure: (error, st) {
            developer.log(
              'Failed to restore session right after OAuth login: $error',
              name: 'AuthProvider',
              error: error,
              stackTrace: st,
            );
          },
        );

        if (session == null) {
          _state = _state.copyWith(
            status: AuthStatus.error,
            message: 'ログイン後のセッション復元に失敗しました。',
          );
          return;
        }

        _state = _state.copyWith(
          message: 'ログイン完了。',
          clearEmojiSyncProgress: true,
        );

        _state = _state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          session: session,
          clearEmojiSyncProgress: true,
        );
      },
      failure: (error, _) async {
        _state = _state.copyWith(
          status: AuthStatus.error,
          message: 'OAuth ログインに失敗しました: $error',
          clearEmojiSyncProgress: true,
        );
      },
    );
    notifyListeners();
  }

  Future<void> restoreSession({bool refreshUser = false}) async {
    final result = refreshUser
        ? await _authRepository.restoreSessionWithUserRefresh()
        : await _authRepository.restoreSession();
    result.when(
      success: (session) {
        if (session == null) {
          _state = const AuthScreenState.idle();
        } else {
          _state = _state.copyWith(
            status: AuthStatus.authenticated,
            user: session.user,
            session: session,
            message: refreshUser
                ? 'セッションを復元し、ユーザー情報を更新しました。'
                : '保存済みセッションを復元しました。',
            clearEmojiSyncProgress: true,
          );
        }
      },
      failure: (error, _) {
        _state = _state.copyWith(
          status: AuthStatus.error,
          message: 'セッション復元に失敗しました: $error',
          clearEmojiSyncProgress: true,
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
          clearEmojiSyncProgress: true,
        );
      },
    );
    notifyListeners();
  }
}
