import 'package:flutter/material.dart';

class DrawingPoint {
  final Offset point;
  final Paint paint;

  const DrawingPoint({
    required this.point,
    required this.paint,
  });

  DrawingPoint copyWith({
    Offset? point,
    Paint? paint,
  }) {
    return DrawingPoint(
      point: point ?? this.point,
      paint: paint ?? this.paint,
    );
  }
}
