import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
sealed class User with _$User {
  const User._();

  const factory User({
    @Default('') String id,
    @Default('') String username,
    @Default('') String name,
    String? avatarUrl,
    @JsonKey(name: 'avatarBlurhash') String? avatarBlurHash,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(_normalizeUserJson(json));
}

Map<String, dynamic> _normalizeUserJson(Map<String, dynamic> json) {
  final username = json['username'] as String? ?? '';
  return {
    ...json,
    'id': json['id'] as String? ?? '',
    'username': username,
    'name': json['name'] as String? ?? username,
  };
}
