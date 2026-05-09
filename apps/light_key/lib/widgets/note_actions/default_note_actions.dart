import '../../models/note.dart';
import '../../models/user.dart';
import '../../services/emoji_cache.dart';
import 'note_actions.dart';

/// [NoteActions] のデフォルト実装。
///
/// すべてのアクションで何も実行しない空実装を提供する。
/// テスト時のモック、または一部のアクションのみ実装したい場合に利用できる。
class DefaultNoteActions implements NoteActions {
  const DefaultNoteActions();

  @override
  Future<void> onNoteTap(Note note) async {}

  @override
  Future<void> onReply(Note note) async {}

  @override
  Future<void> onRenote(Note note) async {}

  @override
  Future<void> onReaction(Note note) async {}

  @override
  Future<void> onReactionChipTap(Note note, String reaction) async {}

  @override
  Future<void> onUserTap(User user) async {}

  @override
  Future<void> onBodyEmojiTap(Note note, String emoji) async {}

  @override
  Future<void> onReplyNoteTap(Note reply) async {}

  @override
  Future<void> onMenu(Note note, Map<String, EmojiCacheEntry> emojis) async {}
}
