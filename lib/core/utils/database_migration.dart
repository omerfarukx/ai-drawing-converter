import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class DatabaseMigration {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Eski verileri yedekle
  Future<Map<String, dynamic>> backupOldData() async {
    final backup = <String, dynamic>{};

    // Users koleksiyonunu yedekle
    final usersSnapshot = await _firestore.collection('users').get();
    backup['users'] = usersSnapshot.docs
        .map((doc) => {
              'id': doc.id,
              'data': doc.data(),
            })
        .toList();

    // Shared drawings koleksiyonunu yedekle
    final drawingsSnapshot =
        await _firestore.collection('shared_drawings').get();
    backup['shared_drawings'] = drawingsSnapshot.docs
        .map((doc) => {
              'id': doc.id,
              'data': doc.data(),
            })
        .toList();

    // Credit transactions koleksiyonunu yedekle
    final creditsSnapshot =
        await _firestore.collection('credit_transactions').get();
    backup['credit_transactions'] = creditsSnapshot.docs
        .map((doc) => {
              'id': doc.id,
              'data': doc.data(),
            })
        .toList();

    return backup;
  }

  // Eski koleksiyonları sil
  Future<void> deleteOldCollections() async {
    final batch = _firestore.batch();

    // Users koleksiyonunu sil
    final usersSnapshot = await _firestore.collection('users').get();
    for (var doc in usersSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Shared drawings koleksiyonunu sil
    final drawingsSnapshot =
        await _firestore.collection('shared_drawings').get();
    for (var doc in drawingsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Credit transactions koleksiyonunu sil
    final creditsSnapshot =
        await _firestore.collection('credit_transactions').get();
    for (var doc in creditsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Yeni yapıyı oluştur ve eski verileri aktar
  Future<void> migrateToNewStructure(Map<String, dynamic> backup) async {
    final batch = _firestore.batch();

    // Users koleksiyonunu yeni yapıya aktar
    for (var user in backup['users']) {
      final userData = user['data'];
      final userId = user['id'];

      // Profil bilgileri
      batch.set(_firestore.doc('users/$userId/profile/info'), {
        'displayName': userData['displayName'],
        'email': userData['email'],
        'photoURL': userData['photoURL'],
        'bio': userData['bio'] ?? '',
        'createdAt': userData['createdAt'],
        'isVerified': userData['isVerified'] ?? false,
        'lastLoginAt': userData['lastLoginAt'] ?? FieldValue.serverTimestamp(),
      });

      // İstatistikler
      batch.set(_firestore.doc('users/$userId/stats/counts'), {
        'drawingsCount': userData['drawingsCount'] ?? 0,
        'followersCount': userData['followersCount'] ?? 0,
        'followingCount': userData['followingCount'] ?? 0,
        'savedDrawingsCount': 0, // Yeni alan
      });
    }

    // Çizimleri yeni yapıya aktar
    for (var drawing in backup['shared_drawings']) {
      final drawingData = drawing['data'];
      final drawingId = drawing['id'];

      // Çizim meta verileri
      batch.set(_firestore.doc('drawings/$drawingId/metadata/info'), {
        'title': drawingData['title'],
        'description': drawingData['description'] ?? '',
        'createdAt': drawingData['createdAt'],
        'updatedAt': FieldValue.serverTimestamp(),
        'imageUrl': drawingData['imageUrl'],
      });

      // Çizim yaratıcı bilgileri
      batch.set(_firestore.doc('drawings/$drawingId/creator/info'), {
        'userId': drawingData['userId'],
        'displayName': drawingData['userName'],
        'photoURL': drawingData['userPhotoURL'] ?? '',
      });

      // Çizim etkileşim sayıları
      batch.set(_firestore.doc('drawings/$drawingId/interactions/counts'), {
        'likesCount': drawingData['likes'] ?? 0,
        'savesCount': drawingData['saves'] ?? 0,
        'commentsCount': 0, // Yeni alan
      });

      // Beğenileri aktar
      if (drawingData['likedBy'] != null) {
        for (String userId in drawingData['likedBy']) {
          batch.set(_firestore.doc('likes/${drawingId}_$userId'), {
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      }

      // Kaydetmeleri aktar
      if (drawingData['savedBy'] != null) {
        for (String userId in drawingData['savedBy']) {
          batch.set(_firestore.doc('saves/${drawingId}_$userId'), {
            'timestamp': FieldValue.serverTimestamp(),
          });

          // Kullanıcının kaydedilen çizimler listesine ekle
          batch.set(_firestore.doc('users/$userId/saved_drawings/$drawingId'), {
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      }
    }

    await batch.commit();
  }

  // Tüm migrasyon işlemini yönet
  Future<void> migrate() async {
    try {
      print('Veri yedekleme başlıyor...');
      final backup = await backupOldData();
      print('Veri yedekleme tamamlandı.');

      print('Eski koleksiyonlar siliniyor...');
      await deleteOldCollections();
      print('Eski koleksiyonlar silindi.');

      print('Yeni yapıya geçiş başlıyor...');
      await migrateToNewStructure(backup);
      print('Yeni yapıya geçiş tamamlandı.');

      print('Migrasyon başarıyla tamamlandı!');
    } catch (e) {
      print('Migrasyon sırasında hata oluştu: $e');
      rethrow;
    }
  }
}
