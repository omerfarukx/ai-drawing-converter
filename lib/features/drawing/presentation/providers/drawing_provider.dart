import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/drawing_point.dart';
import 'dart:math' as Math;

final drawingProvider =
    StateNotifierProvider<DrawingNotifier, DrawingPoints>((ref) {
  return DrawingNotifier();
});

class DrawingNotifier extends StateNotifier<DrawingPoints> {
  DrawingNotifier()
      : super(DrawingPoints(
          points: [],
          currentPaint: Paint()
            ..color = Colors.black
            ..strokeWidth = 3.0
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke,
        ));

  void startDrawing(Offset offset) {
    final newPoint = DrawingPoint(
      offset: offset,
      paint: Paint()
        ..color = state.currentPaint.color
        ..strokeWidth = state.currentPaint.strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
      isStartOfLine: true,
    );

    state = state.copyWith(
      points: [...state.points, newPoint],
    );
  }

  void addPoint(Offset offset) {
    if (state.points.isEmpty) {
      startDrawing(offset);
      return;
    }

    // Son nokta ile yeni nokta arasındaki mesafeyi kontrol et
    final lastPoint = state.points.last;
    final distance = (lastPoint.offset - offset).distance;

    // Minimum mesafe kontrolü (çok yakın noktaları ekleme)
    if (distance < 2.0) {
      return;
    }

    // Maksimum nokta sayısı kontrolü
    if (state.points.length > 3000) {
      // En eski noktaları sil
      final newPoints = state.points.sublist(state.points.length - 3000);
      state = state.copyWith(points: newPoints);
    }

    final newPoint = DrawingPoint(
      offset: offset,
      paint: Paint()
        ..color = state.currentPaint.color
        ..strokeWidth = state.currentPaint.strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    state = state.copyWith(
      points: [...state.points, newPoint],
    );
  }

  void endDrawing() {
    // Çizim bittiğinde yapılacak işlemler buraya eklenebilir
  }

  void updateColor(Color color) {
    final newPaint = Paint()
      ..color = color
      ..strokeWidth = state.currentPaint.strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    state = state.copyWith(currentPaint: newPaint);
  }

  void updateStrokeWidth(double width) {
    final newPaint = Paint()
      ..color = state.currentPaint.color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    state = state.copyWith(currentPaint: newPaint);
  }

  void clear() {
    state = state.copyWith(points: []);
  }

  void undo() {
    if (state.points.isEmpty) return;

    // Son çizgi grubunu bul
    final points = [...state.points];
    for (var i = points.length - 1; i >= 0; i--) {
      if (points[i].isStartOfLine && i > 0) {
        points.removeRange(i, points.length);
        state = state.copyWith(points: points);
        return;
      }
    }

    // Eğer başka çizgi grubu yoksa tümünü temizle
    clear();
  }

  // Çizimi optimize et
  void optimizeDrawing() {
    if (state.points.length < 3) return;

    final optimizedPoints = <DrawingPoint>[];
    optimizedPoints.add(state.points.first);

    for (var i = 1; i < state.points.length - 1; i++) {
      final prev = state.points[i - 1];
      final current = state.points[i];
      final next = state.points[i + 1];

      // Noktalar arasındaki açıyı kontrol et
      final angle = _calculateAngle(prev.offset, current.offset, next.offset);

      // Eğer açı belirli bir değerden büyükse veya nokta bir çizginin başlangıcıysa ekle
      if (angle > 10 || current.isStartOfLine) {
        optimizedPoints.add(current);
      }
    }

    optimizedPoints.add(state.points.last);
    state = state.copyWith(points: optimizedPoints);
  }

  // İki vektör arasındaki açıyı hesapla
  double _calculateAngle(Offset p1, Offset p2, Offset p3) {
    final vector1 = p1 - p2;
    final vector2 = p3 - p2;

    final angle =
        Math.atan2(vector2.dy, vector2.dx) - Math.atan2(vector1.dy, vector1.dx);
    return (angle * 180 / Math.pi).abs();
  }
}
