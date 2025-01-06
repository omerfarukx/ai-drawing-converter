import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/ai_provider.dart';

class AIResultDialog extends ConsumerWidget {
  final String imageUrl;

  const AIResultDialog({
    super.key,
    required this.imageUrl,
  });

  Future<void> _shareImage(BuildContext context) async {
    try {
      // Base64'ü decode et
      final imageBytes = base64Decode(imageUrl);

      // Geçici dosya oluştur
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/ai_image_$timestamp.png');

      // Dosyaya yaz
      await file.writeAsBytes(imageBytes);

      if (!await file.exists()) {
        throw Exception('Dosya oluşturulamadı');
      }

      // Paylaş
      await Share.shareFiles(
        [file.path],
        text: 'Yapay Zeka ile oluşturulmuş çizimim!',
        mimeTypes: ['image/png'],
      );
    } catch (e) {
      debugPrint('Share error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Paylaşım hatası: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.memory(
              base64Decode(imageUrl),
              fit: BoxFit.contain,
              width: 300,
              height: 300,
            ),
          ),
          ButtonBar(
            children: [
              TextButton(
                onPressed: () {
                  ref.read(aiProvider.notifier).clearImage();
                  Navigator.of(context).pop();
                },
                child: const Text('Kapat'),
              ),
              IconButton(
                onPressed: () => _shareImage(context),
                icon: const Icon(Icons.share),
                tooltip: 'Paylaş',
              ),
              FilledButton(
                onPressed: () {
                  // TODO: Save image
                  Navigator.of(context).pop();
                },
                child: const Text('Kaydet'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
