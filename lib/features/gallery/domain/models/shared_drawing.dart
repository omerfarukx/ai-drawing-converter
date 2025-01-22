import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'shared_drawing.freezed.dart';
part 'shared_drawing.g.dart';

@freezed
class SharedDrawing with _$SharedDrawing {
  const factory SharedDrawing({
    required String id,
    required String userId,
    required String userName,
    required String userProfileImage,
    required String imageUrl,
    required String title,
    String? description,
    @Default(0) int likes,
    @Default(0) int comments,
    @Default(false) bool isPublic,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _SharedDrawing;

  factory SharedDrawing.fromJson(Map<String, dynamic> json) =>
      _$SharedDrawingFromJson(json);

  factory SharedDrawing.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Timestamp'i DateTime'a dönüştür
    final createdAtTimestamp = data['createdAt'] as Timestamp;
    final updatedAtTimestamp = data['updatedAt'] as Timestamp?;

    return SharedDrawing.fromJson({
      'id': doc.id,
      ...data,
      'createdAt': createdAtTimestamp.toDate().toIso8601String(),
      'updatedAt': updatedAtTimestamp?.toDate().toIso8601String(),
    });
  }
}
