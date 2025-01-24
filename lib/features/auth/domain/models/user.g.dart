// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String?,
      photoURL: json['photoURL'] as String?,
      bio: json['bio'] as String?,
      followers: (json['followers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      following: (json['following'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      drawingsCount: (json['drawingsCount'] as num?)?.toInt() ?? 0,
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'username': instance.username,
      'displayName': instance.displayName,
      'photoURL': instance.photoURL,
      'bio': instance.bio,
      'followers': instance.followers,
      'following': instance.following,
      'drawingsCount': instance.drawingsCount,
      'isVerified': instance.isVerified,
      'createdAt': instance.createdAt?.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
    };
