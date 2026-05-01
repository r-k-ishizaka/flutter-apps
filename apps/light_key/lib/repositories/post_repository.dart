import 'package:core/models/result.dart';

import '../datasources/post_data_source.dart';
import '../models/auth_session.dart';
import '../screens/post/post_screen_state.dart';

class PostRepository {
  PostRepository(this._dataSource);

  final PostDataSource _dataSource;

  Future<Result<void>> createPost(
    AuthSession session,
    String text,
    PostVisibility visibility,
    bool isFederated,
  ) async {
    try {
      await _dataSource.createPost(session, text, visibility, isFederated);
      return const Success(null);
    } on Exception catch (e, st) {
      return Failure(e, st);
    }
  }
}
