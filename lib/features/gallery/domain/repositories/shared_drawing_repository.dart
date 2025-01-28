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
    String? category,
    bool isPublic = true,
  }) async {
    try {
      final now = DateTime.now();
      final data = {
        'userId': userId,
        'userName': userName,
        'userProfileImage': userProfileImage,
        'imageUrl': imageUrl,
        'title': title,
        'description': description ?? '',
        'category': category ?? 'Diğer',
        'likes': 0,
        'comments': 0,
        'saves': 0,
        'isPublic': isPublic,
        'createdAt': now,
      };

      // Dökümanı oluştur
      final docRef = await _firestore.collection(_collection).add(data);

      // SharedDrawing nesnesini oluştur ve dön
      return SharedDrawing(
        id: docRef.id,
        userId: userId,
        userName: userName,
        userPhotoURL: userProfileImage,
        imageUrl: imageUrl,
        title: title,
        description: description ?? '',
        category: category ?? 'Diğer',
        createdAt: DateTime.now(),
        likesCount: 0,
        savesCount: 0,
        commentsCount: 0,
        isLiked: false,
        isSaved: false,
      );
    } catch (e) {
      print('Çizim paylaşma hatası: $e');
      throw Exception(
          'Çizim paylaşılırken bir hata oluştu. Lütfen tekrar deneyin.');
    }
  }

  // Paylaşılan çizimleri getir
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
}
