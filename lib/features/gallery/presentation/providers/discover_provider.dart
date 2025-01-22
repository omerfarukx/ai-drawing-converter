import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/shared_drawing.dart';
import '../../domain/repositories/shared_drawing_repository.dart';

final discoverProvider = StreamProvider<List<SharedDrawing>>((ref) {
  final repository = ref.watch(sharedDrawingRepositoryProvider);
  return repository.getSharedDrawings();
});

// Sayfalama için son döküman ID'sini tutan provider
final lastDocumentIdProvider = StateProvider<String?>((ref) => null);

// Daha fazla yükleniyor durumunu tutan provider
final isLoadingMoreProvider = StateProvider<bool>((ref) => false);
