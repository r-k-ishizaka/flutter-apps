import 'dart:async';

import 'package:core/models/result.dart';
import 'package:flutter/foundation.dart';

import '../../models/note.dart';
import '../../models/note_type.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/timeline_repository.dart';
import 'timeline_screen_state.dart';

class TimelineProvider extends ChangeNotifier {
  TimelineProvider({
    required AuthRepository authRepository,
    required TimelineRepository timelineRepository,
  }) : _authRepository = authRepository,
       _timelineRepository = timelineRepository;

  final AuthRepository _authRepository;
  final TimelineRepository _timelineRepository;

  StreamSubscription<Result<List<Note>>>? _timelineSubscription;
  Future<void> _realtimeOperation = Future<void>.value();
  int _realtimeGeneration = 0;
  bool _wantsRealtime = false;
  bool _isDisposed = false;

  TimelineScreenState _state = const TimelineScreenState.idle();

  TimelineScreenState get state => _state;

  List<Note> get _loadedNotes => switch (_state) {
    TimelineScreenStateLoaded(:final notes) => notes,
    _ => const <Note>[],
  };

  Future<void> fetch({bool showLoading = true}) async {
    final previousNotes = _loadedNotes;
    final shouldShowLoading = showLoading || previousNotes.isEmpty;

    if (shouldShowLoading) {
      _state = const TimelineScreenState.loading();
      notifyListeners();
    } else {
      _state = TimelineScreenState.loaded(
        notes: previousNotes,
        isRefreshing: true,
      );
      notifyListeners();
    }

    await Future<void>.delayed(const Duration(milliseconds: 500));

    final sessionResult = await _authRepository.restoreSession();
    await sessionResult.when(
      success: (session) async {
        if (session == null) {
          _setTimelineError('先に認証してください。');
          return;
        }

        final timelineResult = await _timelineRepository.fetchTimeline(session);
        timelineResult.when(
          success: (notes) {
            final currentNotes = _loadedNotes;
            _state = TimelineScreenState.loaded(
              notes: _mergeNotesPreservingMyReaction(currentNotes, notes),
              isRefreshing: false,
            );
          },
          failure: (error, _) {
            _setTimelineError('タイムライン取得に失敗しました: $error');
          },
        );
      },
      failure: (error, _) {
        _setTimelineError('セッション取得に失敗しました: $error');
      },
    );

    notifyListeners();
  }

  Future<void> startRealtime() async {
    _wantsRealtime = true;
    return _enqueueRealtimeOperation(() async {
      if (_isDisposed) return;
      final generation = ++_realtimeGeneration;

      await _cancelRealtimeSubscription();

      // 前のデータがない場合のみ loading 状態をセット
      if (_loadedNotes.isEmpty) {
        _state = const TimelineScreenState.loading();
        notifyListeners();
      }

      final sessionResult = await _authRepository.restoreSession();
      if (_isDisposed || !_wantsRealtime || generation != _realtimeGeneration) {
        return;
      }

      await sessionResult.when(
        success: (session) async {
          if (session == null) {
            _setTimelineError('先に認証してください。');
            notifyListeners();
            return;
          }

          if (!_wantsRealtime ||
              generation != _realtimeGeneration ||
              _isDisposed) {
            return;
          }

          late final StreamSubscription<Result<List<Note>>> subscription;
          subscription = _timelineRepository
              .watchTimeline(session)
              .listen(
                (timelineResult) {
                  if (!_wantsRealtime ||
                      generation != _realtimeGeneration ||
                      _isDisposed) {
                    return;
                  }

                  timelineResult.when(
                    success: (notes) {
                      final currentNotes = _loadedNotes;
                      _state = TimelineScreenState.loaded(
                        notes: _mergeNotesPreservingMyReaction(
                          currentNotes,
                          notes,
                        ),
                        isRefreshing: false,
                      );
                    },
                    failure: (error, _) {
                      _setTimelineError('タイムライン取得に失敗しました: $error');
                    },
                  );
                  notifyListeners();
                },
                onError: (error) {
                  if (!_wantsRealtime ||
                      generation != _realtimeGeneration ||
                      _isDisposed) {
                    return;
                  }
                  _setTimelineError('リアルタイム購読でエラーが発生しました: $error');
                  notifyListeners();
                },
                onDone: () {
                  _timelineSubscription = null;
                },
                cancelOnError: true,
              );

          if (!_wantsRealtime ||
              generation != _realtimeGeneration ||
              _isDisposed) {
            await subscription.cancel();
            return;
          }

          _timelineSubscription = subscription;
        },
        failure: (error, _) async {
          _setTimelineError('セッション取得に失敗しました: $error');
          notifyListeners();
        },
      );
    });
  }

