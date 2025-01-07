import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'drawing.freezed.dart';
part 'drawing.g.dart';

@freezed
class Drawing with _$Drawing {
  const factory Drawing({
    required String id,
    required String path,
    required DateTime createdAt,
    required String category,
    String? title,
    String? description,
  }) = _Drawing;

  factory Drawing.fromJson(Map<String, dynamic> json) =>
      _$DrawingFromJson(json);
}
