import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile_model.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../services/social_service.dart';

final currentUserProfileProvider = FutureProvider<UserProfile>((ref) async {
  final authState = ref.watch(authControllerProvider);
  final socialService = ref.read(socialServiceProvider);

  return authState.map(
    initial: (_) => throw Exception('Kullanıcı oturumu başlatılmadı'),
    loading: (_) => throw Exception('Kullanıcı oturumu yükleniyor'),
    authenticated: (state) async {
      return socialService.getUserProfile('current_user');
    },
    unauthenticated: (_) => throw Exception('Kullanıcı oturumu açık değil'),
    error: (state) => throw Exception(state.message),
  );
});

final userProfileProvider =
    FutureProvider.family<UserProfile, String>((ref, userId) async {
  final authState = ref.watch(authControllerProvider);
  final socialService = ref.read(socialServiceProvider);

  return authState.map(
    initial: (_) async {
      return socialService.getUserProfile(userId);
    },
    loading: (_) async {
      return socialService.getUserProfile(userId);
    },
    authenticated: (state) async {
      return socialService.getUserProfile(userId);
    },
    unauthenticated: (_) async {
      return socialService.getUserProfile(userId);
    },
    error: (_) async {
      return socialService.getUserProfile(userId);
    },
  );
});
