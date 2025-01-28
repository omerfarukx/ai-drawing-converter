import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shared_drawing.dart';

class GalleryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Çizimi paylaşma metodu
  Future<void> shareDrawing({
    required String userId,
    required String userName,
    required String displayName,
    String? userPhotoURL,
    required String imageUrl,
    required String title,
    String? description,
  }) async {
    try {
      final now = DateTime.now();

      final drawing = SharedDrawing(
        id: '', // Firestore otomatik oluşturacak
        userId: userId,
        userName: userName,
        displayName: displayName,
        userPhotoURL: userPhotoURL,
        imageUrl: imageUrl,
        title: title,
        description: description,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore.collection('shared_drawings').add(drawing.toFirestore());
    } catch (e) {
      throw Exception('Çizim paylaşılırken bir hata oluştu: $e');
    }
  }

  // Keşfet sayfası için çizimleri getirme
  Stream<List<SharedDrawing>> getDrawings() {
    return _firestore
        .collection('shared_drawings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SharedDrawing.fromFirestore(
                  doc.data(),
                  doc.id,
                ))
            .toList());
  }

  // Kullanıcının çizimlerini getirme
  Stream<List<SharedDrawing>> getUserDrawings(String userId) {
    return _firestore
        .collection('shared_drawings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SharedDrawing.fromFirestore(
                  doc.data(),
                  doc.id,
                ))
            .toList());
  }

  // Çizimi beğen/beğenmekten vazgeç
  Future<void> toggleLike(String drawingId, String userId) async {
    final drawingRef = _firestore.collection('shared_drawings').doc(drawingId);
    final likeRef = drawingRef.collection('likes').doc(userId);
    final statsRef = drawingRef.collection('stats').doc('interactions');

    await _firestore.runTransaction((transaction) async {
      final likeDoc = await transaction.get(likeRef);

      if (likeDoc.exists) {
        // Beğeniyi kaldır
        transaction.delete(likeRef);
        transaction.update(statsRef, {
          'likesCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Beğeni ekle
        transaction.set(likeRef, {
          'createdAt': FieldValue.serverTimestamp(),
        });
        transaction.update(statsRef, {
          'likesCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  // Çizimi kaydet/kayıttan kaldır
  Future<void> toggleSave(String drawingId, String userId) async {
    final drawingRef = _firestore.collection('shared_drawings').doc(drawingId);
    final saveRef = drawingRef.collection('saves').doc(userId);
    final statsRef = drawingRef.collection('stats').doc('interactions');

    await _firestore.runTransaction((transaction) async {
      final saveDoc = await transaction.get(saveRef);

      if (saveDoc.exists) {
        // Kaydı kaldır
        transaction.delete(saveRef);
        transaction.update(statsRef, {
          'savesCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Kaydet
        transaction.set(saveRef, {
          'createdAt': FieldValue.serverTimestamp(),
        });
        transaction.update(statsRef, {
          'savesCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }
}
