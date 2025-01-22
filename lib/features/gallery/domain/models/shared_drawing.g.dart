// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_drawing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SharedDrawingImpl _$$SharedDrawingImplFromJson(Map<String, dynamic> json) =>
    _$SharedDrawingImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userProfileImage: json['userProfileImage'] as String,
      imageUrl: json['imageUrl'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      isPublic: json['isPublic'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$SharedDrawingImplToJson(_$SharedDrawingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'userProfileImage': instance.userProfileImage,
      'imageUrl': instance.imageUrl,
      'title': instance.title,
      'description': instance.description,
      'likes': instance.likes,
      'comments': instance.comments,
      'isPublic': instance.isPublic,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
