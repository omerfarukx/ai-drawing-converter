import 'package:freezed_annotation/freezed_annotation.dart';

part 'drawing.freezed.dart';
part 'drawing.g.dart';

@freezed
class Drawing with _$Drawing {
  const factory Drawing({
    required String id,
    required String imageUrl,
    required String title,
    String? description,
    required DateTime createdAt,
  }) = _Drawing;

  factory Drawing.fromJson(Map<String, dynamic> json) =>
      _$DrawingFromJson(json);
}
