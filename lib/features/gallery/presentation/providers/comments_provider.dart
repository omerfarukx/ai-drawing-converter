import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yapayzeka_cizim/features/gallery/domain/models/comment.dart';
import 'package:yapayzeka_cizim/features/gallery/domain/repositories/shared_drawing_repository.dart';
import 'package:uuid/uuid.dart';

final commentsStreamProvider =
    StreamProvider.family<List<Comment>, String>((ref, drawingId) {
  final repository = ref.watch(sharedDrawingRepositoryProvider);
  return repository.getComments(drawingId);
});

final commentsProvider = Provider((ref) => CommentsNotifier(ref));

class CommentsNotifier {
  final Ref _ref;

  CommentsNotifier(this._ref);

  Future<void> addComment({
    required String drawingId,
    required String text,
    required String userId,
    required String userName,
    String? userPhotoURL,
  }) async {
    try {
      final comment = Comment(
        id: const Uuid().v4(),
        drawingId: drawingId,
        userId: userId,
        userName: userName,
        userPhotoURL: userPhotoURL,
        text: text,
        createdAt: DateTime.now(),
      );

      final repository = _ref.read(sharedDrawingRepositoryProvider);
      await repository.addComment(
        drawingId: drawingId,
        text: text,
        userId: userId,
        userName: userName,
        userPhotoURL: userPhotoURL,
      );
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  Future<void> deleteComment({
    required String drawingId,
    required String commentId,
  }) async {
    try {
      final repository = _ref.read(sharedDrawingRepositoryProvider);
      await repository.deleteComment(
          drawingId: drawingId, commentId: commentId);
    } catch (e) {
      print('Error deleting comment: $e');
      rethrow;
    }
  }
}