  Future<void> stopRealtime() async {
    _wantsRealtime = false;
    return _enqueueRealtimeOperation(() async {
      ++_realtimeGeneration;
      await _cancelRealtimeSubscription();
    });
  }

  Future<void> _enqueueRealtimeOperation(Future<void> Function() operation) {
    final next = _realtimeOperation.then((_) => operation());
    _realtimeOperation = next.catchError((_) {});
    return next;
  }

  Future<void> _cancelRealtimeSubscription() async {
    final subscription = _timelineSubscription;
    _timelineSubscription = null;
    await subscription?.cancel();
  }

  Future<String?> createReaction(Note note, String reaction) async {
    final requestedReaction = reaction.trim();
    if (requestedReaction.isEmpty) {
      return 'リアクションが選択されていません。';
    }

    final targetNote = note.noteType == NoteType.pureRenote
        ? note.renote ?? note
        : note;
    if (targetNote.id.isEmpty) {
      return 'リアクション対象のノートIDが見つかりません。';
    }

    final outgoingReaction = _normalizeOutgoingReaction(requestedReaction);

    final sessionResult = await _authRepository.restoreSession();
    return sessionResult.when(
      success: (session) async {
        if (session == null) {
          return '先に認証してください。';
        }

        final reactionResult = await _timelineRepository.createReaction(
          session,
          noteId: targetNote.id,
          reaction: outgoingReaction,
        );
        return reactionResult.when(
          success: (_) {
            _applyMyReaction(note, targetNote.id, outgoingReaction);
            return null;
          },
          failure: (error, _) => 'リアクション送信に失敗しました: $error',
        );
      },
      failure: (error, _) async => 'セッション取得に失敗しました: $error',
    );
  }

  Future<String?> createRenote(Note note) async {
    final targetNote = note.noteType == NoteType.pureRenote
        ? note.renote ?? note
        : note;
    if (targetNote.id.isEmpty) {
      return 'リノート対象のノートIDが見つかりません。';
    }

    final sessionResult = await _authRepository.restoreSession();
    return sessionResult.when(
      success: (session) async {
        if (session == null) {
          return '先に認証してください。';
        }

        final renoteResult = await _timelineRepository.createRenote(
          session,
          noteId: targetNote.id,
        );
        return renoteResult.when(
          success: (_) => null,
          failure: (error, _) => 'リノート送信に失敗しました: $error',
        );
      },
      failure: (error, _) async => 'セッション取得に失敗しました: $error',
    );
  }

  Future<String?> createFavorite(Note note) async {
    final targetNote = note.noteType == NoteType.pureRenote
        ? note.renote ?? note
        : note;
    if (targetNote.id.isEmpty) {
      return 'お気に入り対象のノートIDが見つかりません。';
    }

    final sessionResult = await _authRepository.restoreSession();
    return sessionResult.when(
      success: (session) async {
        if (session == null) {
          return '先に認証してください。';
        }

        final favoriteResult = await _timelineRepository.createFavorite(
          session,
          noteId: targetNote.id,
        );
        return favoriteResult.when(
          success: (_) => null,
          failure: (error, _) => 'お気に入り追加に失敗しました: $error',
        );
      },
      failure: (error, _) async => 'セッション取得に失敗しました: $error',
    );
  }

