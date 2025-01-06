import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ai_provider.dart';
import '../providers/drawing_provider.dart';
import 'ai_result_dialog.dart';

class AIButton extends ConsumerWidget {
  const AIButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiState = ref.watch(aiProvider);
    final isLoading = aiState.isLoading;

    return Container(
      height: 45,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () async {
                final drawingNotifier = ref.read(drawingProvider.notifier);
                final drawingState = ref.read(drawingProvider);

                if (drawingState.points.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen önce bir çizim yapın'),
                    ),
                  );
                  return;
                }

                drawingNotifier.optimizeDrawing();

                try {
                  await ref
                      .read(aiProvider.notifier)
                      .generateImage(drawingState);

                  if (context.mounted) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const AIResultDialog(),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Hata: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading ? Colors.grey.shade300 : Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: isLoading ? 0 : 4,
          shadowColor: Colors.deepPurple.withOpacity(0.4),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.white,
        ),
        child: Container(
          width: isLoading ? 120 : 100,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.deepPurple,
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
