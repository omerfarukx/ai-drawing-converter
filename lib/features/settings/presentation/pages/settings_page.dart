import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/services/auth_service.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Uygulama'),
          _SettingsItem(
            icon: Icons.language_outlined,
            title: 'Dil',
            subtitle: 'Türkçe',
            onTap: () {
              // TODO: Dil seçimi
            },
          ),
          _SettingsItem(
            icon: Icons.dark_mode_outlined,
            title: 'Tema',
            subtitle: 'Açık',
            onTap: () {
              // TODO: Tema seçimi
            },
          ),
          const _SectionHeader(title: 'Hesap'),
          _SettingsItem(
            icon: Icons.person_outline,
            title: 'Profili Düzenle',
            subtitle: 'İsim, fotoğraf ve bio',
            onTap: () {
              // TODO: Profil düzenleme
            },
          ),
          _SettingsItem(
            icon: Icons.notifications_outlined,
            title: 'Bildirimler',
            subtitle: 'Bildirim tercihleri',
            onTap: () {
              // TODO: Bildirim ayarları
            },
          ),
          const _SectionHeader(title: 'Diğer'),
          _SettingsItem(
            icon: Icons.info_outline,
            title: 'Hakkında',
            subtitle: 'Versiyon 1.0.0',
            onTap: () {
              // TODO: Hakkında sayfası
            },
          ),
          _SettingsItem(
            icon: Icons.help_outline,
            title: 'Yardım',
            subtitle: 'SSS ve destek',
            onTap: () {
              // TODO: Yardım sayfası
            },
          ),
          _SettingsItem(
            icon: Icons.logout,
            title: 'Çıkış Yap',
            subtitle: 'Hesabından çıkış yap',
            onTap: () async {
              final authService = ref.read(authServiceProvider);
              await authService.signOut();
              // TODO: Login sayfasına yönlendir
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.deepPurple,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