  Future<String?> createPin(Note note) async {
    final targetNote = note.noteType == NoteType.pureRenote
        ? note.renote ?? note
        : note;
    if (targetNote.id.isEmpty) {
      return 'ピン留め対象のノートIDが見つかりません。';
    }

    final sessionResult = await _authRepository.restoreSession();
    return sessionResult.when(
      success: (session) async {
        if (session == null) {
          return '先に認証してください。';
        }

        final pinResult = await _timelineRepository.createPin(
          session,
          noteId: targetNote.id,
        );
        return pinResult.when(
          success: (_) => null,
          failure: (error, _) => 'ピン留めに失敗しました: $error',
        );
      },
      failure: (error, _) async => 'セッション取得に失敗しました: $error',
    );
  }

  Future<String?> createMute(String userId) async {
    if (userId.isEmpty) {
      return 'ミュート対象のユーザーIDが見つかりません。';
    }

    final sessionResult = await _authRepository.restoreSession();
    return sessionResult.when(
      success: (session) async {
        if (session == null) {
          return '先に認証してください。';
        }

        final muteResult = await _timelineRepository.createMute(
          session,
          userId: userId,
        );
        return muteResult.when(
          success: (_) => null,
          failure: (error, _) => 'ユーザーミュートに失敗しました: $error',
        );
      },
      failure: (error, _) async => 'セッション取得に失敗しました: $error',
    );
  }

  Future<String?> createRenoteMute(String userId) async {
    if (userId.isEmpty) {
      return 'リノートミュート対象のユーザーIDが見つかりません。';
    }

    final sessionResult = await _authRepository.restoreSession();
    return sessionResult.when(
      success: (session) async {
        if (session == null) {
          return '先に認証してください。';
        }

        final muteResult = await _timelineRepository.createRenoteMute(
          session,
          userId: userId,
        );
        return muteResult.when(
          success: (_) => null,
          failure: (error, _) => 'リノートミュートに失敗しました: $error',
        );
      },
      failure: (error, _) async => 'セッション取得に失敗しました: $error',
    );
  }

  Future<String?> createBlock(String userId) async {
    if (userId.isEmpty) {
      return 'ブロック対象のユーザーIDが見つかりません。';
    }

    final sessionResult = await _authRepository.restoreSession();
    return sessionResult.when(
      success: (session) async {
        if (session == null) {
          return '先に認証してください。';
        }

        final blockResult = await _timelineRepository.createBlock(
          session,
          userId: userId,
        );
        return blockResult.when(
          success: (_) => null,
          failure: (error, _) => 'ユーザーブロックに失敗しました: $error',
        );
      },
      failure: (error, _) async => 'セッション取得に失敗しました: $error',
    );
  }

  Future<String?> createReport(
    Note note,
    String category,
    String userComment,
  ) async {
    final targetNote = note.noteType == NoteType.pureRenote
        ? note.renote ?? note
        : note;
    if (targetNote.id.isEmpty) {
      return '通報対象のノートIDが見つかりません。';
    }
    if (targetNote.user.id.isEmpty) {
      return '通報対象のユーザーIDが見つかりません。';
    }

    final sessionResult = await _authRepository.restoreSession();
    return sessionResult.when(
      success: (session) async {
        if (session == null) {
          return '先に認証してください。';
        }

        final reportResult = await _timelineRepository.createReport(
          session,
          userId: targetNote.user.id,
          noteId: targetNote.id,
          category: category,
          userComment: userComment,
          noteUrl: targetNote.url,
        );
        return reportResult.when(
          success: (_) => null,
          failure: (error, _) => '通報に失敗しました: $error',
        );
      },
      failure: (error, _) async => 'セッション取得に失敗しました: $error',
    );
  }

