// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String? ?? '',
  username: json['username'] as String? ?? '',
  name: json['name'] as String? ?? '',
  avatarUrl: json['avatarUrl'] as String?,
  avatarBlurHash: json['avatarBlurhash'] as String?,
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'name': instance.name,
  'avatarUrl': instance.avatarUrl,
  'avatarBlurhash': instance.avatarBlurHash,
};
