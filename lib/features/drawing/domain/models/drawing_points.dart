import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'drawing_point.dart';

class DrawingPoints {
  final List<DrawingPoint> points;
  final Paint currentPaint;

  const DrawingPoints({
    required this.points,
    required this.currentPaint,
  });

  Future<Uint8List> toImage() async {
    if (points.isEmpty) {
      throw Exception('No points to convert to image');
    }

    // Hedef boyut (SDXL için)
    const targetSize = Size(1024, 1024);

    // Recorder oluştur
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Arka planı beyaz yap
    canvas.drawRect(
      Offset.zero & targetSize,
      Paint()..color = Colors.white,
    );

    // Çizim sınırlarını hesapla
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final point in points) {
      if (point.point == Offset.infinite) continue;
      minX = minX < point.point.dx ? minX : point.point.dx;
      minY = minY < point.point.dy ? minY : point.point.dy;
      maxX = maxX > point.point.dx ? maxX : point.point.dx;
      maxY = maxY > point.point.dy ? maxY : point.point.dy;
    }

    // Çizim boyutlarını hesapla
    final drawingWidth = maxX - minX;
    final drawingHeight = maxY - minY;

    // Ölçekleme faktörünü hesapla
    final scaleX = targetSize.width / drawingWidth;
    final scaleY = targetSize.height / drawingHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    // Ortalama için offset hesapla
    final offsetX = (targetSize.width - drawingWidth * scale) / 2;
    final offsetY = (targetSize.height - drawingHeight * scale) / 2;

    // Çizimi ortala ve ölçekle
    canvas.translate(offsetX - minX * scale, offsetY - minY * scale);
    canvas.scale(scale * 0.8); // Biraz daha küçült ki kenarlarda boşluk olsun

    // Çizimleri çiz
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i + 1].point == Offset.infinite) continue;

      canvas.drawLine(
        points[i].point,
        points[i + 1].point,
        points[i].paint,
      );
    }

    // Picture'ı kaydet
    final picture = recorder.endRecording();

    // Image'a dönüştür
    final image = await picture.toImage(
      targetSize.width.toInt(),
      targetSize.height.toInt(),
    );

    // PNG formatında ve tam kalitede dönüştür
    final byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      throw Exception('Failed to convert drawing to image');
    }

    return byteData.buffer.asUint8List();
  }
}