  Future<String?> deleteNote(Note note) async {
    final targetNote = note.noteType == NoteType.pureRenote
        ? note.renote ?? note
        : note;
    if (targetNote.id.isEmpty) {
      return '削除対象のノートIDが見つかりません。';
    }

    final sessionResult = await _authRepository.restoreSession();
    return sessionResult.when(
      success: (session) async {
        if (session == null) {
          return '先に認証してください。';
        }

        final deleteResult = await _timelineRepository.deleteNote(
          session,
          noteId: targetNote.id,
        );
        return deleteResult.when(
          success: (_) {
            _removeDeletedNote(targetNote.id);
            return null;
          },
          failure: (error, _) => '投稿の削除に失敗しました: $error',
        );
      },
      failure: (error, _) async => 'セッション取得に失敗しました: $error',
    );
  }

  /// 純粋リノートを解除する。
  ///
  /// ラッパーノート（[note].id）を対象に削除APIを呼び、
  /// 成功後にタイムラインから該当カードを除去する。
  Future<String?> undoRenote(Note note) async {
    if (note.id.isEmpty) {
      return 'リノート解除対象のノートIDが見つかりません。';
    }

    final sessionResult = await _authRepository.restoreSession();
    return sessionResult.when(
      success: (session) async {
        if (session == null) {
          return '先に認証してください。';
        }

        final deleteResult = await _timelineRepository.deleteNote(
          session,
          noteId: note.id,
        );
        return deleteResult.when(
          success: (_) {
            _removeDeletedNote(note.id);
            return null;
          },
          failure: (error, _) => 'リノートの解除に失敗しました: $error',
        );
      },
      failure: (error, _) async => 'セッション取得に失敗しました: $error',
    );
  }

  void _removeDeletedNote(String targetNoteId) {
    final loadedState = switch (_state) {
      TimelineScreenStateLoaded(
        :final notes,
        :final isRefreshing,
        :final message,
      ) =>
        (notes: notes, isRefreshing: isRefreshing, message: message),
      _ => null,
    };
    if (loadedState == null) {
      return;
    }

    final filteredNotes = loadedState.notes
        .where(
          (note) => note.id != targetNoteId && note.renote?.id != targetNoteId,
        )
        .toList(growable: false);

    _state = TimelineScreenState.loaded(
      notes: List<Note>.unmodifiable(filteredNotes),
      isRefreshing: loadedState.isRefreshing,
      message: loadedState.message,
    );
    notifyListeners();
  }

  /// リアクション送信成功後にローカル状態の myReaction を更新する。
  void _applyMyReaction(Note note, String targetNoteId, String reaction) {
    final loadedState = switch (_state) {
      TimelineScreenStateLoaded() => _state as TimelineScreenStateLoaded,
      _ => null,
    };
    if (loadedState == null) {
      return;
    }

    final updatedNotes = loadedState.notes
        .map((item) {
          // 直接の note に一致する場合
          if (item.id == targetNoteId) {
            return _updateNoteReaction(item, reaction);
          }
          // 純粋リノートのリノート元に一致する場合
          final renote = item.renote;
          if (renote != null && renote.id == targetNoteId) {
            return item.copyWith(renote: _updateNoteReaction(renote, reaction));
          }
          return item;
        })
        .toList(growable: false);

    _state = loadedState.copyWith(notes: List<Note>.unmodifiable(updatedNotes));
    notifyListeners();
  }

