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
    String? userPhotoURL,
    required String imageUrl,
    required String title,
    required String description,
    required String category,
    @Default(0) int likesCount,
    @Default(0) int savesCount,
    @Default(0) int commentsCount,
    @Default(false) bool isLiked,
    @Default(false) bool isSaved,
    @Default(true) bool isPublic,
    required DateTime createdAt,
  }) = _SharedDrawing;

  const SharedDrawing._();

  factory SharedDrawing.fromJson(Map<String, dynamic> json) =>
      _$SharedDrawingFromJson(json);

  factory SharedDrawing.fromFirestore(Map<String, dynamic> data, String id) {
    return SharedDrawing(
      id: id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'İsimsiz Kullanıcı',
      userPhotoURL: data['userPhotoURL'] as String?,
      imageUrl: data['imageUrl'] as String? ?? '',
      title: data['title'] as String? ?? 'İsimsiz Çizim',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? 'Diğer',
      likesCount: (data['likesCount'] as num?)?.toInt() ?? 0,
      savesCount: (data['savesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (data['commentsCount'] as num?)?.toInt() ?? 0,
      isLiked: data['isLiked'] as bool? ?? false,
      isSaved: data['isSaved'] as bool? ?? false,
      isPublic: data['isPublic'] as bool? ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoURL': userPhotoURL,
      'imageUrl': imageUrl,
      'title': title,
      'description': description,
      'category': category,
      'likesCount': likesCount,
      'savesCount': savesCount,
      'commentsCount': commentsCount,
      'isPublic': isPublic,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
