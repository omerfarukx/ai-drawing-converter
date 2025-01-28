import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shared_drawing.dart';

final drawingServiceProvider = Provider((ref) => DrawingService());

class DrawingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Çizimi beğen/beğenmekten vazgeç
  Future<void> toggleLike(String drawingId, String userId) async {
    print(
        'Debug: Beğeni işlemi başlatıldı - drawingId: $drawingId, userId: $userId');

    try {
      // Referansları al
      final drawingRef =
          _firestore.collection('shared_drawings').doc(drawingId);
      final likeRef = drawingRef.collection('likes').doc(userId);

      // Beğeni dokümanını kontrol et
      final likeDoc = await likeRef.get();

      if (likeDoc.exists) {
        // Beğeniyi kaldır
        await likeRef.delete();
        await drawingRef.update({
          'likesCount': FieldValue.increment(-1),
          'lastInteractionAt': FieldValue.serverTimestamp(),
        });
        print('Debug: Beğeni kaldırıldı');
      } else {
        // Beğeni ekle
        await likeRef.set({
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await drawingRef.update({
          'likesCount': FieldValue.increment(1),
          'lastInteractionAt': FieldValue.serverTimestamp(),
        });
        print('Debug: Beğeni eklendi');
      }
    } catch (e) {
      print('Debug: Beğeni işlemi hatası: $e');
      throw Exception('Beğeni işlemi başarısız oldu: $e');
    }
  }

  // Çizimi kaydet/kaydetmekten vazgeç
  Future<void> toggleSave(String drawingId, String userId) async {
    try {
      final drawingRef =
          _firestore.collection('shared_drawings').doc(drawingId);
      final saveRef = drawingRef.collection('saves').doc(userId);

      // Önce mevcut dokümanı al
      final drawingDoc = await drawingRef.get();
      if (!drawingDoc.exists) {
        throw Exception('Çizim bulunamadı');
      }

      final currentSavesCount = drawingDoc.data()?['savesCount'] ?? 0;
      final saveDoc = await saveRef.get();

      if (saveDoc.exists) {
        // Kaydı kaldır
        if (currentSavesCount > 0) {
          // Sadece 0'dan büyükse azalt
          await saveRef.delete();
          await drawingRef.update({
            'savesCount': FieldValue.increment(-1),
            'lastInteractionAt': FieldValue.serverTimestamp(),
          });
        }
      } else {
        // Kaydet
        await saveRef.set({
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await drawingRef.update({
          'savesCount': FieldValue.increment(1),
          'lastInteractionAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Debug: Kaydetme işlemi hatası: $e');
      throw Exception('Kaydetme işlemi başarısız oldu: $e');
    }
  }

  // Beğenilen çizimleri getir
  Future<List<SharedDrawing>> getLikedDrawings(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('shared_drawings')
          .where('likedBy', arrayContains: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SharedDrawing.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw 'Beğenilen çizimler getirilemedi: $e';
    }
  }

  // Kaydedilen çizimleri getir
  Future<List<SharedDrawing>> getSavedDrawings(String userId) async {
    try {
      print('Debug: getSavedDrawings - Kaydedilen çizimler getiriliyor...');

      // Tüm çizimleri getir ve client-side filtreleme yap
      final querySnapshot =
          await _firestore.collection('shared_drawings').get();

      final drawings = await Future.wait(
        querySnapshot.docs.map((doc) async {
          // Her çizim için saves koleksiyonunu kontrol et
          final saveDoc = await _firestore
              .collection('shared_drawings')
              .doc(doc.id)
              .collection('saves')
              .doc(userId)
              .get();

          // Eğer kullanıcı kaydetmişse, çizimi döndür
          if (saveDoc.exists) {
            return SharedDrawing.fromFirestore(doc.data(), doc.id);
          }
          return null;
        }),
      );

      // null olmayan çizimleri filtrele ve döndür
      return drawings
          .where((drawing) => drawing != null)
          .cast<SharedDrawing>()
          .toList();
    } catch (e) {
      print('Debug: getSavedDrawings - HATA: $e');
      throw 'Kaydedilen çizimler getirilemedi: $e';
    }
  }
}
