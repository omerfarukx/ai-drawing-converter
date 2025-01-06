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

    // Geçerli noktaları topla
    final validPoints = points.where((point) => point.point != Offset.infinite);
    if (validPoints.isEmpty) {
      throw Exception('No valid points to convert to image');
    }

    // Çizim sınırlarını hesapla
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final point in validPoints) {
      minX = minX < point.point.dx ? minX : point.point.dx;
      minY = minY < point.point.dy ? minY : point.point.dy;
      maxX = maxX > point.point.dx ? maxX : point.point.dx;
      maxY = maxY > point.point.dy ? maxY : point.point.dy;
    }

    // Çizim boyutlarını hesapla
    final drawingWidth = maxX - minX;
    final drawingHeight = maxY - minY;

    // Ölçekleme faktörünü hesapla (en-boy oranını koru)
    double scale;
    double offsetX = 0;
    double offsetY = 0;

    if (drawingWidth / drawingHeight > targetSize.width / targetSize.height) {
      // Genişliğe göre ölçekle
      scale = (targetSize.width * 0.8) / drawingWidth;
      offsetX = targetSize.width * 0.1;
      offsetY = (targetSize.height - drawingHeight * scale) / 2;
    } else {
      // Yüksekliğe göre ölçekle
      scale = (targetSize.height * 0.8) / drawingHeight;
      offsetY = targetSize.height * 0.1;
      offsetX = (targetSize.width - drawingWidth * scale) / 2;
    }

    // Recorder oluştur
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Arka planı beyaz yap
    canvas.drawRect(
      Offset.zero & targetSize,
      Paint()..color = Colors.white,
    );

    // Çizimi ortala ve ölçekle
    canvas.translate(offsetX - minX * scale, offsetY - minY * scale);
    canvas.scale(scale);

    // Çizimleri çiz
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i + 1].point == Offset.infinite) continue;

      final current = points[i];
      final next = points[i + 1];

      canvas.drawLine(
        current.point,
        next.point,
        current.paint,
      );
    }

    // Picture'ı kaydet
    final picture = recorder.endRecording();

    // Image'a dönüştür
    final image = await picture.toImage(
      targetSize.width.toInt(),
      targetSize.height.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Failed to convert drawing to image');
    }

    return byteData.buffer.asUint8List();
  }
}
