import 'package:flutter/foundation.dart';

import '../../models/misskey_notification.dart';
import '../../models/note.dart';
import '../../models/note_type.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/notification_repository.dart';
import '../../repositories/timeline_repository.dart';
import 'notifications_screen_state.dart';

class NotificationsProvider extends ChangeNotifier {
  NotificationsProvider({
    required AuthRepository authRepository,
    required NotificationRepository notificationRepository,
    required TimelineRepository timelineRepository,
  }) : _authRepository = authRepository,
       _notificationRepository = notificationRepository,
       _timelineRepository = timelineRepository;

  final AuthRepository _authRepository;
  final NotificationRepository _notificationRepository;
  final TimelineRepository _timelineRepository;

  NotificationsScreenState _state = const NotificationsScreenStateIdle();

  NotificationsScreenState get state => _state;

  NotificationsScreenStateLoaded? get _loadedState => switch (_state) {
    final NotificationsScreenStateLoaded loaded => loaded,
    _ => null,
  };

  List<MisskeyNotification> get _loadedNotifications => switch (_state) {
    NotificationsScreenStateLoaded(:final notifications) => notifications,
    _ => const <MisskeyNotification>[],
  };

  Future<void> fetch({bool showLoading = true}) async {
    final previousLoaded = _loadedState;
    final previous = _loadedNotifications;
    if (showLoading || previous.isEmpty) {
      _state = const NotificationsScreenStateLoading();
      notifyListeners();
    }

    final sessionResult = await _authRepository.restoreSession();
    await sessionResult.when(
      success: (session) async {
        if (session == null) {
          _state = const NotificationsScreenStateError(message: '先に認証してください。');
          notifyListeners();
          return;
        }

        final result = await _notificationRepository.fetchGroupedNotifications(
          session,
        );
        result.when(
          success: (notifications) {
            _state = NotificationsScreenStateLoaded(
              notifications: List.unmodifiable(notifications),
              hasMore: notifications.isNotEmpty,
            );
          },
          failure: (error, _) {
            if (previous.isNotEmpty) {
              _state = NotificationsScreenStateLoaded(
                notifications: previous,
                hasMore: previousLoaded?.hasMore ?? true,
                message: '通知の取得に失敗しました: $error',
              );
            } else {
              _state = NotificationsScreenStateError(
                message: '通知の取得に失敗しました: $error',
              );
            }
          },
        );
        notifyListeners();
      },
      failure: (error, _) async {
        _state = NotificationsScreenStateError(
          message: 'セッション取得に失敗しました: $error',
        );
        notifyListeners();
      },
    );
  }

  Future<void> fetchMore() async {
    final loaded = switch (_state) {
      NotificationsScreenStateLoaded() =>
        _state as NotificationsScreenStateLoaded,
      _ => null,
    };
    if (loaded == null || loaded.isLoadingMore || !loaded.hasMore) return;

    final lastId = loaded.notifications.isEmpty
        ? null
        : loaded.notifications.last.id;

    _state = NotificationsScreenStateLoaded(
      notifications: loaded.notifications,
      isLoadingMore: true,
      hasMore: loaded.hasMore,
    );
    notifyListeners();

    final sessionResult = await _authRepository.restoreSession();
    await sessionResult.when(
      success: (session) async {
        if (session == null) {
          _state = NotificationsScreenStateLoaded(
            notifications: loaded.notifications,
            hasMore: loaded.hasMore,
            message: '先に認証してください。',
          );
          notifyListeners();
          return;
        }

        final result = await _notificationRepository.fetchGroupedNotifications(
          session,
          untilId: lastId,
        );
        result.when(
          success: (more) {
            final merged = _mergeNotifications(loaded.notifications, more);
            final appendedCount = merged.length - loaded.notifications.length;
            _state = NotificationsScreenStateLoaded(
              notifications: merged,
              hasMore: appendedCount > 0,
            );
          },
          failure: (error, _) {
            _state = NotificationsScreenStateLoaded(
              notifications: loaded.notifications,
              hasMore: loaded.hasMore,
              message: '追加読み込みに失敗しました: $error',
            );
          },
        );
        notifyListeners();
      },
      failure: (error, _) async {
        _state = NotificationsScreenStateLoaded(
          notifications: loaded.notifications,
          hasMore: loaded.hasMore,
          message: 'セッション取得に失敗しました: $error',
        );
        notifyListeners();
      },
    );
  }

