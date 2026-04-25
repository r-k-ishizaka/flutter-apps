import 'package:flutter/foundation.dart';

import '../../repositories/auth_repository.dart';
import '../../repositories/post_repository.dart';
import 'post_screen_state.dart';

class PostProvider extends ChangeNotifier {
  PostProvider({
    required AuthRepository authRepository,
    required PostRepository postRepository,
  }) : _authRepository = authRepository,
       _postRepository = postRepository;

  final AuthRepository _authRepository;
  final PostRepository _postRepository;

  PostScreenState _state = const PostScreenState.idle();
  PostScreenState get state => _state;

  Future<void> submit(String text) async {
    if (text.trim().isEmpty) {
      _state = _state.copyWith(
        status: PostStatus.error,
        message: '投稿内容を入力してください。',
      );
      notifyListeners();
      return;
    }

    _state = _state.copyWith(status: PostStatus.submitting, clearMessage: true);
    notifyListeners();

    final sessionResult = await _authRepository.restoreSession();
    await sessionResult.when(
      success: (session) async {
        if (session == null) {
          _state = _state.copyWith(
            status: PostStatus.error,
            message: '先に認証してください。',
          );
          return;
        }

        final postResult = await _postRepository.createPost(session, text.trim());
        postResult.when(
          success: (_) {
            _state = _state.copyWith(
              status: PostStatus.success,
              message: '投稿に成功しました。',
            );
          },
          failure: (error, _) {
            _state = _state.copyWith(
              status: PostStatus.error,
              message: '投稿に失敗しました: $error',
            );
          },
        );
      },
      failure: (error, _) {
        _state = _state.copyWith(
          status: PostStatus.error,
          message: 'セッション取得に失敗しました: $error',
        );
      },
    );

    notifyListeners();
  }
}
