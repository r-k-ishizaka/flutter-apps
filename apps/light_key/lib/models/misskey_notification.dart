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
      'reaction' => ReactionNotification._fromJson(json, id, createdAt),
      'reaction:grouped' =>
        ReactionGroupedNotification._fromJson(json, id, createdAt),
      'followRequestAccepted' =>
        FollowRequestAcceptedNotification._fromJson(json, id, createdAt),
      _ => UnknownNotification(id: id, createdAt: createdAt, type: type),
    };
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
    final userJson = json['user'];
    final user = userJson is Map
        ? User.fromJson(Map<String, dynamic>.from(userJson))
        : const User();
    final noteJson = json['note'];
    final note = noteJson is Map
        ? Note.fromJson(Map<String, dynamic>.from(noteJson))
        : Note(
            createdAt: DateTime.fromMillisecondsSinceEpoch(0),
            user: const User(),
          );
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
    final noteJson = json['note'];
    final note = noteJson is Map
        ? Note.fromJson(Map<String, dynamic>.from(noteJson))
        : Note(
            createdAt: DateTime.fromMillisecondsSinceEpoch(0),
            user: const User(),
          );
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
    final userJson = json['user'];
    final user = userJson is Map
        ? User.fromJson(Map<String, dynamic>.from(userJson))
        : const User();
    final message = json['message'] as String?;
    return FollowRequestAcceptedNotification(
      id: id,
      createdAt: createdAt,
      user: user,
      message: message,
    );
  }
}

/// 未対応の通知タイプ
class UnknownNotification extends MisskeyNotification {
  const UnknownNotification({
    required super.id,
    required super.createdAt,
    required super.type,
  });
}