  Note _updateNoteReaction(Note note, String reaction) {
    // WS 購読中はカウント変更を reacted/unreacted イベントに委ねる。
    // （API レスポンスより先に WS が届いた場合の applyReactionDelta 二重適用を防ぐ。）
    // WS が非アクティブな場合はローカルで楽観的にカウントを更新する。
    if (_timelineSubscription != null) {
      return note.copyWith(myReaction: reaction);
    }

    final previousReaction = note.myReaction;
    if (previousReaction == reaction) {
      return note.copyWith(myReaction: reaction);
    }

    var updated = note;
    if (previousReaction != null && previousReaction.isNotEmpty) {
      updated = updated.applyReactionDelta(previousReaction, -1);
    }
    updated = updated.applyReactionDelta(reaction, 1);

    return updated.copyWith(myReaction: reaction);
  }

  List<Note> _mergeNotesPreservingMyReaction(
    List<Note> current,
    List<Note> incoming,
  ) {
    final currentById = <String, Note>{};
    for (final note in current) {
      if (note.id.isNotEmpty) {
        currentById[note.id] = note;
      }

      final renote = note.renote;
      if (renote != null && renote.id.isNotEmpty) {
        currentById[renote.id] = renote;
      }
    }

    return List<Note>.unmodifiable(
      incoming
          .map(
            (note) => _mergeNotePreservingMyReaction(
              note,
              currentById[note.id],
              currentById,
            ),
          )
          .toList(growable: false),
    );
  }

  Note _mergeNotePreservingMyReaction(
    Note incoming,
    Note? current,
    Map<String, Note> currentById,
  ) {
    final matchedCurrent = current ?? currentById[incoming.id];
    final mergedRenote = switch (incoming.renote) {
      final renote? => _mergeNotePreservingMyReaction(
        renote,
        matchedCurrent?.renote,
        currentById,
      ),
      null => null,
    };

    return incoming.copyWith(
      myReaction: _resolveMergedMyReaction(incoming, matchedCurrent),
      renote: mergedRenote,
    );
  }

  String? _resolveMergedMyReaction(Note incoming, Note? current) {
    final incomingReaction = incoming.myReaction;
    final currentReaction = current?.myReaction;

    if (incomingReaction == null || incomingReaction.isEmpty) {
      return currentReaction;
    }
    if (currentReaction == null || currentReaction.isEmpty) {
      return incomingReaction;
    }
    if (incomingReaction == currentReaction) {
      return incomingReaction;
    }

    final incomingExists = _reactionKeyExists(
      incoming.reactions,
      incomingReaction,
    );
    final currentExists = _reactionKeyExists(
      incoming.reactions,
      currentReaction,
    );
    if (!incomingExists && currentExists) {
      return currentReaction;
    }

    return incomingReaction;
  }

  String _normalizeOutgoingReaction(String reaction) {
    final sameServerDot = RegExp(
      r'^:([a-zA-Z0-9_.-]+)@\.:$',
    ).firstMatch(reaction);
    if (sameServerDot != null) {
      // 互換入力として受け取りつつ、送信は自鯖形式 `:name:` を優先する。
      return ':${sameServerDot.group(1)}:';
    }

    return reaction;
  }

  bool _reactionKeyExists(Map<String, int> reactions, String reaction) {
    if (reactions.containsKey(reaction)) {
      return true;
    }
    final sameServerBare = RegExp(
      r'^:([a-zA-Z0-9_.-]+):$',
    ).firstMatch(reaction);
    if (sameServerBare != null) {
      return reactions.containsKey(':${sameServerBare.group(1)}@.:');
    }
    final sameServerDot = RegExp(
      r'^:([a-zA-Z0-9_.-]+)@\.:$',
    ).firstMatch(reaction);
    if (sameServerDot != null) {
      return reactions.containsKey(':${sameServerDot.group(1)}:');
    }
    return false;
  }

  @override
  void dispose() {
    _isDisposed = true;
    unawaited(stopRealtime());
    super.dispose();
  }

  void _setTimelineError(String message) {
    final currentState = _state;
    if (currentState is! TimelineScreenStateLoaded) {
      _state = TimelineScreenState.error(message: message);
      return;
    }

    _state = currentState.copyWith(isRefreshing: false, message: message);
  }
}
