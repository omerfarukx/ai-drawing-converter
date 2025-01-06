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
        ref.read(drawingProvider.notifier).addPoint(details.localPosition);
      },
      onPanUpdate: (details) {
        ref.read(drawingProvider.notifier).addPoint(details.localPosition);
      },
      onPanEnd: (_) {
        ref.read(drawingProvider.notifier).endLine();
      },
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _DrawingPainter(drawingState.points),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<DrawingPoint> points;

  _DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
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
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
