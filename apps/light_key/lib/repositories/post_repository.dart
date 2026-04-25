import 'package:core/models/result.dart';

import '../datasources/post_data_source.dart';
import '../models/auth_session.dart';

class PostRepository {
  PostRepository(this._dataSource);

  final PostDataSource _dataSource;

  Future<Result<void>> createPost(AuthSession session, String text) async {
    try {
      await _dataSource.createPost(session, text);
      return const Success(null);
    } on Exception catch (e, st) {
      return Failure(e, st);
    }
  }
}
