import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/drawing_point.dart';

class DrawingService {
  static Future<ui.Image?> convertDrawingToImage(
    List<DrawingPoint> points,
    Size size,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Hedef boyutlar (1024x1024)
    const targetSize = Size(1024, 1024);

    // Ölçekleme faktörünü hesapla
    final scale = targetSize.width / size.width;
    canvas.scale(scale);

    // Beyaz arka plan
    final background = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, background);

    // Çizim noktaları
    for (var i = 0; i < points.length - 1; i++) {
      canvas.drawLine(
        points[i].offset,
        points[i + 1].offset,
        points[i].paint,
      );
    }

    final picture = recorder.endRecording();
    return picture.toImage(targetSize.width.toInt(), targetSize.height.toInt());
  }

  static Future<String> saveDrawingToFile(
      List<DrawingPoint> points, Size size) async {
    try {
      final image = await convertDrawingToImage(points, size);
      if (image == null) throw Exception('Çizim görüntüye dönüştürülemedi');

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Görüntü verisi alınamadı');

      final bytes = byteData.buffer.asUint8List();

      // Uygulama dökümanlar dizinini al
      final appDir = await getApplicationDocumentsDirectory();
      final drawingsDir = Directory('${appDir.path}/drawings');

      // Dizin yoksa oluştur
      if (!await drawingsDir.exists()) {
        await drawingsDir.create(recursive: true);
      }

      // Dosya adı oluştur
      final fileName = 'drawing_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${drawingsDir.path}/$fileName';

      // Dosyayı kaydet
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      return filePath;
    } catch (e) {
      throw Exception('Çizim kaydedilemedi: $e');
    }
  }

  static Future<String> getDrawingsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final drawingsDir = Directory('${appDir.path}/drawings');

    if (!await drawingsDir.exists()) {
      await drawingsDir.create(recursive: true);
    }

    return drawingsDir.path;
  }
}
