import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/shared_drawing.dart';
import '../../domain/services/drawing_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class DrawingCard extends ConsumerWidget {
  final SharedDrawing drawing;
  final VoidCallback? onTap;

  const DrawingCard({
    super.key,
    required this.drawing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Çizim Görseli
            AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                drawing.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),

            // Kullanıcı Bilgileri
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: drawing.userPhotoURL != null
                        ? NetworkImage(drawing.userPhotoURL!)
                        : null,
                    child: drawing.userPhotoURL == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          drawing.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          drawing.userName,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // İstatistikler
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    context,
                    Icons.favorite,
                    drawing.likesCount,
                    'Beğeni',
                    drawing.isLiked ? Colors.red : null,
                  ),
                  _buildStatItem(
                    context,
                    Icons.bookmark,
                    drawing.savesCount,
                    'Kaydetme',
                    drawing.isSaved ? Colors.blue : null,
                  ),
                  _buildStatItem(
                    context,
                    Icons.comment,
                    drawing.commentsCount,
                    'Yorum',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    int value,
    String label, [
    Color? color,
  ]) {
    return Column(
      children: [
        Icon(
          icon,
          color: color ?? Theme.of(context).iconTheme.color,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  void _handleLike(BuildContext context, WidgetRef ref) async {
    try {
      final authState = ref.read(authControllerProvider);

      final isAuthenticated = authState.maybeMap(
        authenticated: (_) => true,
        orElse: () => false,
      );

      if (!isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Beğenmek için giriş yapmalısınız')),
        );
        return;
      }

      final userId = authState.maybeMap(
        authenticated: (state) => state.user.id,
        orElse: () => throw Exception('User not authenticated'),
      );

      final drawingService = ref.read(drawingServiceProvider);
      await drawingService.toggleLike(drawing.id, userId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  void _handleSave(BuildContext context, WidgetRef ref) async {
    try {
      final authState = ref.read(authControllerProvider);

      final isAuthenticated = authState.maybeMap(
        authenticated: (_) => true,
        orElse: () => false,
      );

      if (!isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kaydetmek için giriş yapmalısınız')),
        );
        return;
      }

      final userId = authState.maybeMap(
        authenticated: (state) => state.user.id,
        orElse: () => throw Exception('User not authenticated'),
      );

      final drawingService = ref.read(drawingServiceProvider);
      await drawingService.toggleSave(drawing.id, userId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}
