import '../models/auth_session.dart';
import '../screens/post/post_screen_state.dart';
import '../utils/misskey_http_client.dart';
import 'post_data_source.dart';

class MisskeyPostDataSource implements PostDataSource {
  MisskeyPostDataSource(this.client);

  final MisskeyHttpClient client;

  String _toMisskeyVisibility(PostVisibility visibility) {
    return switch (visibility) {
      PostVisibility.public => 'public',
      PostVisibility.home => 'home',
      PostVisibility.follower => 'followers',
    };
  }

  @override
  Future<void> createPost(
    AuthSession session,
    String text,
    PostVisibility visibility,
  ) async {
    await client.postJson(
      baseUrl: session.baseUrl,
      path: '/api/notes/create',
      body: {
        'i': session.accessToken,
        'text': text,
        'visibility': _toMisskeyVisibility(visibility),
      },
    );
  }
}
