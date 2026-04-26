class User {
  const User({
    required this.id,
    required this.username,
    required this.name,
    this.avatarUrl,
    this.avatarBlurHash,
  });

  final String id;
  final String username;
  final String name;
  final String? avatarUrl;
  final String? avatarBlurHash;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      name: json['name'] as String? ?? json['username'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      avatarBlurHash: json['avatarBlurhash'] as String?,
    );
  }
}
