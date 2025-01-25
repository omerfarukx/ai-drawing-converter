import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/profile/domain/models/user_profile_model.dart';

final firestoreServiceProvider = Provider((ref) => FirestoreService());

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kullanıcı ara
  Future<List<UserProfile>> searchUsers(String query) async {
    try {
      if (query.isEmpty) return [];

      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThan: query + 'z')
          .limit(10)
          .get();

      return querySnapshot.docs
          .map((doc) => UserProfile.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw 'Kullanıcılar aranırken hata oluştu: $e';
    }
  }

  // Kullanıcı adının kullanılıp kullanılmadığını kontrol et
  Future<bool> isUsernameTaken(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw 'Kullanıcı adı kontrolü yapılırken hata oluştu: $e';
    }
  }

  // Kullanıcı profili oluştur/güncelle
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _firestore.collection('users').doc(profile.id).set(
            profile.toJson(),
            SetOptions(merge: true),
          );
    } catch (e) {
      throw 'Kullanıcı profili güncellenirken hata oluştu: $e';
    }
  }

  // Kullanıcı profili getir
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;

      return UserProfile.fromJson(data);
    } catch (e) {
      throw 'Kullanıcı profili alınırken hata oluştu: $e';
    }
  }

  // Kullanıcıyı takip et
  Future<void> followUser(String followerId, String followedId) async {
    try {
      final batch = _firestore.batch();

      // Takip eden kullanıcının following listesine ekle
      final followerRef = _firestore.collection('users').doc(followerId);
      batch.update(followerRef, {
        'following': FieldValue.arrayUnion([followedId]),
        'followingCount': FieldValue.increment(1),
      });

      // Takip edilen kullanıcının followers listesine ekle
      final followedRef = _firestore.collection('users').doc(followedId);
      batch.update(followedRef, {
        'followers': FieldValue.arrayUnion([followerId]),
        'followersCount': FieldValue.increment(1),
      });

      await batch.commit();
    } catch (e) {
      throw 'Kullanıcı takip edilirken hata oluştu: $e';
    }
  }

  // Kullanıcıyı takipten çıkar
  Future<void> unfollowUser(String followerId, String followedId) async {
    try {
      final batch = _firestore.batch();

      // Takip eden kullanıcının following listesinden çıkar
      final followerRef = _firestore.collection('users').doc(followerId);
      batch.update(followerRef, {
        'following': FieldValue.arrayRemove([followedId]),
        'followingCount': FieldValue.increment(-1),
      });

      // Takip edilen kullanıcının followers listesinden çıkar
      final followedRef = _firestore.collection('users').doc(followedId);
      batch.update(followedRef, {
        'followers': FieldValue.arrayRemove([followerId]),
        'followersCount': FieldValue.increment(-1),
      });

      await batch.commit();
    } catch (e) {
      throw 'Kullanıcı takipten çıkarılırken hata oluştu: $e';
    }
  }

  // Takipçileri getir
  Future<List<UserProfile>> getFollowers(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) throw 'Kullanıcı bulunamadı';

      final followers = List<String>.from(userDoc.data()?['followers'] ?? []);
      if (followers.isEmpty) return [];

      final querySnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: followers)
          .get();

      return querySnapshot.docs
          .map((doc) => UserProfile.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw 'Takipçiler alınırken hata oluştu: $e';
    }
  }

  // Takip edilenleri getir
  Future<List<UserProfile>> getFollowing(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) throw 'Kullanıcı bulunamadı';

      final following = List<String>.from(userDoc.data()?['following'] ?? []);
      if (following.isEmpty) return [];

      final querySnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: following)
          .get();

      return querySnapshot.docs
          .map((doc) => UserProfile.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw 'Takip edilenler alınırken hata oluştu: $e';
    }
  }
}
