import '../../models/note.dart';
import '../../models/user.dart';
import '../../services/emoji_cache.dart';

/// ノートに対するユーザーアクションのインターフェース。
///
/// Timeline、Profile、NoteDetail、Notificationsなど、ノートを表示する
/// すべての画面で共通して使用するアクションを定義する。
/// 各画面は固有の要件に応じてこのインターフェースを実装する。
abstract class NoteActions {
  /// ノート全体をタップしたときの処理。
  /// 通常はノート詳細画面へ遷移する。
  Future<void> onNoteTap(Note note);

  /// リプライボタンをタップしたときの処理。
  /// 投稿画面を開いて返信を作成する。
  Future<void> onReply(Note note);

  /// リノートボタンをタップしたときの処理。
  /// アクションシートを表示してリノート/引用を選択する。
  Future<void> onRenote(Note note);

  /// リアクションボタンをタップしたときの処理。
  /// リアクションピッカーを表示してリアクションを選択する。
  Future<void> onReaction(Note note);

  /// リアクションチップをタップしたときの処理。
  /// 既存のリアクションと同じものを送信する。
  Future<void> onReactionChipTap(Note note, String reaction);

  /// ユーザーアバター/名前をタップしたときの処理。
  /// ユーザープロフィール画面へ遷移する。
  Future<void> onUserTap(User user);

  /// ノート本文内の絵文字をタップしたときの処理。
  /// アクションシートを表示してリアクション/コピーを選択する。
  Future<void> onBodyEmojiTap(Note note, String emoji);

  /// 返信元ノートをタップしたときの処理。
  /// 返信元のノート詳細画面へ遷移する。
  Future<void> onReplyNoteTap(Note reply);

  /// メニューボタン（⋯）をタップしたときの処理。
  /// ノートメニューシートを表示する。
  Future<void> onMenu(Note note, Map<String, EmojiCacheEntry> emojis);
}
