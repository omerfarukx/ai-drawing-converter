// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String? ?? 'Yeni Kullanıcı',
      photoUrl: json['photoURL'] as String?,
      bio: json['bio'] as String? ?? 'Merhaba! Ben yeni bir kullanıcıyım.',
      drawingsCount: (json['drawingsCount'] as num?)?.toInt() ?? 0,
      followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
      followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
      savedDrawingsCount: (json['savedDrawingsCount'] as num?)?.toInt() ?? 0,
      isFollowing: json['isFollowing'] as bool? ?? false,
      followers: (json['followers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      following: (json['following'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: _dateTimeFromTimestamp(json['createdAt']),
      lastLoginAt: _dateTimeFromTimestamp(json['lastLoginAt']),
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'displayName': instance.displayName,
      'photoURL': instance.photoUrl,
      'bio': instance.bio,
      'drawingsCount': instance.drawingsCount,
      'followersCount': instance.followersCount,
      'followingCount': instance.followingCount,
      'savedDrawingsCount': instance.savedDrawingsCount,
      'isFollowing': instance.isFollowing,
      'followers': instance.followers,
      'following': instance.following,
      'createdAt': _dateTimeToTimestamp(instance.createdAt),
      'lastLoginAt': _dateTimeToTimestamp(instance.lastLoginAt),
    };
