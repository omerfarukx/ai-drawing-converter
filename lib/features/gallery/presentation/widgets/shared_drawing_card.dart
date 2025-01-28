import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/models/shared_drawing.dart';
import '../pages/shared_drawing_detail_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/services/drawing_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Çizim güncellemelerini dinlemek için StreamProvider
final sharedDrawingStreamProvider =
    StreamProvider.family<SharedDrawing, String>((ref, drawingId) {
  final firestore = FirebaseFirestore.instance;
  return firestore
      .collection('shared_drawings')
      .doc(drawingId)
      .snapshots()
      .asyncMap((doc) async {
    if (!doc.exists) throw Exception('Çizim bulunamadı');

    final data = doc.data()!;
    final authState = ref.read(authControllerProvider);
    final currentUserId = authState.maybeMap(
      authenticated: (state) => state.user.id,
      orElse: () => null,
    );

    // İstatistikleri al
    final statsDoc =
        await doc.reference.collection('stats').doc('interactions').get();
    if (statsDoc.exists) {
      final stats = statsDoc.data()!;
      data['likesCount'] = stats['likesCount'];
      data['savesCount'] = stats['savesCount'];
      data['commentsCount'] = stats['commentsCount'];
    }

    // Beğeni ve kaydetme durumlarını kontrol et
    if (currentUserId != null) {
      final likeDoc =
          await doc.reference.collection('likes').doc(currentUserId).get();
      final saveDoc =
          await doc.reference.collection('saves').doc(currentUserId).get();
      data['isLiked'] = likeDoc.exists;
      data['isSaved'] = saveDoc.exists;
    }

    return SharedDrawing.fromFirestore(data, doc.id);
  });
});

class SharedDrawingCard extends ConsumerWidget {
  final SharedDrawing drawing;

  const SharedDrawingCard({
    super.key,
    required this.drawing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawingStream = ref.watch(sharedDrawingStreamProvider(drawing.id));

    return drawingStream.when(
      data: (updatedDrawing) => GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SharedDrawingDetailPage(drawing: updatedDrawing),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF16213E), Color(0xFF1A1A2E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'drawing_${updatedDrawing.id}',
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: updatedDrawing.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 300),
                    fadeOutDuration: const Duration(milliseconds: 300),
                    memCacheWidth: 640,
                    memCacheHeight: 360,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: const Color(0xFF1A1A2E),
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF533483),
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      print(
                          'Debug: Resim yükleme hatası - URL: $url, Hata: $error');
                      return Container(
                        height: 200,
                        color: const Color(0xFF1A1A2E),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.white,
                                size: 32,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Resim yüklenemedi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    imageBuilder: (context, imageProvider) {
                      print('Debug: Resim başarıyla yüklendi');
                      return Material(
                        // Hero animasyonu için Material widget'ı ekle
                        type: MaterialType.transparency,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Hero(
                          tag:
                              'shared_drawing_profile_${updatedDrawing.userId}_${updatedDrawing.id}',
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: updatedDrawing.userPhotoURL != null
                                ? NetworkImage(updatedDrawing.userPhotoURL!)
                                : null,
                            child: updatedDrawing.userPhotoURL == null
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 24,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            updatedDrawing.userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      updatedDrawing.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        InkWell(
                          onTap: () => _handleLike(context, ref),
                          child: Row(
                            children: [
                              Icon(
                                updatedDrawing.isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: updatedDrawing.isLiked
                                    ? Colors.red.withOpacity(0.8)
                                    : Colors.white.withOpacity(0.7),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${updatedDrawing.likesCount} beğeni',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () => _handleSave(context, ref),
                          child: Row(
                            children: [
                              Icon(
                                updatedDrawing.isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: updatedDrawing.isSaved
                                    ? Colors.blue.withOpacity(0.8)
                                    : Colors.white.withOpacity(0.7),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${updatedDrawing.savesCount} kaydetme',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () => _handleComment(context),
                          child: Row(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.white.withOpacity(0.7),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${updatedDrawing.commentsCount} yorum',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('Hata: $error'),
      ),
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

  void _handleComment(BuildContext context) {
    // TODO: Yorum özelliği eklenecek
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yorum özelliği yakında eklenecek')),
    );
  }
}
