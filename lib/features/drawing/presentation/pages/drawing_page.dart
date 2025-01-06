import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/drawing_toolbar.dart';
import '../widgets/ai_result_dialog.dart';
import '../providers/drawing_provider.dart';
import '../providers/ai_provider.dart';

class DrawingPage extends ConsumerWidget {
  const DrawingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Çizim Yap'),
        backgroundColor: Colors.deepPurple,
        actions: [
          // Geri al butonu
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: () {
              ref.read(drawingProvider.notifier).undo();
            },
          ),
          // Temizle butonu
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              ref.read(drawingProvider.notifier).clear();
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Sol taraftaki araç çubuğu
          const SizedBox(
            width: 80,
            child: DrawingToolbar(),
          ),
          // Sağ taraftaki çizim alanı
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: const DrawingCanvas(),
            ),
          ),
        ],
      ),
    );
  }
}
