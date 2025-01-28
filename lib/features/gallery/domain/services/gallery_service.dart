import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shared_drawing.dart';

class GalleryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Çizimi paylaşma metodu
  Future<void> shareDrawing({
    required String userId,
    required String userName,
    String? userPhotoURL,
    required String imageUrl,
    required String title,
    required String description,
    required String category,
  }) async {
    try {
      final now = DateTime.now();
      final batch = _firestore.batch();

      // Ana dokümanı oluştur
      final drawingRef = _firestore.collection('shared_drawings').doc();
      final drawing = SharedDrawing(
        id: drawingRef.id,
        userId: userId,
        userName: userName,
        userPhotoURL: userPhotoURL,
        imageUrl: imageUrl,
        title: title,
        description: description,
        category: category,
        createdAt: now,
        likesCount: 0,
        savesCount: 0,
        commentsCount: 0,
        isLiked: false,
        isSaved: false,
      );

      // Stats dokümanını oluştur
      final statsRef = drawingRef.collection('stats').doc('interactions');
      batch.set(drawingRef, drawing.toFirestore());
      batch.set(statsRef, {
        'likesCount': 0,
        'savesCount': 0,
        'commentsCount': 0,
        'updatedAt': now,
      });

      await batch.commit();
    } catch (e) {
      print('Debug: shareDrawing - HATA: $e');
      throw Exception('Çizim paylaşılırken bir hata oluştu: $e');
    }
  }

  // Keşfet sayfası için çizimleri getirme
  Stream<List<SharedDrawing>> getDrawings() {
    print('Debug: getSharedDrawings - Tüm çizimler getiriliyor...');
    return _firestore
        .collection('shared_drawings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      print('Debug: getSharedDrawings - ${snapshot.docs.length} çizim bulundu');
      return snapshot.docs
          .map((doc) => SharedDrawing.fromFirestore(
                doc.data(),
                doc.id,
              ))
          .toList();
    });
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
    print(
        'Debug: toggleLike - Beğeni işlemi başlatılıyor... DrawingId: $drawingId, UserId: $userId');

    final drawingRef = _firestore.collection('shared_drawings').doc(drawingId);
    final likeRef = drawingRef.collection('likes').doc(userId);
    final statsRef = drawingRef.collection('stats').doc('interactions');

    try {
      await _firestore.runTransaction((transaction) async {
        print('Debug: toggleLike - Transaction başlatıldı');

        final drawingDoc = await transaction.get(drawingRef);
        if (!drawingDoc.exists) {
          print('Debug: toggleLike - Çizim bulunamadı!');
          throw Exception('Çizim bulunamadı');
        }

        final likeDoc = await transaction.get(likeRef);
        final statsDoc = await transaction.get(statsRef);
        final currentStats = statsDoc.exists
            ? (statsDoc.data() ?? {})
            : {'likesCount': 0, 'savesCount': 0, 'commentsCount': 0};
        final currentLikesCount =
            (currentStats['likesCount'] as num?)?.toInt() ?? 0;

        if (likeDoc.exists) {
          print('Debug: toggleLike - Beğeni kaldırılıyor...');
          // Beğeniyi kaldır
          transaction.delete(likeRef);

          // Stats dokümanını güncelle
          if (!statsDoc.exists) {
            transaction.set(statsRef, {
              'likesCount': 0,
              'savesCount': 0,
              'commentsCount': 0,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          } else {
            transaction.update(statsRef, {
              'likesCount': FieldValue.increment(-1),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }

          // Ana dokümanı güncelle
          transaction.update(drawingRef, {
            'likesCount': currentLikesCount - 1,
            'lastInteractionAt': FieldValue.serverTimestamp(),
          });

          print('Debug: toggleLike - Beğeni kaldırıldı');
        } else {
          print('Debug: toggleLike - Beğeni ekleniyor...');
          // Beğeni ekle
          transaction.set(likeRef, {
            'createdAt': FieldValue.serverTimestamp(),
          });

          // Stats dokümanını güncelle
          if (!statsDoc.exists) {
            transaction.set(statsRef, {
              'likesCount': 1,
              'savesCount': 0,
              'commentsCount': 0,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          } else {
            transaction.update(statsRef, {
              'likesCount': FieldValue.increment(1),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }

          // Ana dokümanı güncelle
          transaction.update(drawingRef, {
            'likesCount': currentLikesCount + 1,
            'lastInteractionAt': FieldValue.serverTimestamp(),
          });

          print('Debug: toggleLike - Beğeni eklendi');
        }
      });
      print('Debug: toggleLike - İşlem başarıyla tamamlandı');
    } catch (e) {
      print('Debug: toggleLike - HATA: $e');
      throw Exception('Beğeni işlemi sırasında bir hata oluştu: $e');
    }
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
