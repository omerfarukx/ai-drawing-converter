import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_profile_model.dart';
import '../../domain/services/social_service.dart';

final currentUserProfileProvider = FutureProvider<UserProfile>((ref) async {
  final socialService = ref.read(socialServiceProvider);
  return socialService.getUserProfile('current_user');
});

final userProfileProvider =
    FutureProvider.family<UserProfile, String>((ref, userId) async {
  final socialService = ref.read(socialServiceProvider);
  return socialService.getUserProfile(userId);
});

final followersProvider =
    FutureProvider.family<List<UserProfile>, String>((ref, userId) async {
  final socialService = ref.read(socialServiceProvider);
  return socialService.getFollowers(userId);
});

final followingProvider =
    FutureProvider.family<List<UserProfile>, String>((ref, userId) async {
  final socialService = ref.read(socialServiceProvider);
  return socialService.getFollowing(userId);
});
