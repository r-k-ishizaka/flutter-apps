import 'package:flutter/foundation.dart';

import '../../services/app_database.dart';
import 'reaction_deck_edit_screen_state.dart';

class ReactionDeckEditProvider extends ChangeNotifier {
  ReactionDeckEditProvider({
    required AppDatabase database,
    required int initialDeckId,
  }) : _database = database,
       _state = ReactionDeckEditScreenState.initial(
         initialDeckId: initialDeckId.clamp(1, 4),
       );

  final AppDatabase _database;
  static final RegExp _customEmojiPattern = RegExp(r'^:([^:]+):$');

  /// カテゴリ文字列からトップレベルカテゴリ名を返す。
  static String _normalizeTopCategory(String? rawCategory) {
    if (rawCategory == null || rawCategory.trim().isEmpty) return 'その他';
    final parts = rawCategory
        .split('/')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
    return parts.isEmpty ? 'その他' : parts.first;
  }

  ReactionDeckEditScreenState _state;
  final Map<int, String> _deckNames = {};
  final Map<int, List<String>> _deckEmojis = {};
  final Map<String, String> _customEmojiUrlByName = {};

  ReactionDeckEditScreenState get state => _state;

  Future<void> load() async {
    try {
      final decks = await _database.getReactionDecks();
      final deckItems = await _database.getReactionDeckItems();
      final pickerRows = await _database.getEmojisForPicker();

      _deckNames
        ..clear()
        ..addEntries(decks.map((row) => MapEntry(row.deckId, row.name)));

      _deckEmojis.clear();
      for (final item in deckItems) {
        if (item.deckId < 1 || item.deckId > 4) {
          continue;
        }
        _deckEmojis.putIfAbsent(item.deckId, () => []).add(item.emoji);
      }

      for (var deckId = 1; deckId <= 4; deckId++) {
        _deckNames.putIfAbsent(deckId, () => '');
        _deckEmojis.putIfAbsent(deckId, () => []);
      }

      final candidateMap = <String, ReactionDeckCandidateEmoji>{};
      _customEmojiUrlByName.clear();
      for (final row in pickerRows) {
        if (row.name.isEmpty || row.url.isEmpty) {
          continue;
        }
        _customEmojiUrlByName[row.name] = row.url;
        candidateMap[row.name] = ReactionDeckCandidateEmoji(
          name: row.name,
          url: row.url,
          category: _normalizeTopCategory(row.category),
        );
      }

      final candidates = candidateMap.values.toList(growable: false)
        ..sort((a, b) => a.name.compareTo(b.name));

      final selectedDeckId = _state.selectedDeckId.clamp(1, 4);
      _state = _state.copyWith(
        isLoading: false,
        selectedDeckId: selectedDeckId,
        deckName: _deckNames[selectedDeckId] ?? '',
        deckEmojis: List<String>.unmodifiable(
          (_deckEmojis[selectedDeckId] ?? const []).take(32),
        ),
        candidates: List<ReactionDeckCandidateEmoji>.unmodifiable(candidates),
        clearMessage: true,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(isLoading: false, message: '読み込みに失敗しました: $e');
      notifyListeners();
    }
  }

  void updateQuery(String query) {
    if (_state.query == query) {
      return;
    }
    _state = _state.copyWith(query: query);
    notifyListeners();
  }

  void selectDeck(int deckId) {
    final safeDeckId = deckId.clamp(1, 4);
    if (_state.selectedDeckId == safeDeckId) {
      return;
    }

    _state = _state.copyWith(
      selectedDeckId: safeDeckId,
      deckName: _deckNames[safeDeckId] ?? '',
      deckEmojis: List<String>.unmodifiable(
        (_deckEmojis[safeDeckId] ?? const []).take(32),
      ),
      clearMessage: true,
    );
    notifyListeners();
  }

  Future<void> renameSelectedDeck(String nextName) async {
    final safeName = nextName.trim();
    final deckId = _state.selectedDeckId;
    if ((_deckNames[deckId] ?? '') == safeName) {
      return;
    }

    try {
      await _database.renameReactionDeck(deckId: deckId, name: safeName);
      _deckNames[deckId] = safeName;
      _state = _state.copyWith(
        deckName: safeName,
        message: 'デッキ名を保存しました。',
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(message: 'デッキ名の保存に失敗しました: $e');
      notifyListeners();
    }
  }

  Future<void> addEmojiToSelectedDeck(String emoji) async {
    final deckId = _state.selectedDeckId;
    if (_state.deckEmojis.length >= 32) {
      _state = _state.copyWith(message: '1デッキの上限は32件です。');
      notifyListeners();
      return;
    }

    try {
      final added = await _database.addReactionDeckItem(deckId: deckId, emoji: emoji);
      if (!added) {
        _state = _state.copyWith(message: '1デッキの上限は32件です。');
        notifyListeners();
        return;
      }

      final next = List<String>.unmodifiable([..._state.deckEmojis, emoji]);
      _deckEmojis[deckId] = next;
      _state = _state.copyWith(deckEmojis: next, clearMessage: true);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(message: '絵文字の追加に失敗しました: $e');
      notifyListeners();
    }
  }

  Future<void> removeEmojiAt(int index) async {
    final deckId = _state.selectedDeckId;
    if (index < 0 || index >= _state.deckEmojis.length) {
      return;
    }

    try {
      final removed = await _database.removeReactionDeckItem(
        deckId: deckId,
        position: index,
      );
      if (!removed) {
        return;
      }
      final next = [..._state.deckEmojis]..removeAt(index);
      final immutable = List<String>.unmodifiable(next);
      _deckEmojis[deckId] = immutable;
      _state = _state.copyWith(deckEmojis: immutable, clearMessage: true);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(message: '絵文字の削除に失敗しました: $e');
      notifyListeners();
    }
  }

  Future<void> reorderEmoji(int oldIndex, int newIndex) async {
    final deckId = _state.selectedDeckId;
    if (oldIndex < 0 || oldIndex >= _state.deckEmojis.length) {
      return;
    }

    var destination = newIndex;
    if (destination > oldIndex) {
      destination -= 1;
    }
    if (destination < 0 || destination >= _state.deckEmojis.length) {
      return;
    }
    if (destination == oldIndex) {
      return;
    }

    try {
      final moved = await _database.moveReactionDeckItem(
        deckId: deckId,
        fromPosition: oldIndex,
        toPosition: destination,
      );
      if (!moved) {
        return;
      }
      final next = [..._state.deckEmojis];
      final item = next.removeAt(oldIndex);
      next.insert(destination, item);
      final immutable = List<String>.unmodifiable(next);
      _deckEmojis[deckId] = immutable;
      _state = _state.copyWith(deckEmojis: immutable, clearMessage: true);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(message: '並び替えの保存に失敗しました: $e');
      notifyListeners();
    }
  }

  String? getCustomEmojiUrl(String emoji) {
    final match = _customEmojiPattern.firstMatch(emoji);
    if (match == null) {
      return null;
    }
    final name = match.group(1);
    if (name == null || name.isEmpty) {
      return null;
    }
    return _customEmojiUrlByName[name];
  }

  String? getCustomEmojiName(String emoji) {
    final match = _customEmojiPattern.firstMatch(emoji);
    return match?.group(1);
  }

  void clearMessage() {
    if (_state.message == null) {
      return;
    }
    _state = _state.copyWith(clearMessage: true);
    notifyListeners();
  }
}
