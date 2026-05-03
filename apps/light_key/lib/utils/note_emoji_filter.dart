import '../models/note.dart';
import '../models/response_with_cache_hints.dart';
import '../models/user_profile.dart';

/// ノートの表示で実際に使われる絵文字だけに [EmojiToCache] リストを絞り込むユーティリティ。
///
/// - [maxVisibleReactions] は [NoteReactionList] の表示上限と共有する。
/// - フィルタロジكはソート順も含め [NoteReactionList] と完全に同期させる。
abstract final class NoteEmojiFilter {
  /// 1ノートで表示するリアクションの上限（NoteReactionList と共有）。
  static const int maxVisibleReactions = 16;

  static final _shortcodePattern = RegExp(
    r':([a-zA-Z0-9_]+(?:@[a-zA-Z0-9._-]+)?):',
  );

  static final _reactionKeyPattern = RegExp(
    r'^:([a-zA-Z0-9_]+(?:@[a-zA-Z0-9._-]+)?):$',
  );

  /// ノートリストで実際に表示される絵文字だけに絞り込む。
  static List<EmojiToCache> filterForNotes(
    List<Note> notes,
    List<EmojiToCache> candidates,
  ) {
    if (candidates.isEmpty || notes.isEmpty) return candidates;
    final needed = <String>{};
    for (final note in notes) {
      _collectFromNote(note, needed);
    }
    return _filter(candidates, needed);
  }

  /// ユーザープロフィール（名前・説明・ピン留めノート）で
  /// 実際に表示される絵文字だけに絞り込む。
  static List<EmojiToCache> filterForProfile(
    UserProfile profile,
    List<EmojiToCache> candidates,
  ) {
    if (candidates.isEmpty) return candidates;
    final needed = <String>{};
    _extractFromText(profile.name, needed);
    _extractFromText(profile.description, needed);
    for (final note in profile.pinnedNotes) {
      _collectFromNote(note, needed);
    }
    return _filter(candidates, needed);
  }

  // -----------------------------------------------------------------------
  // private helpers
  // -----------------------------------------------------------------------

  static List<EmojiToCache> _filter(
    List<EmojiToCache> candidates,
    Set<String> needed,
  ) {
    if (needed.isEmpty) return const [];
    return candidates
        .where((e) => needed.contains(e.name))
        .toList(growable: false);
  }

  static void _collectFromNote(Note note, Set<String> names) {
    _extractFromText(note.text, names);
    _extractFromText(note.cw, names);
    _extractFromText(note.user.name, names);
    _addTopReactions(note.reactions, names);
    final renote = note.renote;
    if (renote != null) {
      _collectFromNote(renote, names);
    }
  }

  /// テキスト中の `:shortcode:` / `:shortcode@host:` を抽出する。
  ///
  /// `:name@.:` は `emojisToCache` では `name` で保存されるため正規化する。
  static void _extractFromText(String? text, Set<String> names) {
    if (text == null || text.isEmpty) return;
    for (final match in _shortcodePattern.allMatches(text)) {
      final inner = match.group(1)!;
      names.add(_normalizeEmojiName(inner));
    }
  }

  /// NoteReactionList と同じソート順（カウント降順 → キー昇順）で上位16件を抽出し、
  /// 対応する絵文字名を [names] に追加する。
  static void _addTopReactions(Map<String, int> reactions, Set<String> names) {
    if (reactions.isEmpty) return;
    final sorted =
        reactions.entries
            .where((e) => e.value > 0)
            .toList(growable: false)
          ..sort((a, b) {
            final c = b.value.compareTo(a.value);
            return c != 0 ? c : a.key.compareTo(b.key);
          });

    for (final entry in sorted.take(maxVisibleReactions)) {
      final match = _reactionKeyPattern.firstMatch(entry.key);
      if (match == null) continue; // Unicode 絵文字などはスキップ
      final inner = match.group(1)!;
      names.add(_normalizeEmojiName(inner));
    }
  }

  /// `:name@.:` → `name`（emojisToCache のキー形式に合わせる）。
  static String _normalizeEmojiName(String inner) {
    if (inner.endsWith('@.')) {
      return inner.substring(0, inner.length - 2);
    }
    return inner;
  }
}
