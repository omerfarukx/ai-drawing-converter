import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/models/user_profile_model.dart';
import '../../domain/services/social_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../drawing/presentation/providers/ai_credits_provider.dart';
import '../providers/social_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/models/auth_state.dart';

class ProfileHeaderWidget extends ConsumerStatefulWidget {
  final UserProfile profile;
  final bool isCurrentUser;

  const ProfileHeaderWidget({
    super.key,
    required this.profile,
    this.isCurrentUser = false,
  });

  @override
  ConsumerState<ProfileHeaderWidget> createState() =>
      _ProfileHeaderWidgetState();
}

class _ProfileHeaderWidgetState extends ConsumerState<ProfileHeaderWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final credits = ref.watch(aiCreditsProvider);
    final authState = ref.watch(authControllerProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Kredi Bilgisi
          if (widget.isCurrentUser)
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
                backgroundImage: widget.profile.photoUrl != null
                    ? NetworkImage(widget.profile.photoUrl!)
                    : null,
                child: widget.profile.photoUrl == null
                    ? const Icon(Icons.person,
                        size: 50, color: Colors.deepPurple)
                    : null,
              ),
              if (widget.isCurrentUser)
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
            onTap: widget.isCurrentUser
                ? () => _handleDisplayNameEdit(context, ref)
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.profile.displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (widget.isCurrentUser) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.edit,
                    size: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Kullanıcı adı
          GestureDetector(
            onTap: widget.isCurrentUser
                ? () => _handleUsernameEdit(context, ref)
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '@${widget.profile.username}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                if (widget.isCurrentUser) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.edit,
                    size: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Bio
          GestureDetector(
            onTap: widget.isCurrentUser
                ? () => _handleBioEdit(context, ref)
                : null,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      widget.profile.bio ?? 'Bio ekle',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.profile.bio != null
                            ? Colors.white.withOpacity(0.9)
                            : Colors.white.withOpacity(0.5),
                        fontStyle: widget.profile.bio != null
                            ? FontStyle.normal
                            : FontStyle.italic,
                      ),
                    ),
                  ),
                  if (widget.isCurrentUser) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.edit,
                      size: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Takip Et / Takibi Bırak Butonu
          if (!widget.isCurrentUser) ...[
            const SizedBox(height: 16),
            authState.map(
              initial: (_) => const SizedBox(),
              loading: (_) => const Center(child: CircularProgressIndicator()),
              authenticated: (state) => SizedBox(
                width: 200,
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isHovered = true),
                  onExit: (_) => setState(() => _isHovered = false),
                  child: ElevatedButton(
                    onPressed: () =>
                        _handleFollowAction(context, ref, state.user.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.profile.isFollowing
                          ? _isHovered
                              ? Colors.red.withOpacity(0.1)
                              : Colors.white.withOpacity(0.1)
                          : Colors.white,
                      foregroundColor: widget.profile.isFollowing
                          ? _isHovered
                              ? Colors.red
                              : Colors.white
                          : Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      widget.profile.isFollowing
                          ? _isHovered
                              ? 'Takibi Bırak'
                              : 'Takip Ediliyor'
                          : 'Takip Et',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              unauthenticated: (_) => const SizedBox(),
              error: (state) => Text('Hata: ${state.message}'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleFollowAction(
    BuildContext context,
    WidgetRef ref,
    String currentUserId,
  ) async {
    try {
      final socialService = ref.read(socialServiceProvider);

      if (widget.profile.isFollowing) {
        await socialService.unfollowUser(widget.profile.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Takipten çıkıldı')),
        );
      } else {
        await socialService.followUser(widget.profile.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Takip edildi')),
        );
      }

      // Profilleri yenile
      ref.invalidate(userProfileProvider(widget.profile.id));
      ref.invalidate(currentUserProfileProvider);

      // Takipçi ve takip edilen listelerini yenile
      ref.invalidate(followersProvider(widget.profile.id));
      ref.invalidate(followingProvider(currentUserId));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

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
        widget.profile.id,
        File(image.path),
      );

      // Profili güncelle
      await socialService.updateProfile(photoUrl: imageUrl);

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

  Future<void> _handleDisplayNameEdit(
      BuildContext context, WidgetRef ref) async {
    final TextEditingController controller =
        TextEditingController(text: widget.profile.displayName);
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

    if (newDisplayName != null &&
        newDisplayName != widget.profile.displayName) {
      try {
        final socialService = ref.read(socialServiceProvider);
        await socialService.updateProfile(displayName: newDisplayName);
        ref.invalidate(currentUserProfileProvider);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  Future<void> _handleUsernameEdit(BuildContext context, WidgetRef ref) async {
    final TextEditingController controller =
        TextEditingController(text: widget.profile.username);
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

    if (newUsername != null && newUsername != widget.profile.username) {
      try {
        final socialService = ref.read(socialServiceProvider);
        await socialService.updateUsername(newUsername);
        ref.invalidate(currentUserProfileProvider);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  Future<void> _handleBioEdit(BuildContext context, WidgetRef ref) async {
    final TextEditingController controller =
        TextEditingController(text: widget.profile.bio);
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

    if (newBio != widget.profile.bio) {
      try {
        final socialService = ref.read(socialServiceProvider);
        await socialService.updateProfile(bio: newBio);
        ref.invalidate(currentUserProfileProvider);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }
}
