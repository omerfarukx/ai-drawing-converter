import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/drawing_provider.dart';
import '../../domain/models/drawing_point.dart';

class DrawingCanvas extends ConsumerWidget {
  const DrawingCanvas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawingState = ref.watch(drawingProvider);

    return GestureDetector(
      onPanStart: (details) {
        final box = context.findRenderObject() as RenderBox;
        final point = box.globalToLocal(details.globalPosition);
        ref.read(drawingProvider.notifier).startLine(point);
      },
      onPanUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        final point = box.globalToLocal(details.globalPosition);
        ref.read(drawingProvider.notifier).addPoint(point);
      },
      onPanEnd: (_) {
        ref.read(drawingProvider.notifier).endLine();
      },
      child: RepaintBoundary(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: CustomPaint(
            painter: _DrawingPainter(
              lines: drawingState.lines,
              currentLine: drawingState.currentLine,
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<List<DrawingPoint>> lines;
  final List<DrawingPoint> currentLine;

  _DrawingPainter({
    required this.lines,
    required this.currentLine,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Önceki çizgileri çiz
    for (final line in lines) {
      if (line.isEmpty) continue;
      _drawLine(canvas, line);
    }

    // Şu anki çizgiyi çiz
    if (currentLine.isNotEmpty) {
      _drawLine(canvas, currentLine);
    }
  }

  void _drawLine(Canvas canvas, List<DrawingPoint> line) {
    for (int i = 0; i < line.length - 1; i++) {
      final current = line[i];
      final next = line[i + 1];

      canvas.drawLine(
        current.point,
        next.point,
        current.paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) {
    return oldDelegate.lines != lines || oldDelegate.currentLine != currentLine;
  }
}
