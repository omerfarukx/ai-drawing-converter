import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile_model.dart';

final socialServiceProvider = Provider((ref) => SocialService());

class SocialService {
  // Kullanıcı profili getirme
  Future<UserProfile> getUserProfile(String userId) async {
    // TODO: API entegrasyonu eklenecek
    return const UserProfile(
      id: '1',
      username: 'test_user',
      displayName: 'Test User',
    );
  }

  // Kullanıcıyı takip etme
  Future<void> followUser(String userId) async {
    // TODO: API entegrasyonu eklenecek
  }

  // Kullanıcıyı takipten çıkarma
  Future<void> unfollowUser(String userId) async {
    // TODO: API entegrasyonu eklenecek
  }

  // Takipçileri getirme
  Future<List<UserProfile>> getFollowers(String userId) async {
    // TODO: API entegrasyonu eklenecek
    return [];
  }

  // Takip edilenleri getirme
  Future<List<UserProfile>> getFollowing(String userId) async {
    // TODO: API entegrasyonu eklenecek
    return [];
  }
}
