import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../models/user_profile_model.dart';
import 'package:uuid/uuid.dart';

final socialServiceProvider = Provider((ref) => SocialService(
      ref.read(authServiceProvider),
      ref.read(firestoreServiceProvider),
    ));

class SocialService {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  SocialService(this._authService, this._firestoreService);

  String _generateUsername() {
    // 8 karakterlik rastgele bir kullanıcı adı oluştur
    const uuid = Uuid();
    final randomString = uuid.v4().substring(0, 8);
    return 'user_$randomString';
  }

  // Kullanıcı arama
  Future<List<UserProfile>> searchUsers(String query) async {
    try {
      return await _firestoreService.searchUsers(query);
    } catch (e) {
      throw 'Kullanıcılar aranamadı: $e';
    }
  }

  // Kullanıcı profili getirme
  Future<UserProfile> getUserProfile(String userId) async {
    try {
      if (userId == 'current_user') {
        userId = _authService.currentUser?.uid ?? '';
      }

      final profile = await _firestoreService.getUserProfile(userId);
      if (profile != null) {
        return profile;
      }

      // Profil bulunamazsa yeni profil oluştur
      final newProfile = UserProfile.defaultProfile(
        id: userId,
        username: _generateUsername(),
      );

      await _firestoreService.updateUserProfile(newProfile);
      return newProfile;
    } catch (e) {
      throw 'Profil alınamadı: $e';
    }
  }

  // Kullanıcı adı güncelleme
  Future<void> updateUsername(String newUsername) async {
    try {
      final currentUserId = _authService.currentUser?.uid;
      if (currentUserId == null) throw 'Oturum açmanız gerekiyor';

      // Kullanıcı adının benzersiz olup olmadığını kontrol et
      final isUsernameTaken =
          await _firestoreService.isUsernameTaken(newUsername);
      if (isUsernameTaken) {
        throw 'Bu kullanıcı adı zaten kullanılıyor';
      }

      await updateProfile(username: newUsername);
    } catch (e) {
      throw 'Kullanıcı adı güncellenemedi: $e';
    }
  }

  // Kullanıcıyı takip etme
  Future<void> followUser(String userId) async {
    try {
      final currentUserId = _authService.currentUser?.uid;
      if (currentUserId == null) throw 'Oturum açmanız gerekiyor';
      if (currentUserId == userId) throw 'Kendinizi takip edemezsiniz';

      await _firestoreService.followUser(currentUserId, userId);
    } catch (e) {
      throw 'Takip işlemi başarısız: $e';
    }
  }

  // Kullanıcıyı takipten çıkarma
  Future<void> unfollowUser(String userId) async {
    try {
      final currentUserId = _authService.currentUser?.uid;
      if (currentUserId == null) throw 'Oturum açmanız gerekiyor';

      await _firestoreService.unfollowUser(currentUserId, userId);
    } catch (e) {
      throw 'Takipten çıkarma işlemi başarısız: $e';
    }
  }

  // Takipçileri getirme
  Future<List<UserProfile>> getFollowers(String userId) async {
    try {
      return await _firestoreService.getFollowers(userId);
    } catch (e) {
      throw 'Takipçiler alınamadı: $e';
    }
  }

  // Takip edilenleri getirme
  Future<List<UserProfile>> getFollowing(String userId) async {
    try {
      return await _firestoreService.getFollowing(userId);
    } catch (e) {
      throw 'Takip edilenler alınamadı: $e';
    }
  }

  // Profil güncelleme
  Future<void> updateProfile({
    String? displayName,
    String? username,
    String? bio,
    String? photoUrl,
  }) async {
    try {
      final currentUserId = _authService.currentUser?.uid;
      if (currentUserId == null) throw 'Oturum açmanız gerekiyor';

      final currentProfile = await getUserProfile(currentUserId);
      final updatedProfile = UserProfile(
        id: currentUserId,
        username: username ?? currentProfile.username,
        displayName: displayName ?? currentProfile.displayName,
        bio: bio ?? currentProfile.bio,
        photoUrl: photoUrl ?? currentProfile.photoUrl,
        followersCount: currentProfile.followersCount,
        followingCount: currentProfile.followingCount,
        drawingsCount: currentProfile.drawingsCount,
        followers: currentProfile.followers,
        following: currentProfile.following,
      );

      await _firestoreService.updateUserProfile(updatedProfile);
    } catch (e) {
      throw 'Profil güncellenemedi: $e';
    }
  }
}
