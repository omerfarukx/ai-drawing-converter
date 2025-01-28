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
      displayName: json['displayName'] as String,
      userPhotoURL: json['userPhotoURL'] as String?,
      imageUrl: json['imageUrl'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      savesCount: (json['savesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isSaved: json['isSaved'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$SharedDrawingImplToJson(_$SharedDrawingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'displayName': instance.displayName,
      'userPhotoURL': instance.userPhotoURL,
      'imageUrl': instance.imageUrl,
      'title': instance.title,
      'description': instance.description,
      'likesCount': instance.likesCount,
      'savesCount': instance.savesCount,
      'commentsCount': instance.commentsCount,
      'isLiked': instance.isLiked,
      'isSaved': instance.isSaved,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
