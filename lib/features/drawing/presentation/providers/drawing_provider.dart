import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/drawing_point.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class DrawingState {
  final List<DrawingPoint> currentLine;
  final List<List<DrawingPoint>> lines;
  final List<List<List<DrawingPoint>>> history;
  final int historyIndex;
  final Color currentColor;
  final Color selectedColor;
  final double strokeWidth;
  final bool isErasing;
  final Paint currentPaint;

  const DrawingState({
    required this.currentLine,
    required this.lines,
    required this.history,
    required this.historyIndex,
    required this.currentColor,
    required this.selectedColor,
    required this.strokeWidth,
    required this.isErasing,
    required this.currentPaint,
  });

  bool get canUndo => historyIndex > 0;
  bool get canRedo => historyIndex < history.length - 1;

  List<DrawingPoint> get allPoints {
    final List<DrawingPoint> all = [];
    for (var line in lines) {
      all.addAll(line);
    }
    all.addAll(currentLine);
    return all;
  }

  DrawingState copyWith({
    List<DrawingPoint>? currentLine,
    List<List<DrawingPoint>>? lines,
    List<List<List<DrawingPoint>>>? history,
    int? historyIndex,
    Color? currentColor,
    Color? selectedColor,
    double? strokeWidth,
    bool? isErasing,
    Paint? currentPaint,
  }) {
    return DrawingState(
      currentLine: currentLine ?? this.currentLine,
      lines: lines ?? this.lines,
      history: history ?? this.history,
      historyIndex: historyIndex ?? this.historyIndex,
      currentColor: currentColor ?? this.currentColor,
      selectedColor: selectedColor ?? this.selectedColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      isErasing: isErasing ?? this.isErasing,
      currentPaint: currentPaint ?? this.currentPaint,
    );
  }

  Future<String> saveToImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Beyaz arka plan
    canvas.drawRect(
      Rect.largest,
      Paint()..color = Colors.white,
    );

    // Tüm çizim noktalarını çiz
    for (var line in lines) {
      for (var i = 0; i < line.length - 1; i++) {
        final current = line[i];
        final next = line[i + 1];
        canvas.drawLine(current.point, next.point, current.paint);
      }
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(512, 512); // 512x512 boyutunda kaydet
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = pngBytes!.buffer.asUint8List();

    // Firebase Storage'a yükle
    final storage = FirebaseStorage.instance;
    final fileName = 'drawings/${DateTime.now().millisecondsSinceEpoch}.png';
    final ref = storage.ref().child(fileName);

    await ref.putData(buffer);
    final url = await ref.getDownloadURL();

    return url;
  }
}

class DrawingNotifier extends StateNotifier<DrawingState> {
  DrawingNotifier()
      : super(DrawingState(
          currentLine: [],
          lines: [],
          history: [[]],
          historyIndex: 0,
          currentColor: Colors.black,
          selectedColor: Colors.black,
          strokeWidth: 2.0,
          isErasing: false,
          currentPaint: Paint()
            ..color = Colors.black
            ..strokeWidth = 2.0
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..style = PaintingStyle.stroke,
        ));

  void startLine(Offset point) {
    final paint = Paint()
      ..color = state.isErasing ? Colors.white : state.currentColor
      ..strokeWidth = state.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final newPoint = DrawingPoint(
      point: point,
      paint: paint,
      pressure: 1.0,
    );

    state = state.copyWith(
      currentLine: [newPoint],
      currentPaint: paint,
    );
  }

  void addPoint(Offset point) {
    if (state.currentLine.isEmpty) return;

    final paint = Paint()
      ..color = state.isErasing ? Colors.white : state.currentColor
      ..strokeWidth = state.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final newPoint = DrawingPoint(
      point: point,
      paint: paint,
      pressure: 1.0,
    );

    state = state.copyWith(
      currentLine: [...state.currentLine, newPoint],
      currentPaint: paint,
    );
  }

  void endLine() {
    if (state.currentLine.isEmpty) return;

    final newLines = [...state.lines, state.currentLine];
    final newHistory = [
      ...state.history.sublist(0, state.historyIndex + 1),
      newLines
    ];

    state = state.copyWith(
      currentLine: [],
      lines: newLines,
      history: newHistory,
      historyIndex: state.historyIndex + 1,
    );
  }

  void undo() {
    if (!state.canUndo) return;

    final previousLines = state.history[state.historyIndex - 1];
    state = state.copyWith(
      currentLine: [],
      lines: previousLines,
      historyIndex: state.historyIndex - 1,
    );
  }

  void redo() {
    if (!state.canRedo) return;

    final nextLines = state.history[state.historyIndex + 1];
    state = state.copyWith(
      currentLine: [],
      lines: nextLines,
      historyIndex: state.historyIndex + 1,
    );
  }

  void clear() {
    state = state.copyWith(
      currentLine: [],
      lines: [],
      history: [[]],
      historyIndex: 0,
    );
  }

  void setColor(Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = state.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    state = state.copyWith(
      currentColor: color,
      selectedColor: color,
      currentPaint: paint,
      isErasing: false,
    );
  }

  void updateColor(Color color) => setColor(color);

  void setStrokeWidth(double width) {
    final paint = Paint()
      ..color = state.currentColor
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    state = state.copyWith(
      strokeWidth: width,
      currentPaint: paint,
    );
  }

  void toggleEraser() {
    final paint = Paint()
      ..color = state.isErasing ? state.selectedColor : Colors.white
      ..strokeWidth = state.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    state = state.copyWith(
      isErasing: !state.isErasing,
      currentColor: state.isErasing ? state.selectedColor : Colors.white,
      currentPaint: paint,
    );
  }
}

final drawingProvider =
    StateNotifierProvider<DrawingNotifier, DrawingState>((ref) {
  return DrawingNotifier();
});
