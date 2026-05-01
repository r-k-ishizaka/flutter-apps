import '../models/auth_session.dart';
import '../screens/post/post_screen_state.dart';

abstract interface class PostDataSource {
  Future<void> createPost(
    AuthSession session,
    String text,
    PostVisibility visibility,
    bool isFederated,
  );
}
