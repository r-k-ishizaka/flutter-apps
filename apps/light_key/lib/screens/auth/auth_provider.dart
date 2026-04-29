import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../../models/auth_session.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/emoji_repository.dart';
import 'auth_screen_state.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(
    this._authRepository,
    this._emojiRepository,
  );

  final AuthRepository _authRepository;
  final EmojiRepository _emojiRepository;

  AuthScreenState _state = const AuthScreenState.idle();
  AuthScreenState get state => _state;


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

        try {
          _state = _state.copyWith(
            message: 'OAuth ログインに成功しました。絵文字を同期中...',
            emojiSyncProgress: 0,
          );
          notifyListeners();
          await _emojiRepository.syncEmojis(
            session!,
            onProgress: (progress, message) {
              _state = _state.copyWith(
                emojiSyncProgress: progress,
                message: message,
              );
              notifyListeners();
            },
          );
          developer.log(
            'Emoji sync completed during OAuth login',
            name: 'AuthProvider',
          );
          _state = _state.copyWith(
            message: 'ログイン完了。',
            emojiSyncProgress: 1,
          );
        } catch (e, st) {
          developer.log(
            'Emoji sync failed during OAuth login: $e',
            name: 'AuthProvider',
            error: e,
            stackTrace: st,
          );
          // 同期失敗時もログインは継続し、スプラッシュ側で再同期を試みる。
          _state = _state.copyWith(
            message: 'ログイン完了（絵文字同期は後で再試行します）。',
            clearEmojiSyncProgress: true,
          );
        }

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
