import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../gallery/domain/models/shared_drawing.dart';
import '../../../gallery/presentation/widgets/drawing_card.dart';
import '../../../gallery/presentation/pages/shared_drawing_detail_page.dart';
import '../providers/saved_drawings_provider.dart';

class SavedDrawingsPage extends ConsumerWidget {
  const SavedDrawingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedDrawingsAsync = ref.watch(savedDrawingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Kaydedilenler'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: savedDrawingsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF533483),
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Hata: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(savedDrawingsProvider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF533483),
                ),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
        data: (drawings) => drawings.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: 64,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz hiç çizim kaydetmediniz',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Beğendiğiniz çizimleri kaydedin ve\nburada görüntüleyin',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: drawings.length,
                itemBuilder: (context, index) {
                  final drawing = drawings[index];
                  return DrawingCard(
                    drawing: drawing,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SharedDrawingDetailPage(
                            drawing: drawing,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
