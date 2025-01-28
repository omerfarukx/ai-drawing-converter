import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kullanıcı işlemleri
  Future<void> createUserProfile({
    required String userId,
    required String displayName,
    required String username,
    required String email,
    String? photoURL,
    String? bio,
  }) async {
    final userDoc = _firestore.collection('users').doc(userId);

    // Ana kullanıcı dokümanı
    await userDoc.set({
      'displayName': displayName,
      'username': username,
      'email': email,
      'photoURL': photoURL,
      'bio': bio,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Kullanıcı istatistikleri
    await userDoc.collection('stats').doc('profile').set({
      'drawingsCount': 0,
      'followersCount': 0,
      'followingCount': 0,
      'likesCount': 0,
      'savesCount': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Çizim işlemleri
  Future<String> createDrawing({
    required String userId,
    required String title,
    required String imageUrl,
  }) async {
    // Ana çizim dokümanı
    final drawingRef = _firestore.collection('drawings').doc();
    await drawingRef.set({
      'userId': userId,
      'title': title,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Çizim istatistikleri
    await drawingRef.collection('stats').doc('interactions').set({
      'likesCount': 0,
      'savesCount': 0,
      'commentsCount': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return drawingRef.id;
  }

  // Beğeni işlemleri
  Future<void> likeDrawing({
    required String drawingId,
    required String userId,
  }) async {
    final drawingRef = _firestore.collection('drawings').doc(drawingId);
    final likeRef = drawingRef.collection('likes').doc(userId);
    final statsRef = drawingRef.collection('stats').doc('interactions');

    // Transaction ile atomik işlem
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

  // Kaydetme işlemleri
  Future<void> saveDrawing({
    required String drawingId,
    required String userId,
  }) async {
    final drawingRef = _firestore.collection('drawings').doc(drawingId);
    final saveRef = drawingRef.collection('saves').doc(userId);
    final statsRef = drawingRef.collection('stats').doc('interactions');

    // Transaction ile atomik işlem
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

  // Takip işlemleri
  Future<void> followUser({
    required String followerId,
    required String followedId,
  }) async {
    final followerRef = _firestore.collection('users').doc(followerId);
    final followedRef = _firestore.collection('users').doc(followedId);

    final followerStatsRef = followerRef.collection('stats').doc('profile');
    final followedStatsRef = followedRef.collection('stats').doc('profile');

    // Transaction ile atomik işlem
    await _firestore.runTransaction((transaction) async {
      // Takip durumunu kontrol et
      final followDoc = await transaction
          .get(followerRef.collection('following').doc(followedId));

      if (followDoc.exists) {
        // Takibi kaldır
        transaction.delete(followerRef.collection('following').doc(followedId));
        transaction.delete(followedRef.collection('followers').doc(followerId));

        transaction.update(followerStatsRef, {
          'followingCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        transaction.update(followedStatsRef, {
          'followersCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Takip et
        transaction.set(
          followerRef.collection('following').doc(followedId),
          {'createdAt': FieldValue.serverTimestamp()},
        );

        transaction.set(
          followedRef.collection('followers').doc(followerId),
          {'createdAt': FieldValue.serverTimestamp()},
        );

        transaction.update(followerStatsRef, {
          'followingCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        transaction.update(followedStatsRef, {
          'followersCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }
}
