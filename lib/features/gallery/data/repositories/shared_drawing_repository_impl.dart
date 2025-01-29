import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yapayzeka_cizim/features/gallery/domain/models/comment.dart';
import 'package:yapayzeka_cizim/features/gallery/domain/models/shared_drawing.dart';
import 'package:yapayzeka_cizim/features/gallery/domain/repositories/shared_drawing_repository.dart';

final sharedDrawingRepositoryProvider =
    Provider<SharedDrawingRepository>((ref) {
  return SharedDrawingRepositoryImpl();
});

class SharedDrawingRepositoryImpl implements SharedDrawingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'shared_drawings';

  @override
  Future<void> addComment({
    required String drawingId,
    required String text,
    required String userId,
    required String userName,
    String? userPhotoURL,
  }) async {
    final commentData = {
      'drawingId': drawingId,
      'userId': userId,
      'userName': userName,
      'userPhotoURL': userPhotoURL,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection(_collection)
        .doc(drawingId)
        .collection('comments')
        .add(commentData);

    await _firestore.collection(_collection).doc(drawingId).update({
      'commentsCount': FieldValue.increment(1),
    });
  }

  @override
  Stream<List<Comment>> getComments(String drawingId) {
    return _firestore
        .collection(_collection)
        .doc(drawingId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Comment.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<void> deleteSharedDrawing(String drawingId) async {
    await _firestore.collection(_collection).doc(drawingId).delete();
  }

  @override
  Future<List<SharedDrawing>> getSharedDrawings({
    int limit = 20,
    String? startAfterId,
  }) async {
    try {
      var query = _firestore
          .collection(_collection)
          .where('isPublic', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfterId != null) {
        final startAfterDoc =
            await _firestore.collection(_collection).doc(startAfterId).get();
        if (startAfterDoc.exists) {
          query = query.startAfterDocument(startAfterDoc);
        }
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => SharedDrawing.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Debug: getSharedDrawings - Hata: $e');
      throw 'Paylaşılan çizimler getirilirken hata oluştu: $e';
    }
  }

  @override
  Stream<List<SharedDrawing>> getUserSharedDrawings(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SharedDrawing.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<void> initializeCollection() async {
    try {
      final collectionRef = _firestore.collection(_collection);
      final snapshot = await collectionRef.limit(1).get();

      if (snapshot.docs.isEmpty) {
        final docRef = await collectionRef.add({
          'userId': 'temp',
          'userName': 'temp',
          'userProfileImage': '',
          'imageUrl': '',
          'title': 'temp',
          'description': '',
          'likes': 0,
          'comments': 0,
          'isPublic': true,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await docRef.delete();
      }
    } catch (e) {
      print('Koleksiyon başlatma hatası: $e');
    }
  }

  @override
  Future<SharedDrawing> shareDrawing({
    required String userId,
    required String userName,
    required String userProfileImage,
    required String imageUrl,
    required String title,
    String? description,
    String? category,
    bool isPublic = true,
  }) async {
    try {
      final now = DateTime.now();
      final drawing = SharedDrawing(
        id: '',
        userId: userId,
        userName: userName,
        userPhotoURL: userProfileImage,
        imageUrl: imageUrl,
        title: title,
        description: description ?? '',
        category: category ?? 'Diğer',
        isPublic: isPublic,
        createdAt: now,
      );

      final docRef =
          await _firestore.collection(_collection).add(drawing.toFirestore());

      return drawing.copyWith(id: docRef.id);
    } catch (e) {
      print('Çizim paylaşma hatası: $e');
      throw Exception(
          'Çizim paylaşılırken bir hata oluştu. Lütfen tekrar deneyin.');
    }
  }

  @override
  Future<void> deleteComment({
    required String drawingId,
    required String commentId,
  }) async {
    try {
      final commentRef = _firestore
          .collection('shared_drawings')
          .doc(drawingId)
          .collection('comments')
          .doc(commentId);

      await commentRef.delete();
    } catch (e) {
      print('Error deleting comment: $e');
      rethrow;
    }
  }

  @override
  Future<void> addSharedDrawing(SharedDrawing drawing) async {
    await _firestore
        .collection(_collection)
        .doc(drawing.id)
        .set(drawing.toFirestore());
  }

  @override
  Future<void> updateSharedDrawing(SharedDrawing drawing) async {
    await _firestore
        .collection(_collection)
        .doc(drawing.id)
        .update(drawing.toFirestore());
  }

  @override
  Future<void> toggleLike(
      {required String drawingId, required String userId}) async {
    final docRef = _firestore.collection(_collection).doc(drawingId);
    final doc = await docRef.get();

    if (!doc.exists) return;

    final likes = (doc.data()?['likes'] as List<dynamic>?) ?? [];
    final isLiked = likes.contains(userId);

    await docRef.update({
      'likes': isLiked
          ? FieldValue.arrayRemove([userId])
          : FieldValue.arrayUnion([userId]),
      'likesCount': FieldValue.increment(isLiked ? -1 : 1),
    });
  }
}
