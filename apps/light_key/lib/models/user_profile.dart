class UserProfileRole {
  const UserProfileRole({
    required this.name,
    this.iconUrl,
    this.color,
  });

  final String name;
  final String? iconUrl;
  final String? color;
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    required this.name,
    this.avatarUrl,
    this.avatarBlurHash,
    this.bannerUrl,
    this.roles = const <UserProfileRole>[],
    this.description,
    this.birthday,
    this.createdAt,
    this.notesCount = 0,
    this.followingCount = 0,
    this.followersCount = 0,
  });

  final String id;
  final String username;
  final String name;
  final String? avatarUrl;
  final String? avatarBlurHash;
  final String? bannerUrl;
  final List<UserProfileRole> roles;
  final String? description;
  final DateTime? birthday;
  final DateTime? createdAt;
  final int notesCount;
  final int followingCount;
  final int followersCount;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final username = json['username'] as String? ?? '';
    final name = (json['name'] as String?)?.trim();
    return UserProfile(
      id: json['id'] as String? ?? '',
      username: username,
      name: (name == null || name.isEmpty) ? username : name,
      avatarUrl: json['avatarUrl'] as String?,
      avatarBlurHash: json['avatarBlurhash'] as String?,
      bannerUrl: json['bannerUrl'] as String?,
      roles: _parseRoles(json['roles']),
      description: json['description'] as String?,
      birthday: _parseDateTime(json['birthday']),
      createdAt: _parseDateTime(json['createdAt']),
      notesCount: _parseInt(json['notesCount']),
      followingCount: _parseInt(json['followingCount']),
      followersCount: _parseInt(json['followersCount']),
    );
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  static int _parseInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static List<UserProfileRole> _parseRoles(Object? value) {
    if (value is! List) return const <UserProfileRole>[];

    return value
        .map((item) {
          if (item is String && item.isNotEmpty) {
            return UserProfileRole(name: item);
          }
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            final roleName = map['name'] as String?;
            if (roleName != null && roleName.isNotEmpty) {
              return UserProfileRole(
                name: roleName,
                iconUrl: map['iconUrl'] as String?,
                color: map['color'] as String?,
              );
            }
          }
          return null;
        })
        .whereType<UserProfileRole>()
        .toList(growable: false);
  }
}
