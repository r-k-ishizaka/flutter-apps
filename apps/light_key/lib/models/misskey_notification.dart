import 'note.dart';
import 'user.dart';

/// Misskey の通知アイテム（グルーピング対応版）。
///
/// API: POST /api/i/notifications-grouped
sealed class MisskeyNotification {
  const MisskeyNotification({
    required this.id,
    required this.createdAt,
    required this.type,
  });

  final String id;
  final DateTime createdAt;
  final String type;

  factory MisskeyNotification.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final createdAtStr = json['createdAt'] as String? ?? '';
    final createdAt = createdAtStr.isNotEmpty
        ? (DateTime.tryParse(createdAtStr) ??
              DateTime.fromMillisecondsSinceEpoch(0))
        : DateTime.fromMillisecondsSinceEpoch(0);
    final type = json['type'] as String? ?? '';

    return switch (type) {
      'follow' => FollowNotification._fromJson(json, id, createdAt),
      'reply' => ReplyNotification._fromJson(json, id, createdAt),
      'mention' => MentionNotification._fromJson(json, id, createdAt),
      'renote' => RenoteNotification._fromJson(json, id, createdAt),
      'quote' => QuoteNotification._fromJson(json, id, createdAt),
      'reaction' => ReactionNotification._fromJson(json, id, createdAt),
      'reaction:grouped' => ReactionGroupedNotification._fromJson(
        json,
        id,
        createdAt,
      ),
      'followRequestAccepted' => FollowRequestAcceptedNotification._fromJson(
        json,
        id,
        createdAt,
      ),
      'pollEnded' => PollEndedNotification._fromJson(json, id, createdAt),
      'login' => LoginNotification._fromJson(json, id, createdAt),
      _ => UnknownNotification(id: id, createdAt: createdAt, type: type),
    };
  }
}

/// リプライ通知
class ReplyNotification extends MisskeyNotification {
  const ReplyNotification({
    required super.id,
    required super.createdAt,
    required this.user,
    required this.note,
  }) : super(type: 'reply');

  final User user;
  final Note note;

  factory ReplyNotification._fromJson(
    Map<String, dynamic> json,
    String id,
    DateTime createdAt,
  ) {
    return ReplyNotification(
      id: id,
      createdAt: createdAt,
      user: _parseUser(json['user']),
      note: _parseNote(json['note']),
    );
  }
}

/// メンション通知
class MentionNotification extends MisskeyNotification {
  const MentionNotification({
    required super.id,
    required super.createdAt,
    required this.user,
    required this.note,
  }) : super(type: 'mention');

  final User user;
  final Note note;

  factory MentionNotification._fromJson(
    Map<String, dynamic> json,
    String id,
    DateTime createdAt,
  ) {
    return MentionNotification(
      id: id,
      createdAt: createdAt,
      user: _parseUser(json['user']),
      note: _parseNote(json['note']),
    );
  }
}

/// リノート通知
class RenoteNotification extends MisskeyNotification {
  const RenoteNotification({
    required super.id,
    required super.createdAt,
    required this.user,
    required this.note,
  }) : super(type: 'renote');

  final User user;
  final Note note;

  factory RenoteNotification._fromJson(
    Map<String, dynamic> json,
    String id,
    DateTime createdAt,
  ) {
    return RenoteNotification(
      id: id,
      createdAt: createdAt,
      user: _parseUser(json['user']),
      note: _parseNote(json['note']),
    );
  }
}

/// 引用通知
class QuoteNotification extends MisskeyNotification {
  const QuoteNotification({
    required super.id,
    required super.createdAt,
    required this.user,
    required this.note,
  }) : super(type: 'quote');

  final User user;
  final Note note;

  factory QuoteNotification._fromJson(
    Map<String, dynamic> json,
    String id,
    DateTime createdAt,
  ) {
    return QuoteNotification(
      id: id,
      createdAt: createdAt,
      user: _parseUser(json['user']),
      note: _parseNote(json['note']),
    );
  }
}

/// フォロー通知
class FollowNotification extends MisskeyNotification {
  const FollowNotification({
    required super.id,
    required super.createdAt,
    required this.user,
  }) : super(type: 'follow');

  final User user;

  factory FollowNotification._fromJson(
    Map<String, dynamic> json,
    String id,
    DateTime createdAt,
  ) {
    final userJson = json['user'];
    final user = userJson is Map
        ? User.fromJson(Map<String, dynamic>.from(userJson))
        : const User();
    return FollowNotification(id: id, createdAt: createdAt, user: user);
  }
}

