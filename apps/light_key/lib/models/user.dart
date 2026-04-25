class User {
  const User({
    required this.id,
    required this.username,
    required this.name,
    this.avatarUrl,
  });

  final String id;
  final String username;
  final String name;
  final String? avatarUrl;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      name: json['name'] as String? ?? json['username'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
