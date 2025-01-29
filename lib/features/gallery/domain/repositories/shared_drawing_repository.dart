import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shared_drawing.dart';
import 'package:yapayzeka_cizim/features/gallery/domain/models/comment.dart';
import 'package:yapayzeka_cizim/features/gallery/data/repositories/shared_drawing_repository_impl.dart';

final sharedDrawingRepositoryProvider =
    Provider<SharedDrawingRepository>((ref) {
  return SharedDrawingRepositoryImpl();
});

abstract class SharedDrawingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'shared_drawings';

  // Koleksiyonu ve indeksi oluştur
  Future<void> initializeCollection() async {
    try {
      // Koleksiyonun varlığını kontrol et
      final collectionRef = _firestore.collection(_collection);
      final snapshot = await collectionRef.limit(1).get();

      // Koleksiyon boşsa örnek bir döküman ekle ve sil
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

        // Örnek dökümanı sil
        await docRef.delete();
      }
    } catch (e) {
      print('Koleksiyon başlatma hatası: $e');
    }
  }

  // Çizim paylaş
  Future<List<SharedDrawing>> getSharedDrawings({
    int limit = 20,
    String? startAfterId,
  }) async {
    try {
      print('Debug: getSharedDrawings - Sorgu oluşturuluyor...');
      var query = _firestore
          .collection(_collection)
          .where('isPublic', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfterId != null) {
        print('Debug: getSharedDrawings - Pagination yapılıyor...');
        final startAfterDoc =
            await _firestore.collection(_collection).doc(startAfterId).get();
        if (startAfterDoc.exists) {
          query = query.startAfterDocument(startAfterDoc);
        }
      }

      print('Debug: getSharedDrawings - Sorgu çalıştırılıyor...');
      final snapshot = await query.get();
      print('Debug: getSharedDrawings - ${snapshot.docs.length} çizim bulundu');

      final drawings = snapshot.docs
          .map((doc) => SharedDrawing.fromFirestore(doc.data()!, doc.id))
          .toList();

      print(
          'Debug: getSharedDrawings - Çizimler: ${drawings.map((d) => d.title).join(', ')}');
      return drawings;
    } catch (e) {
      print('Debug: getSharedDrawings - Hata: $e');
      throw 'Paylaşılan çizimler getirilirken hata oluştu: $e';
    }
  }

  // Kullanıcının paylaşımlarını getir
  Stream<List<SharedDrawing>> getUserSharedDrawings(String userId) {
    try {
      return _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => SharedDrawing.fromFirestore(doc.data()!, doc.id))
            .toList();
      });
    } catch (e) {
      throw 'Kullanıcının paylaşımları getirilirken hata oluştu: $e';
    }
  }

  // Paylaşımı sil
  Future<void> deleteSharedDrawing(String drawingId) async {
    try {
      await _firestore.collection(_collection).doc(drawingId).delete();
    } catch (e) {
      throw 'Paylaşım silinirken hata oluştu: $e';
    }
  }

  Future<void> addComment({
    required String drawingId,
    required String text,
    required String userId,
    required String userName,
    String? userPhotoURL,
  });

  Stream<List<Comment>> getComments(String drawingId);

  Future<SharedDrawing> shareDrawing({
    required String userId,
    required String userName,
    required String userProfileImage,
    required String imageUrl,
    required String title,
    String? description,
    String? category,
    bool isPublic = true,
  });

  Future<void> addSharedDrawing(SharedDrawing drawing);
  Future<void> updateSharedDrawing(SharedDrawing drawing);
  Future<void> deleteComment(
      {required String drawingId, required String commentId});
  Future<void> toggleLike({
    required String drawingId,
    required String userId,
  });
}
