import 'package:core/models/result.dart';

import '../datasources/post_data_source.dart';
import '../models/auth_session.dart';
import '../screens/post/post_screen_state.dart';
import 'emoji_repository.dart';

class PostRepository {
  PostRepository(this._dataSource, {EmojiRepository? emojiRepository})
      : _emojiRepository = emojiRepository;

  final PostDataSource _dataSource;
  final EmojiRepository? _emojiRepository;

  Future<Result<void>> createPost(
    AuthSession session,
    String text,
    PostVisibility visibility,
    bool isFederated,
  ) async {
    try {
      final response = await _dataSource.createPost(
        session,
        text,
        visibility,
        isFederated,
      );
      if (_emojiRepository != null && response.emojisToCache.isNotEmpty) {
        await _emojiRepository.cacheEmojiHints(response.emojisToCache);
      }
      return const Success(null);
    } on Exception catch (e, st) {
      return Failure(e, st);
    }
  }
}
