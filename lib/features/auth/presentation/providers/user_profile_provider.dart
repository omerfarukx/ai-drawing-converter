import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final userProfileProvider = Provider.autoDispose((ref) {
  final authState = ref.watch(authControllerProvider);
  final database = ref.watch(databaseProvider);

  authState.whenOrNull(
    authenticated: (user) async {
      // Yeni kullanıcı geldiğinde profilini oluştur
      await database.createUserProfile(
        userId: user.id,
        displayName: user.displayName ?? 'Yeni Kullanıcı',
        username: user.username ?? 'user_${user.id.substring(0, 8)}',
        email: user.email,
        photoURL: user.photoURL,
        bio: user.bio,
      );
    },
  );

  return null;
});
