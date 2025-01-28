import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/shared_drawing.dart';
import '../../domain/services/drawing_service.dart';
import '../widgets/shared_drawing_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final savedDrawingsProvider =
    FutureProvider.autoDispose<List<SharedDrawing>>((ref) async {
  final authState = ref.read(authControllerProvider);
  final userId = authState.maybeMap(
    authenticated: (state) => state.user.id,
    orElse: () => throw Exception('Giriş yapmanız gerekiyor'),
  );

  final drawingService = ref.read(drawingServiceProvider);
  return drawingService.getSavedDrawings(userId);
});

class SavedDrawingsPage extends ConsumerWidget {
  const SavedDrawingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedDrawings = ref.watch(savedDrawingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F3460),
      appBar: AppBar(
        title: const Text(
          'Kaydedilen Çizimler',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF16213E),
        elevation: 0,
      ),
      body: savedDrawings.when(
        data: (drawings) {
          if (drawings.isEmpty) {
            return const Center(
              child: Text(
                'Henüz kaydedilen çizim yok',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: drawings.length,
            itemBuilder: (context, index) {
              final drawing = drawings[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SharedDrawingCard(drawing: drawing),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF533483),
          ),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Hata: $error',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
