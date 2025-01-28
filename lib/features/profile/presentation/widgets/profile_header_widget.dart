import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/services/social_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../drawing/presentation/providers/ai_credits_provider.dart';
import '../providers/social_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/models/auth_state.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../../core/providers/database_provider.dart';

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
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2C1B47),
            const Color(0xFF0B1221),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Kredi Bilgisi
          if (widget.isCurrentUser)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.stars_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$credits Kredi',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Avatar
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF533483).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Hero(
                  tag: 'profile_${widget.profile.id}',
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    backgroundImage: widget.profile.photoURL != null
                        ? NetworkImage(widget.profile.photoURL!)
                        : null,
                    child: widget.profile.photoURL == null
                        ? Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white.withOpacity(0.7),
                          )
                        : null,
                  ),
                ),
              ),
              if (widget.isCurrentUser)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () => _handleImageUpload(context, ref),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF533483),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_a_photo,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

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
                    letterSpacing: 0.5,
                  ),
                ),
                if (widget.isCurrentUser) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),

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
                    color: Colors.white.withOpacity(0.7),
                    letterSpacing: 0.5,
                  ),
                ),
                if (widget.isCurrentUser) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.edit,
                    size: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Bio
          GestureDetector(
            onTap: widget.isCurrentUser
                ? () => _handleBioEdit(context, ref)
                : null,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
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
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  if (widget.isCurrentUser) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Takip Et / Takibi Bırak Butonu
          if (!widget.isCurrentUser) ...[
            const SizedBox(height: 20),
            authState.map(
              initial: (_) => const SizedBox(),
              loading: (_) => const CircularProgressIndicator(),
              authenticated: (state) => MouseRegion(
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                child: Container(
                  width: 200,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.profile.isFollowing
                          ? _isHovered
                              ? [
                                  Colors.red.withOpacity(0.5),
                                  Colors.red.withOpacity(0.3),
                                ]
                              : [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                ]
                          : [
                              const Color(0xFF533483),
                              const Color(0xFF16213E),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () =>
                          _handleFollowAction(context, ref, state.user.id),
                      borderRadius: BorderRadius.circular(22),
                      child: Center(
                        child: Text(
                          widget.profile.isFollowing
                              ? _isHovered
                                  ? 'Takibi Bırak'
                                  : 'Takip Ediliyor'
                              : 'Takip Et',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              unauthenticated: (_) => const SizedBox(),
              error: (state) => Text(
                'Hata: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
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
      final database = ref.read(databaseProvider);

      // Takip/takipten çıkma işlemini yap
      await database.followUser(
        followerId: currentUserId,
        followedId: widget.profile.id,
      );

      // Başarılı bildirimi göster
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 16),
              Text(
                widget.profile.isFollowing
                    ? 'Takipten çıkıldı'
                    : 'Takip edilmeye başlandı',
              ),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 16),
              Expanded(child: Text('Hata: $e')),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleImageUpload(BuildContext context, WidgetRef ref) async {
    try {
      // Android 13 ve üzeri için izin kontrolü
      if (Platform.isAndroid) {
        final status = await Permission.photos.request();

        if (status.isDenied) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Galeri izni reddedildi')),
          );
          return;
        }

        if (status.isPermanentlyDenied) {
          if (!context.mounted) return;
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('İzin Gerekli'),
              content: const Text(
                  'Profil fotoğrafı yükleyebilmek için galeri iznine ihtiyacımız var. Ayarlardan izin verebilirsiniz.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    openAppSettings();
                  },
                  child: const Text('Ayarlara Git'),
                ),
              ],
            ),
          );
          return;
        }
      }

      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      if (!context.mounted) return;

      // Yükleme başladı bildirimi
      final loadingController = ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(width: 16),
              Text('Fotoğraf yükleniyor...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );

      final storageService = ref.read(storageServiceProvider);
      final database = ref.read(databaseProvider);

      // Fotoğrafı Storage'a yükle
      final imageUrl = await storageService.uploadProfileImage(
        widget.profile.id,
        File(image.path),
      );

      // Loading snackbar'ı kapat
      loadingController.close();

      // Profili güncelle
      await database.createUserProfile(
        userId: widget.profile.id,
        displayName: widget.profile.displayName,
        username: widget.profile.username,
        email: widget.profile.email,
        photoURL: imageUrl,
        bio: widget.profile.bio,
      );

      if (!context.mounted) return;

      // Başarılı bildirimi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 16),
              Text('Profil fotoğrafı güncellendi'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 16),
              Expanded(child: Text('Hata: $e')),
            ],
          ),
          backgroundColor: Colors.red,
        ),
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
