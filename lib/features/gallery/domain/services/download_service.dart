import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class DownloadService {
  static Future<String> saveImageToGallery(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw Exception('Görsel bulunamadı');
      }

      final result = await ImageGallerySaver.saveFile(imagePath);

      if (result['isSuccess']) {
        return 'Görsel galeriye kaydedildi';
      } else {
        throw Exception('Görsel kaydedilemedi');
      }
    } catch (e) {
      throw Exception('Görsel kaydedilirken hata oluştu: $e');
    }
  }
}
