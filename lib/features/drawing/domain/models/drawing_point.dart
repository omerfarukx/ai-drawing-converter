import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class DrawingPoint {
  final Offset offset;
  final Paint paint;
  final bool isStartOfLine;

  DrawingPoint({
    required this.offset,
    required this.paint,
    this.isStartOfLine = false,
  });

  DrawingPoint copyWith({
    Offset? offset,
    Paint? paint,
    bool? isStartOfLine,
  }) {
    return DrawingPoint(
      offset: offset ?? this.offset,
      paint: paint ?? this.paint,
      isStartOfLine: isStartOfLine ?? this.isStartOfLine,
    );
  }
}

class DrawingPoints {
  final List<DrawingPoint> points;
  final Paint currentPaint;

  const DrawingPoints({
    required this.points,
    required this.currentPaint,
  });

  DrawingPoints copyWith({
    List<DrawingPoint>? points,
    Paint? currentPaint,
  }) {
    return DrawingPoints(
      points: points ?? this.points,
      currentPaint: currentPaint ?? this.currentPaint,
    );
  }

  Future<Uint8List> toImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(1024, 1024); // API'nin beklediği boyut

    // Beyaz arkaplan
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.white,
    );

    // Çizimleri ölçeklendir
    if (points.isNotEmpty) {
      double minX = double.infinity;
      double minY = double.infinity;
      double maxX = -double.infinity;
      double maxY = -double.infinity;

      // Çizimin sınırlarını bul
      for (final point in points) {
        minX = minX < point.offset.dx ? minX : point.offset.dx;
        minY = minY < point.offset.dy ? minY : point.offset.dy;
        maxX = maxX > point.offset.dx ? maxX : point.offset.dx;
        maxY = maxY > point.offset.dy ? maxY : point.offset.dy;
      }

      final drawingWidth = maxX - minX;
      final drawingHeight = maxY - minY;
      final scale = (size.width * 0.8) /
          (drawingWidth > drawingHeight ? drawingWidth : drawingHeight);

      // Çizimi ortala ve ölçeklendir
      canvas.translate(
        (size.width - drawingWidth * scale) / 2 - minX * scale,
        (size.height - drawingHeight * scale) / 2 - minY * scale,
      );
      canvas.scale(scale);

      // Çizimleri çiz
      for (var i = 0; i < points.length - 1; i++) {
        final current = points[i];
        final next = points[i + 1];
        if (!next.isStartOfLine) {
          canvas.drawLine(current.offset, next.offset, current.paint);
        }
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) throw Exception('Resim verisi alınamadı');

    return byteData.buffer.asUint8List();
  }
}
