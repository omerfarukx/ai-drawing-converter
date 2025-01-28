import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/user_profile.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final userProfileStreamProvider =
    StreamProvider.family.autoDispose<UserProfile, String>((ref, userId) {
  final firestore = FirebaseFirestore.instance;

  // Mevcut kullanıcıyı al
  final currentUserId = ref.watch(authControllerProvider).whenOrNull(
        authenticated: (user) => user.id,
      );

  return firestore.collection('users').doc(userId).snapshots().map((doc) {
    if (!doc.exists) {
      throw Exception('Kullanıcı bulunamadı');
    }

    // Ana profil verilerini al
    final data = doc.data()!;

    // İstatistikleri ve takip durumunu al
    return Future.wait([
      // İstatistikleri al
      firestore
          .collection('users')
          .doc(userId)
          .collection('stats')
          .doc('profile')
          .get(),

      // Takip durumunu kontrol et
      if (currentUserId != null && currentUserId != userId)
        firestore
            .collection('users')
            .doc(currentUserId)
            .collection('following')
            .doc(userId)
            .get()
      else
        Future.value(null),
    ]).then((results) {
      final statsDoc = results[0] as DocumentSnapshot;
      final followingDoc = results[1] as DocumentSnapshot?;

      if (!statsDoc.exists) {
        throw Exception('Kullanıcı istatistikleri bulunamadı');
      }

      final stats = statsDoc.data()! as Map<String, dynamic>;

      return UserProfile(
        id: doc.id,
        displayName: data['displayName'] as String,
        username: data['username'] as String,
        email: data['email'] as String,
        photoURL: data['photoURL'] as String?,
        bio: data['bio'] as String?,
        drawingsCount: stats['drawingsCount'] as int,
        followersCount: stats['followersCount'] as int,
        followingCount: stats['followingCount'] as int,
        isFollowing: followingDoc?.exists ?? false,
      );
    });
  }).asyncMap((future) => future);
});