  List<MisskeyNotification> _mergeNotifications(
    List<MisskeyNotification> current,
    List<MisskeyNotification> incoming,
  ) {
    final merged = <MisskeyNotification>[];
    final seenIds = <String>{};

    for (final item in [...current, ...incoming]) {
      final id = item.id;
      if (id.isNotEmpty && !seenIds.add(id)) {
        continue;
      }
      merged.add(item);
    }

    return List.unmodifiable(merged);
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
            _applyMyReaction(targetNote.id, outgoingReaction);
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
            _removeNotificationsForNote(targetNote.id);
            return null;
          },
          failure: (error, _) => '投稿の削除に失敗しました: $error',
        );
      },
      failure: (error, _) async => 'セッション取得に失敗しました: $error',
    );
  }

  /// 削除されたノートIDを含む通知を一覧から除外する。
  void _removeNotificationsForNote(String targetNoteId) {
    final loaded = _loadedState;
    if (loaded == null) return;

    final filtered = loaded.notifications
        .where((notification) {
          final note = switch (notification) {
            ReplyNotification(:final note) => note,
            MentionNotification(:final note) => note,
            RenoteNotification(:final note) => note,
            QuoteNotification(:final note) => note,
            ReactionNotification(:final note) => note,
            ReactionGroupedNotification(:final note) => note,
            PollEndedNotification(:final note) => note,
            _ => null,
          };
          if (note == null) return true;
          return note.id != targetNoteId && note.renote?.id != targetNoteId;
        })
        .toList(growable: false);

    _state = NotificationsScreenStateLoaded(
      notifications: List.unmodifiable(filtered),
      isLoadingMore: loaded.isLoadingMore,
      hasMore: loaded.hasMore,
      message: loaded.message,
    );
    notifyListeners();
  }

  void _applyMyReaction(String targetNoteId, String reaction) {
    final loaded = _loadedState;
    if (loaded == null) {
      return;
    }

    final updatedNotifications = loaded.notifications
        .map(
          (notification) =>
              _updateNotificationReaction(notification, targetNoteId, reaction),
        )
        .toList(growable: false);

    _state = NotificationsScreenStateLoaded(
      notifications: List.unmodifiable(updatedNotifications),
      isLoadingMore: loaded.isLoadingMore,
      hasMore: loaded.hasMore,
      message: loaded.message,
    );
    notifyListeners();
  }

  MisskeyNotification _updateNotificationReaction(
    MisskeyNotification notification,
    String targetNoteId,
    String reaction,
  ) {
    return switch (notification) {
      ReplyNotification(
        :final id,
        :final createdAt,
        :final user,
        :final note,
      ) =>
        ReplyNotification(
          id: id,
          createdAt: createdAt,
          user: user,
          note: _updateMyReactionInNote(note, targetNoteId, reaction),
        ),
      MentionNotification(
        :final id,
        :final createdAt,
        :final user,
        :final note,
      ) =>
        MentionNotification(
          id: id,
          createdAt: createdAt,
          user: user,
          note: _updateMyReactionInNote(note, targetNoteId, reaction),
        ),
      RenoteNotification(
        :final id,
        :final createdAt,
        :final user,
        :final note,
      ) =>
        RenoteNotification(
          id: id,
          createdAt: createdAt,
          user: user,
          note: _updateMyReactionInNote(note, targetNoteId, reaction),
        ),
      QuoteNotification(
        :final id,
        :final createdAt,
        :final user,
        :final note,
      ) =>
        QuoteNotification(
          id: id,
          createdAt: createdAt,
          user: user,
          note: _updateMyReactionInNote(note, targetNoteId, reaction),
        ),
      ReactionNotification(
        :final id,
        :final createdAt,
        :final user,
        :final note,
        :final reaction,
      ) =>
        ReactionNotification(
          id: id,
          createdAt: createdAt,
          user: user,
          note: _updateMyReactionInNote(note, targetNoteId, reaction),
          reaction: reaction,
        ),
      ReactionGroupedNotification(
        :final id,
        :final createdAt,
        :final note,
        :final reactions,
      ) =>
        ReactionGroupedNotification(
          id: id,
          createdAt: createdAt,
          note: _updateMyReactionInNote(note, targetNoteId, reaction),
          reactions: reactions,
        ),
      PollEndedNotification(:final id, :final createdAt, :final note) =>
        PollEndedNotification(
          id: id,
          createdAt: createdAt,
          note: _updateMyReactionInNote(note, targetNoteId, reaction),
        ),
      _ => notification,
    };
  }

  Note _updateMyReactionInNote(
    Note note,
    String targetNoteId,
    String reaction,
  ) {
    if (note.id == targetNoteId) {
      return _updateNoteReaction(note, reaction);
    }

    final updatedRenote = note.renote == null
        ? null
        : _updateMyReactionInNote(note.renote!, targetNoteId, reaction);
    final updatedReply = note.reply == null
        ? null
        : _updateMyReactionInNote(note.reply!, targetNoteId, reaction);

    if (identical(updatedRenote, note.renote) &&
        identical(updatedReply, note.reply)) {
      return note;
    }

    return note.copyWith(renote: updatedRenote, reply: updatedReply);
  }

  Note _updateNoteReaction(Note note, String reaction) {
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

  String _normalizeOutgoingReaction(String reaction) {
    final sameServerDot = RegExp(
      r'^:([a-zA-Z0-9_.-]+)@\.:$',
    ).firstMatch(reaction);
    if (sameServerDot != null) {
      return ':${sameServerDot.group(1)}:';
    }

    return reaction;
  }
}
