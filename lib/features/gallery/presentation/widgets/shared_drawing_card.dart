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
    StreamProvider.family.autoDispose<SharedDrawing, String>((ref, drawingId) {
  print('Debug: Stream başlatıldı - drawingId: $drawingId');
  final firestore = FirebaseFirestore.instance;
  final authState = ref.read(authControllerProvider);
  final currentUserId = authState.maybeMap(
    authenticated: (state) => state.user.id,
    orElse: () => null,
  );

  // Ana çizim dökümanını ve alt koleksiyonları dinle
  return firestore
      .collection('shared_drawings')
      .doc(drawingId)
      .snapshots()
      .asyncMap((doc) async {
    if (!doc.exists) {
      throw Exception('Çizim bulunamadı');
    }

    final data = doc.data()!;

    // Beğeni durumunu kontrol et
    if (currentUserId != null) {
      final likeDoc =
          await doc.reference.collection('likes').doc(currentUserId).get();

      final saveDoc =
          await doc.reference.collection('saves').doc(currentUserId).get();

      data['isLiked'] = likeDoc.exists;
      data['isSaved'] = saveDoc.exists;
    } else {
      data['isLiked'] = false;
      data['isSaved'] = false;
    }

    // Beğeni ve kaydetme sayılarını al
    data['likesCount'] = data['likesCount'] ?? 0;
    data['savesCount'] = data['savesCount'] ?? 0;

    return SharedDrawing.fromFirestore(data, doc.id);
  }).handleError((error) {
    print('Debug: Stream hatası - $error');
    throw error;
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
    // Stream'i sadece gerektiğinde dinle
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
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CachedNetworkImage(
                      imageUrl: updatedDrawing.imageUrl,
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(milliseconds: 300),
                      fadeOutDuration: const Duration(milliseconds: 300),
                      memCacheWidth: 640,
                      memCacheHeight: 360,
                      placeholder: (context, url) => Container(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => _handleLike(context, ref),
                              child: Icon(
                                updatedDrawing.isLiked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_outline_rounded,
                                color: updatedDrawing.isLiked
                                    ? Colors.red
                                    : Colors.white.withOpacity(0.7),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${updatedDrawing.likesCount}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () => _handleSave(context, ref),
                              child: Icon(
                                updatedDrawing.isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: updatedDrawing.isSaved
                                    ? const Color(0xFF533483)
                                    : Colors.white.withOpacity(0.7),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${updatedDrawing.savesCount}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                            // Kullanıcının kendi paylaşımıysa silme butonu göster
                            if (updatedDrawing.userId ==
                                ref.read(authControllerProvider).maybeMap(
                                      authenticated: (state) => state.user.id,
                                      orElse: () => null,
                                    )) ...[
                              const SizedBox(width: 16),
                              GestureDetector(
                                onTap: () => _handleDelete(context, ref),
                                child: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red.withOpacity(0.7),
                                  size: 24,
                                ),
                              ),
                            ],
                          ],
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
      loading: () => Container(
        height: 300,
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
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF533483),
          ),
        ),
      ),
      error: (error, stack) => Container(
        height: 300,
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
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Hata: ${error.toString()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLike(BuildContext context, WidgetRef ref) async {
    print('Debug: Beğeni butonuna basıldı');

    try {
      final authState = ref.read(authControllerProvider);
      final userId = authState.maybeMap(
        authenticated: (state) => state.user.id,
        orElse: () => null,
      );

      print('Debug: Kullanıcı durumu - userId: $userId');

      if (userId == null) {
        print('Debug: Kullanıcı giriş yapmamış');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Beğenmek için giriş yapmalısınız'),
            backgroundColor: Color(0xFF533483),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // UI'ı hemen güncelle
      ref.invalidate(sharedDrawingStreamProvider(drawing.id));

      print('Debug: DrawingService alınıyor');
      final drawingService = ref.read(drawingServiceProvider);

      print('Debug: toggleLike çağrılıyor - drawingId: ${drawing.id}');
      await drawingService.toggleLike(drawing.id, userId);

      print('Debug: Beğeni işlemi başarılı');

      // Stream'i yenile
      ref.invalidate(sharedDrawingStreamProvider(drawing.id));
    } catch (e) {
      print('Debug: Beğeni işlemi hatası - $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Beğeni işlemi başarısız oldu: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleSave(BuildContext context, WidgetRef ref) async {
    try {
      final authState = ref.read(authControllerProvider);
      final userId = authState.maybeMap(
        authenticated: (state) => state.user.id,
        orElse: () => null,
      );

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kaydetmek için giriş yapmalısınız'),
            backgroundColor: Color(0xFF533483),
          ),
        );
        return;
      }

      final drawingService = ref.read(drawingServiceProvider);
      await drawingService.toggleSave(drawing.id, userId);
      print('Debug: Kaydetme işlemi başarılı');
    } catch (e) {
      print('Debug: Kaydetme işlemi hatası - $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kaydetme işlemi başarısız oldu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleComment(BuildContext context) {
    // TODO: Yorum özelliği eklenecek
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yorum özelliği yakında eklenecek')),
    );
  }

  // Silme işlemi için yeni fonksiyon ekle
  void _handleDelete(BuildContext context, WidgetRef ref) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          'Çizimi Sil',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Bu çizimi silmek istediğinize emin misiniz?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'İptal',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sil',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      try {
        final drawingService = ref.read(drawingServiceProvider);
        await drawingService.deleteSharedDrawing(drawing.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Çizim başarıyla silindi')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Çizim silinirken bir hata oluştu: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
