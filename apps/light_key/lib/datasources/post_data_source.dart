import '../models/auth_session.dart';

abstract interface class PostDataSource {
  Future<void> createPost(AuthSession session, String text);
}
