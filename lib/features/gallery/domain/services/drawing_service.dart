import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shared_drawing.dart';

final drawingServiceProvider = Provider((ref) => DrawingService());

class DrawingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Çizimi beğen/beğenmekten vazgeç
  Future<void> toggleLike(String drawingId, String userId) async {
    try {
      final drawingRef =
          _firestore.collection('shared_drawings').doc(drawingId);
      final doc = await drawingRef.get();

      if (!doc.exists) {
        throw 'Çizim bulunamadı';
      }

      final likes = List<String>.from(doc.data()?['likedBy'] ?? []);

      if (likes.contains(userId)) {
        // Beğeniyi kaldır
        await drawingRef.update({
          'likedBy': FieldValue.arrayRemove([userId]),
        });
      } else {
        // Beğeni ekle
        await drawingRef.update({
          'likedBy': FieldValue.arrayUnion([userId]),
        });
      }
    } catch (e) {
      throw 'Beğeni işlemi başarısız oldu: $e';
    }
  }

  // Çizimi kaydet/kaydetmekten vazgeç
  Future<void> toggleSave(String drawingId, String userId) async {
    try {
      final drawingRef =
          _firestore.collection('shared_drawings').doc(drawingId);
      final doc = await drawingRef.get();

      if (!doc.exists) {
        throw 'Çizim bulunamadı';
      }

      final saves = List<String>.from(doc.data()?['savedBy'] ?? []);

      if (saves.contains(userId)) {
        // Kaydı kaldır
        await drawingRef.update({
          'savedBy': FieldValue.arrayRemove([userId]),
        });
      } else {
        // Kaydet
        await drawingRef.update({
          'savedBy': FieldValue.arrayUnion([userId]),
        });
      }
    } catch (e) {
      throw 'Kaydetme işlemi başarısız oldu: $e';
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
      final querySnapshot = await _firestore
          .collection('shared_drawings')
          .where('savedBy', arrayContains: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SharedDrawing.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw 'Kaydedilen çizimler getirilemedi: $e';
    }
  }
}
