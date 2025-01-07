import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../gallery/domain/models/drawing.dart';
import '../../../gallery/domain/repositories/gallery_repository.dart';
import '../providers/ai_provider.dart';

class AiResultDialog extends ConsumerWidget {
  final String imageUrl;

  const AiResultDialog({
    super.key,
    required this.imageUrl,
  });

  Future<void> _saveImage(BuildContext context) async {
    try {
      // Base64'ü decode et
      final bytes = base64Decode(imageUrl);

      // Uygulama dökümanlar dizinini al
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/images');

      // Dizin yoksa oluştur
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Dosya adı oluştur
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${imagesDir.path}/image_$timestamp.png';

      // Dosyayı kaydet
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Drawing nesnesini oluştur ve kaydet
      final drawing = Drawing(
        id: const Uuid().v4(),
        path: filePath,
        createdAt: DateTime.now(),
        category: 'AI Generated',
        title: 'AI Drawing',
      );

      // GalleryRepository'ye kaydet
      final galleryRepository = GalleryRepository();
      await galleryRepository.saveDrawing(drawing);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Görsel başarıyla kaydedildi'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Görsel kaydetme hatası: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Görsel kaydedilemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  base64Decode(imageUrl),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('Görüntü yükleme hatası: $error');
                    return const Center(
                      child: Icon(Icons.error, color: Colors.red, size: 48),
                    );
                  },
                ),
              ),
            ),
          ),
          ButtonBar(
            children: [
              TextButton(
                onPressed: () {
                  ref.read(aiProvider.notifier).clearImage();
                  Navigator.pop(context);
                },
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => _saveImage(context),
                child: Text(l10n.save),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
