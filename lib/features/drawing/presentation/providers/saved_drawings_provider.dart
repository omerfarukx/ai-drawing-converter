import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../gallery/domain/models/shared_drawing.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final savedDrawingsProvider =
    StreamProvider.autoDispose<List<SharedDrawing>>((ref) {
  final authState = ref.watch(authControllerProvider);

  return authState.maybeMap(
    authenticated: (state) {
      final userId = state.user.id;

      return FirebaseFirestore.instance
          .collection('shared_drawings')
          .where('savedBy', arrayContains: userId)
          .snapshots()
          .map((snapshot) {
        final drawings = snapshot.docs
            .map((doc) {
              try {
                return SharedDrawing.fromFirestore(doc.data(), doc.id);
              } catch (e) {
                print('Error parsing drawing ${doc.id}: $e');
                return null;
              }
            })
            .where((drawing) => drawing != null)
            .cast<SharedDrawing>()
            .toList();

        return drawings;
      });
    },
    orElse: () => Stream.value([]),
  );
});
