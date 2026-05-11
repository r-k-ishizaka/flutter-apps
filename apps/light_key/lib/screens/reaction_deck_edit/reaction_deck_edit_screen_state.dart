class ReactionDeckCandidateEmoji {
  const ReactionDeckCandidateEmoji({
    required this.name,
    required this.url,
    required this.category,
  });

  final String name;
  final String url;

  /// トップレベルのカテゴリ名（例: "000 Misskey.io Original"）。
  final String category;
}

class ReactionDeckEditScreenState {
  const ReactionDeckEditScreenState({
    required this.isLoading,
    required this.selectedDeckId,
    required this.deckName,
    required this.deckEmojis,
    required this.candidates,
    required this.query,
    required this.message,
  });

  const ReactionDeckEditScreenState.initial({required int initialDeckId})
    : this(
        isLoading: true,
        selectedDeckId: initialDeckId,
        deckName: '',
        deckEmojis: const [],
        candidates: const [],
        query: '',
        message: null,
      );

  final bool isLoading;
  final int selectedDeckId;
  final String deckName;
  final List<String> deckEmojis;
  final List<ReactionDeckCandidateEmoji> candidates;
  final String query;
  final String? message;

  List<ReactionDeckCandidateEmoji> get filteredCandidates {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return candidates;
    }
    return candidates
        .where((item) => item.name.toLowerCase().contains(q))
        .toList(growable: false);
  }

  /// カテゴリ名の昇順一覧（重複なし）。
  List<String> get sortedCategoryNames {
    final seen = <String>{};
    for (final c in candidates) {
      seen.add(c.category);
    }
    return seen.toList()..sort();
  }

  /// カテゴリ名をキーとした候補グループ。
  Map<String, List<ReactionDeckCandidateEmoji>> get candidatesByCategory {
    final map = <String, List<ReactionDeckCandidateEmoji>>{};
    for (final c in candidates) {
      map.putIfAbsent(c.category, () => []).add(c);
    }
    return map;
  }

  ReactionDeckEditScreenState copyWith({
    bool? isLoading,
    int? selectedDeckId,
    String? deckName,
    List<String>? deckEmojis,
    List<ReactionDeckCandidateEmoji>? candidates,
    String? query,
    String? message,
    bool clearMessage = false,
  }) {
    return ReactionDeckEditScreenState(
      isLoading: isLoading ?? this.isLoading,
      selectedDeckId: selectedDeckId ?? this.selectedDeckId,
      deckName: deckName ?? this.deckName,
      deckEmojis: deckEmojis ?? this.deckEmojis,
      candidates: candidates ?? this.candidates,
      query: query ?? this.query,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}
