import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../../domain/models/drawing.dart';
import '../../domain/repositories/gallery_repository.dart';

class DrawingDetailPage extends ConsumerWidget {
  final String id;

  const DrawingDetailPage({
    Key? key,
    required this.id,
  }) : super(key: key);

  Future<void> _downloadImage(BuildContext context, String imagePath) async {
    try {
      // Dosyayı oku
      final file = File(imagePath);
      if (!await file.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Görsel bulunamadı')),
          );
        }
        return;
      }

      final bytes = await file.readAsBytes();

      // Galeriye kaydet
      final result = await ImageGallerySaver.saveImage(
        bytes,
        quality: 100,
        name: 'AI_Drawing_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (context.mounted) {
        if (result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Görsel galeriye kaydedildi')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Görsel kaydedilemedi')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Çizim Detayı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final drawing =
                  await ref.read(galleryRepositoryProvider).getDrawingById(id);
              if (drawing != null) {
                if (context.mounted) {
                  await _downloadImage(context, drawing.path);
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Çizimi Sil'),
                  content:
                      const Text('Bu çizimi silmek istediğinize emin misiniz?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('İptal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Sil'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                try {
                  await ref.read(galleryRepositoryProvider).deleteDrawing(id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Çizim silindi'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Hata: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            tooltip: 'Sil',
          ),
        ],
      ),
      body: FutureBuilder<Drawing?>(
        future: ref.read(galleryRepositoryProvider).getDrawingById(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final drawing = snapshot.data;
          if (drawing == null) {
            return const Center(child: Text('Çizim bulunamadı'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.file(
                  File(drawing.path),
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        drawing.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        drawing.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.category),
                          const SizedBox(width: 8),
                          Text(drawing.category),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 8),
                          Text(drawing.createdAt.toString().split(' ')[0]),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
