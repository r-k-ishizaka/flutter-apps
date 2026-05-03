import 'package:core/models/result.dart';

import '../datasources/user_profile_data_source.dart';
import '../models/auth_session.dart';
import '../models/note.dart';
import '../models/user_profile.dart';
import '../utils/note_emoji_filter.dart';
import 'emoji_repository.dart';

class UserProfileRepository {
  UserProfileRepository(this._dataSource, {EmojiRepository? emojiRepository})
      : _emojiRepository = emojiRepository;

  final UserProfileDataSource _dataSource;
  final EmojiRepository? _emojiRepository;

  Future<Result<UserProfile>> fetchUserProfile(
    AuthSession session,
    String userId,
  ) async {
    try {
      final response = await _dataSource.fetchUserProfile(session, userId);
      if (_emojiRepository != null && response.emojisToCache.isNotEmpty) {
        final filtered = NoteEmojiFilter.filterForProfile(
          response.data,
          response.emojisToCache,
        );
        if (filtered.isNotEmpty) {
          await _emojiRepository.cacheEmojiHints(filtered);
        }
      }
      return Success(response.data);
    } on Exception catch (error, stackTrace) {
      return Failure(error, stackTrace);
    }
  }

  Future<Result<List<Note>>> fetchUserNotes(
    AuthSession session,
    String userId, {
    int limit = 50,
    bool withReplies = true,
    bool withRenotes = true,
    bool withFiles = false,
    bool withChannelNotes = true,
    bool allowPartial = false,
  }) async {
    try {
      final response = await _dataSource.fetchUserNotes(
        session,
        userId,
        limit: limit,
        withReplies: withReplies,
        withRenotes: withRenotes,
        withFiles: withFiles,
        withChannelNotes: withChannelNotes,
        allowPartial: allowPartial,
      );
      if (_emojiRepository != null && response.emojisToCache.isNotEmpty) {
        final filtered = NoteEmojiFilter.filterForNotes(
          response.data,
          response.emojisToCache,
        );
        if (filtered.isNotEmpty) {
          await _emojiRepository.cacheEmojiHints(filtered);
        }
      }
      return Success(response.data);
    } on Exception catch (error, stackTrace) {
      return Failure(error, stackTrace);
    }
  }
}
