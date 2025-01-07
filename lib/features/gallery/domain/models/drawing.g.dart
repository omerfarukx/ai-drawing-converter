// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drawing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DrawingImpl _$$DrawingImplFromJson(Map<String, dynamic> json) =>
    _$DrawingImpl(
      id: json['id'] as String,
      path: json['path'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      category: json['category'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$DrawingImplToJson(_$DrawingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'path': instance.path,
      'createdAt': instance.createdAt.toIso8601String(),
      'category': instance.category,
      'title': instance.title,
      'description': instance.description,
    };
