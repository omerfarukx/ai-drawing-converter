import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/drawing_toolbar.dart';
import '../widgets/ai_button.dart';

class DrawingPage extends ConsumerWidget {
  const DrawingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Çizim'),
      ),
      body: Stack(
        children: [
          const DrawingCanvas(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      AIButton(),
                    ],
                  ),
                ),
                const DrawingToolbar(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
