import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/models/user_profile_model.dart';
import '../../domain/services/social_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../drawing/presentation/providers/ai_credits_provider.dart';

class ProfileHeaderWidget extends ConsumerWidget {
  final UserProfile profile;

  const ProfileHeaderWidget({
    super.key,
    required this.profile,
  });

  Future<void> _handleImageUpload(BuildContext context, WidgetRef ref) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      final storageService = ref.read(storageServiceProvider);
      final socialService = ref.read(socialServiceProvider);

      // Yükleme başladı bildirimi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotoğraf yükleniyor...')),
      );

      // Fotoğrafı Storage'a yükle
      final imageUrl = await storageService.uploadProfileImage(
        profile.id,
        File(image.path),
      );

      // Profili güncelle
      await socialService.updateProfile(profileImage: imageUrl);

      // Başarılı bildirimi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil fotoğrafı güncellendi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credits = ref.watch(aiCreditsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Kredi Bilgisi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.stars_rounded,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '$credits Kredi',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Kredi Al',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: profile.profileImage != null
                    ? NetworkImage(profile.profileImage!)
                    : null,
                child: profile.profileImage == null
                    ? const Icon(Icons.person,
                        size: 50, color: Colors.deepPurple)
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () => _handleImageUpload(context, ref),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_a_photo,
                      color: Colors.deepPurple,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // İsim
          Text(
            profile.displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),

          // Kullanıcı adı
          Text(
            '@${profile.username}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),

          // Bio
          if (profile.bio != null) ...[
            const SizedBox(height: 12),
            Text(
              profile.bio!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
