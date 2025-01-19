// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drawing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DrawingImpl _$$DrawingImplFromJson(Map<String, dynamic> json) =>
    _$DrawingImpl(
      id: json['id'] as String,
      path: json['path'] as String,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      isAIGenerated: json['isAIGenerated'] as bool? ?? false,
    );

Map<String, dynamic> _$$DrawingImplToJson(_$DrawingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'path': instance.path,
      'category': instance.category,
      'createdAt': instance.createdAt.toIso8601String(),
      'title': instance.title,
      'description': instance.description,
      'isAIGenerated': instance.isAIGenerated,
    };
