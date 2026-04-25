import '../models/auth_session.dart';
import '../utils/misskey_http_client.dart';
import 'post_data_source.dart';

class MisskeyPostDataSource implements PostDataSource {
  MisskeyPostDataSource(this.client);

  final MisskeyHttpClient client;

  @override
  Future<void> createPost(AuthSession session, String text) async {
    await client.postJson(
      baseUrl: session.baseUrl,
      path: '/api/notes/create',
      body: {'i': session.accessToken, 'text': text},
    );
  }
}
