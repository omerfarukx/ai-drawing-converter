import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/drawing_provider.dart';
import '../../domain/models/drawing_point.dart';

class DrawingCanvas extends ConsumerWidget {
  const DrawingCanvas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawingState = ref.watch(drawingProvider);
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: GestureDetector(
        onPanStart: (details) {
          final box = context.findRenderObject() as RenderBox;
          final offset = box.globalToLocal(details.globalPosition);
          ref.read(drawingProvider.notifier).startDrawing(offset);
        },
        onPanUpdate: (details) {
          final box = context.findRenderObject() as RenderBox;
          final offset = box.globalToLocal(details.globalPosition);
          ref.read(drawingProvider.notifier).addPoint(offset);
        },
        onPanEnd: (details) {
          ref.read(drawingProvider.notifier).endDrawing();
        },
        child: CustomPaint(
          size: Size(size.width - 80, size.height),
          painter: DrawingPainter(drawingState.points),
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> points;

  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.white,
    );

    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];

      // Eğer next noktası yeni bir çizginin başlangıcıysa, çizgi çizme
      if (!next.isStartOfLine) {
        canvas.drawLine(current.offset, next.offset, current.paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
