import '../models/auth_session.dart';
import '../models/response_with_cache_hints.dart';
import '../screens/post/post_screen_state.dart';

abstract interface class PostDataSource {
  Future<ResponseWithCacheHints<Map<String, dynamic>>> createPost(
    AuthSession session,
    String text,
    String? cw,
    PostVisibility visibility,
    bool isFederated, {
    String? replyId,
  });
}
