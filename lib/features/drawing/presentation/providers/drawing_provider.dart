import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/drawing_point.dart';

enum BrushType {
  normal,
  soft,
  square,
  calligraphy,
}

class DrawingState {
  final List<DrawingPoint> points;
  final Paint currentPaint;
  final bool isErasing;
  final double strokeWidth;
  final Color selectedColor;
  final BrushType brushType;

  const DrawingState({
    required this.points,
    required this.currentPaint,
    required this.isErasing,
    required this.strokeWidth,
    required this.selectedColor,
    required this.brushType,
  });

  DrawingState copyWith({
    List<DrawingPoint>? points,
    Paint? currentPaint,
    bool? isErasing,
    double? strokeWidth,
    Color? selectedColor,
    BrushType? brushType,
  }) {
    return DrawingState(
      points: points ?? this.points,
      currentPaint: currentPaint ?? this.currentPaint,
      isErasing: isErasing ?? this.isErasing,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      selectedColor: selectedColor ?? this.selectedColor,
      brushType: brushType ?? this.brushType,
    );
  }
}

final drawingProvider =
    StateNotifierProvider<DrawingNotifier, DrawingState>((ref) {
  return DrawingNotifier();
});

class DrawingNotifier extends StateNotifier<DrawingState> {
  DrawingNotifier()
      : super(DrawingState(
          points: [],
          currentPaint: Paint()
            ..color = Colors.black
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..style = PaintingStyle.stroke,
          isErasing: false,
          strokeWidth: 3,
          selectedColor: Colors.black,
          brushType: BrushType.normal,
        ));

  void addPoint(Offset point) {
    final newPoint = DrawingPoint(
      point: point,
      paint: state.currentPaint,
    );

    state = state.copyWith(
      points: [...state.points, newPoint],
    );
  }

  void endLine() {
    if (state.points.isEmpty) return;

    state = state.copyWith(
      points: [
        ...state.points,
        DrawingPoint(
          point: Offset.infinite,
          paint: state.currentPaint,
        ),
      ],
    );
  }

  void clear() {
    state = state.copyWith(points: []);
  }

  void toggleEraser() {
    final isErasing = !state.isErasing;
    final paint = Paint()
      ..strokeWidth = state.strokeWidth
      ..strokeCap = _getStrokeCap()
      ..strokeJoin = _getStrokeJoin()
      ..style = PaintingStyle.stroke
      ..color = isErasing ? Colors.white : state.selectedColor;

    state = state.copyWith(
      isErasing: isErasing,
      currentPaint: paint,
    );
  }

  void updateStrokeWidth(double width) {
    final paint = Paint()
      ..strokeWidth = width
      ..strokeCap = _getStrokeCap()
      ..strokeJoin = _getStrokeJoin()
      ..style = PaintingStyle.stroke
      ..color = state.isErasing ? Colors.white : state.selectedColor;

    state = state.copyWith(
      strokeWidth: width,
      currentPaint: paint,
    );
  }

  void updateColor(Color color) {
    if (state.isErasing) return;

    final paint = Paint()
      ..strokeWidth = state.strokeWidth
      ..strokeCap = _getStrokeCap()
      ..strokeJoin = _getStrokeJoin()
      ..style = PaintingStyle.stroke
      ..color = color;

    state = state.copyWith(
      selectedColor: color,
      currentPaint: paint,
    );
  }

  void updateBrushType(BrushType type) {
    final paint = Paint()
      ..strokeWidth = state.strokeWidth
      ..strokeCap = _getStrokeCap(type)
      ..strokeJoin = _getStrokeJoin(type)
      ..style = PaintingStyle.stroke
      ..color = state.isErasing ? Colors.white : state.selectedColor;

    state = state.copyWith(
      brushType: type,
      currentPaint: paint,
    );
  }

  StrokeCap _getStrokeCap([BrushType? type]) {
    final brushType = type ?? state.brushType;
    switch (brushType) {
      case BrushType.normal:
        return StrokeCap.round;
      case BrushType.soft:
        return StrokeCap.round;
      case BrushType.square:
        return StrokeCap.square;
      case BrushType.calligraphy:
        return StrokeCap.square;
    }
  }

  StrokeJoin _getStrokeJoin([BrushType? type]) {
    final brushType = type ?? state.brushType;
    switch (brushType) {
      case BrushType.normal:
        return StrokeJoin.round;
      case BrushType.soft:
        return StrokeJoin.round;
      case BrushType.square:
        return StrokeJoin.miter;
      case BrushType.calligraphy:
        return StrokeJoin.bevel;
    }
  }
}
