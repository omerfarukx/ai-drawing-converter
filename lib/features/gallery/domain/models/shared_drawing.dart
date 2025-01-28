import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'shared_drawing.freezed.dart';
part 'shared_drawing.g.dart';

@freezed
abstract class SharedDrawing with _$SharedDrawing {
  const factory SharedDrawing({
    required String id,
    required String userId,
    required String userName,
    required String displayName,
    String? userPhotoURL,
    required String imageUrl,
    required String title,
    String? description,
    @Default(0) int likesCount,
    @Default(0) int savesCount,
    @Default(0) int commentsCount,
    @Default(false) bool isLiked,
    @Default(false) bool isSaved,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SharedDrawing;

  const SharedDrawing._();

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'displayName': displayName,
      'userPhotoURL': userPhotoURL,
      'imageUrl': imageUrl,
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory SharedDrawing.fromJson(Map<String, dynamic> json) =>
      _$SharedDrawingFromJson(json);

  factory SharedDrawing.fromFirestore(Map<String, dynamic> data, String id) {
    return SharedDrawing(
      id: id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Anonim',
      displayName: data['displayName'] as String? ??
          data['userName'] as String? ??
          'Anonim',
      userPhotoURL: data['userProfileImage'] as String?,
      imageUrl: data['imageUrl'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String?,
      likesCount: (data['likes'] as num?)?.toInt() ?? 0,
      savesCount: (data['saves'] as num?)?.toInt() ?? 0,
      commentsCount: (data['comments'] as num?)?.toInt() ?? 0,
      isLiked: false,
      isSaved: false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
