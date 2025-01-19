import 'package:flutter/material.dart';

class DrawingPoint {
  final Offset point;
  final Paint paint;
  final double pressure;

  const DrawingPoint({
    required this.point,
    required this.paint,
    required this.pressure,
  });

  factory DrawingPoint.initial() => DrawingPoint(
        point: Offset.zero,
        paint: Paint()
          ..color = Colors.black
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke,
        pressure: 1.0,
      );

  DrawingPoint copyWith({
    Offset? point,
    Paint? paint,
    double? pressure,
  }) {
    return DrawingPoint(
      point: point ?? this.point,
      paint: paint ?? this.paint,
      pressure: pressure ?? this.pressure,
    );
  }
}
