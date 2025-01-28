import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/shared_drawing.dart';
import '../widgets/shared_drawing_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final savedDrawingsProvider =
    StreamProvider.autoDispose<List<SharedDrawing>>((ref) {
  final authState = ref.watch(authControllerProvider);
  final userId = authState.maybeMap(
    authenticated: (state) => state.user.id,
    orElse: () => null,
  );

  if (userId == null) return Stream.value([]);

  final firestore = FirebaseFirestore.instance;
  return firestore
      .collection('shared_drawings')
      .where('savedBy', arrayContains: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => SharedDrawing.fromFirestore(doc.data(), doc.id))
          .toList());
});

class SavedDrawingsPage extends ConsumerWidget {
  const SavedDrawingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedDrawings = ref.watch(savedDrawingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Kaydedilenler'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: savedDrawings.when(
        data: (drawings) {
          if (drawings.isEmpty) {
            return Center(
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
                    'Henüz kaydettiğin çizim yok',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Keşfet sayfasından beğendiğin çizimleri kaydedebilirsin',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: drawings.length,
            itemBuilder: (context, index) {
              return SharedDrawingCard(drawing: drawings[index]);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Hata: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
