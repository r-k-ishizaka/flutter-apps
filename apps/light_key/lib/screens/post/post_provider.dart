import 'package:flutter/foundation.dart';

import '../../models/user.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/post_repository.dart';
import 'post_effect_state.dart';
import 'post_screen_state.dart';

class PostProvider extends ChangeNotifier {
  PostProvider({
    required AuthRepository authRepository,
    required PostRepository postRepository,
  }) : _authRepository = authRepository,
       _postRepository = postRepository;

  final AuthRepository _authRepository;
  final PostRepository _postRepository;

  PostScreenState _screenState = const PostScreenState.idle();
  PostEffectState _effectState = const PostEffectState.none();
  PostVisibility _visibility = PostVisibility.public;
  bool _isFederated = true;

  PostScreenState get state => _screenState;
  PostEffectState get effectState => _effectState;
  PostVisibility get visibility => _visibility;
  bool get isFederated => _isFederated;

  /// ログイン中のユーザー情報を取得
  Future<User?> getCurrentUser() async {
    final result = await _authRepository.restoreSession();
    return result.when(
      success: (session) => session?.user,
      failure: (_, __) => null,
    );
  }

  void setVisibility(PostVisibility visibility) {
    if (_visibility == visibility) return;
    _visibility = visibility;
    notifyListeners();
  }

  void setFederated(bool isFederated) {
    if (_isFederated == isFederated) return;
    _isFederated = isFederated;
    notifyListeners();
  }

  void reset() {
    if (_screenState == const PostScreenState.idle() &&
        _effectState == const PostEffectState.none() &&
        _visibility == PostVisibility.public &&
        _isFederated) {
      return;
    }
    _screenState = const PostScreenState.idle();
    _effectState = const PostEffectState.none();
    _visibility = PostVisibility.public;
    _isFederated = true;
    notifyListeners();
  }

  void consumeEffect() {
    if (_effectState == const PostEffectState.none()) return;
    _effectState = const PostEffectState.none();
    notifyListeners();
  }

  Future<void> submit({
    required String text,
    String? cw,
    String? replyId,
    String? renoteId,
  }) async {
    final normalizedText = text.trim();
    final normalizedCw = cw?.trim();

    if (normalizedText.isEmpty) {
      const message = '投稿内容を入力してください。';
      _screenState = const PostScreenState.error(message: message);
      _effectState = const PostEffectState.showError(message);
      notifyListeners();
      return;
    }

    _screenState = const PostScreenState.submitting();
    _effectState = const PostEffectState.none();
    notifyListeners();

    final sessionResult = await _authRepository.restoreSession();
    await sessionResult.when(
      success: (session) async {
        if (session == null) {
          const message = '先に認証してください。';
          _screenState = const PostScreenState.error(message: message);
          _effectState = const PostEffectState.showError(message);
          return;
        }

        final postResult = await _postRepository.createPost(
          session,
          normalizedText,
          normalizedCw == null || normalizedCw.isEmpty ? null : normalizedCw,
          _visibility,
          _isFederated,
          replyId: replyId,
          renoteId: renoteId,
        );
        postResult.when(
          success: (_) {
            _screenState = const PostScreenState.idle();
            _effectState = const PostEffectState.closeWithMessage(
              postSuccessMessage,
            );
          },
          failure: (error, _) {
            final message = '投稿に失敗しました: $error';
            _screenState = PostScreenState.error(message: message);
            _effectState = PostEffectState.showError(message);
          },
        );
      },
      failure: (error, _) {
        final message = 'セッション取得に失敗しました: $error';
        _screenState = PostScreenState.error(message: message);
        _effectState = PostEffectState.showError(message);
      },
    );

    notifyListeners();
  }
}
