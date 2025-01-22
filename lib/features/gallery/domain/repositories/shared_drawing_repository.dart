import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shared_drawing.dart';

final sharedDrawingRepositoryProvider =
    Provider((ref) => SharedDrawingRepository());

class SharedDrawingRepository {
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
  Future<SharedDrawing> shareDrawing({
    required String userId,
    required String userName,
    required String userProfileImage,
    required String imageUrl,
    required String title,
    String? description,
    bool isPublic = true,
  }) async {
    try {
      // Koleksiyonu başlat
      await initializeCollection();

      final data = {
        'userId': userId,
        'userName': userName,
        'userProfileImage': userProfileImage,
        'imageUrl': imageUrl,
        'title': title,
        'description': description,
        'likes': 0,
        'comments': 0,
        'isPublic': isPublic,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection(_collection).add(data);
      final doc = await docRef.get();

      return SharedDrawing.fromFirestore(doc);
    } catch (e) {
      throw 'Çizim paylaşılırken hata oluştu: $e';
    }
  }

  // Paylaşılan çizimleri getir
  Stream<List<SharedDrawing>> getSharedDrawings({
    int limit = 20,
    String? lastDocumentId,
  }) {
    try {
      var query = _firestore
          .collection(_collection)
          .where('isPublic', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocumentId != null) {
        query = query.startAfter([lastDocumentId]);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => SharedDrawing.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
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
            .map((doc) => SharedDrawing.fromFirestore(doc))
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
}
