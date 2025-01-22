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

  Future<void> _handleUsernameEdit(BuildContext context, WidgetRef ref) async {
    final TextEditingController controller =
        TextEditingController(text: profile.username);
    final formKey = GlobalKey<FormState>();

    final newUsername = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kullanıcı Adını Düzenle'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Kullanıcı Adı',
              hintText: 'Yeni kullanıcı adını girin',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kullanıcı adı boş olamaz';
              }
              if (value.length < 3) {
                return 'Kullanıcı adı en az 3 karakter olmalı';
              }
              if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                return 'Sadece harf, rakam ve alt çizgi kullanılabilir';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, controller.text);
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (newUsername != null && newUsername != profile.username) {
      try {
        final socialService = ref.read(socialServiceProvider);
        await socialService.updateUsername(newUsername);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kullanıcı adı güncellendi')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  // İsim düzenleme işleyicisi
  Future<void> _handleDisplayNameEdit(
      BuildContext context, WidgetRef ref) async {
    final TextEditingController controller =
        TextEditingController(text: profile.displayName);
    final formKey = GlobalKey<FormState>();

    final newDisplayName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İsmi Düzenle'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'İsim',
              hintText: 'Yeni isminizi girin',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'İsim boş olamaz';
              }
              if (value.length < 2) {
                return 'İsim en az 2 karakter olmalı';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, controller.text);
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (newDisplayName != null && newDisplayName != profile.displayName) {
      try {
        final socialService = ref.read(socialServiceProvider);
        await socialService.updateProfile(displayName: newDisplayName);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İsim güncellendi')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  // Bio düzenleme işleyicisi
  Future<void> _handleBioEdit(BuildContext context, WidgetRef ref) async {
    final TextEditingController controller =
        TextEditingController(text: profile.bio);
    final formKey = GlobalKey<FormState>();

    final newBio = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bio Düzenle'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            maxLines: 3,
            maxLength: 150,
            decoration: const InputDecoration(
              labelText: 'Bio',
              hintText: 'Kendinizi kısaca tanıtın',
            ),
            validator: (value) {
              if (value != null && value.length > 150) {
                return 'Bio en fazla 150 karakter olabilir';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(
                    context, controller.text.isEmpty ? null : controller.text);
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (newBio != profile.bio) {
      try {
        final socialService = ref.read(socialServiceProvider);
        await socialService.updateProfile(bio: newBio);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bio güncellendi')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
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
          GestureDetector(
            onTap: () => _handleDisplayNameEdit(context, ref),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  profile.displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.edit,
                  size: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Kullanıcı adı
          GestureDetector(
            onTap: () => _handleUsernameEdit(context, ref),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '@${profile.username}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.edit,
                  size: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ],
            ),
          ),

          // Bio
          GestureDetector(
            onTap: () => _handleBioEdit(context, ref),
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      profile.bio ?? 'Bio ekle',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: profile.bio != null
                            ? Colors.white.withOpacity(0.9)
                            : Colors.white.withOpacity(0.5),
                        fontStyle: profile.bio != null
                            ? FontStyle.normal
                            : FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.edit,
                    size: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