/// リアクション通知（単一）
class ReactionNotification extends MisskeyNotification {
  const ReactionNotification({
    required super.id,
    required super.createdAt,
    required this.user,
    required this.note,
    required this.reaction,
  }) : super(type: 'reaction');

  final User user;
  final Note note;

  /// リアクション絵文字名 (例: `:ohayoo:`)
  final String reaction;

  factory ReactionNotification._fromJson(
    Map<String, dynamic> json,
    String id,
    DateTime createdAt,
  ) {
    final user = _parseUser(json['user']);
    final note = _parseNote(json['note']);
    final reaction = json['reaction'] as String? ?? '';
    return ReactionNotification(
      id: id,
      createdAt: createdAt,
      user: user,
      note: note,
      reaction: reaction,
    );
  }
}

/// リアクション通知（グループ化）
class ReactionGroupedNotification extends MisskeyNotification {
  const ReactionGroupedNotification({
    required super.id,
    required super.createdAt,
    required this.note,
    required this.reactions,
  }) : super(type: 'reaction:grouped');

  final Note note;

  /// リアクションした人とリアクションのリスト
  final List<GroupedReactionItem> reactions;

  factory ReactionGroupedNotification._fromJson(
    Map<String, dynamic> json,
    String id,
    DateTime createdAt,
  ) {
    final note = _parseNote(json['note']);
    final reactionsRaw = json['reactions'];
    final reactions = <GroupedReactionItem>[];
    if (reactionsRaw is List) {
      for (final item in reactionsRaw) {
        if (item is Map) {
          reactions.add(
            GroupedReactionItem.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    return ReactionGroupedNotification(
      id: id,
      createdAt: createdAt,
      note: note,
      reactions: List.unmodifiable(reactions),
    );
  }
}

/// グループ化リアクション内の個別リアクション
class GroupedReactionItem {
  const GroupedReactionItem({required this.user, required this.reaction});

  final User user;
  final String reaction;

  factory GroupedReactionItem.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    final user = userJson is Map
        ? User.fromJson(Map<String, dynamic>.from(userJson))
        : const User();
    final reaction = json['reaction'] as String? ?? '';
    return GroupedReactionItem(user: user, reaction: reaction);
  }
}

/// フォローリクエスト承認通知
class FollowRequestAcceptedNotification extends MisskeyNotification {
  const FollowRequestAcceptedNotification({
    required super.id,
    required super.createdAt,
    required this.user,
    this.message,
  }) : super(type: 'followRequestAccepted');

  final User user;
  final String? message;

  factory FollowRequestAcceptedNotification._fromJson(
    Map<String, dynamic> json,
    String id,
    DateTime createdAt,
  ) {
    final user = _parseUser(json['user']);
    final message = json['message'] as String?;
    return FollowRequestAcceptedNotification(
      id: id,
      createdAt: createdAt,
      user: user,
      message: message,
    );
  }
}

/// 投票終了通知
class PollEndedNotification extends MisskeyNotification {
  const PollEndedNotification({
    required super.id,
    required super.createdAt,
    required this.note,
  }) : super(type: 'pollEnded');

  final Note note;

  factory PollEndedNotification._fromJson(
    Map<String, dynamic> json,
    String id,
    DateTime createdAt,
  ) {
    return PollEndedNotification(
      id: id,
      createdAt: createdAt,
      note: _parseNote(json['note']),
    );
  }
}

/// ログイン通知
class LoginNotification extends MisskeyNotification {
  const LoginNotification({
    required super.id,
    required super.createdAt,
    this.message,
  }) : super(type: 'login');

  final String? message;

  factory LoginNotification._fromJson(
    Map<String, dynamic> json,
    String id,
    DateTime createdAt,
  ) {
    final message =
        (json['body'] as String?) ??
        (json['message'] as String?) ??
        (json['text'] as String?);
    return LoginNotification(id: id, createdAt: createdAt, message: message);
  }
}

User _parseUser(Object? userJson) {
  if (userJson is Map) {
    return User.fromJson(Map<String, dynamic>.from(userJson));
  }
  return const User();
}

Note _parseNote(Object? noteJson) {
  if (noteJson is Map) {
    return Note.fromJson(Map<String, dynamic>.from(noteJson));
  }
  return Note(
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    user: const User(),
  );
}

/// 未対応の通知タイプ
class UnknownNotification extends MisskeyNotification {
  const UnknownNotification({
    required super.id,
    required super.createdAt,
    required super.type,
  });
}
