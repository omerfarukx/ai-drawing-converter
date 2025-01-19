import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/drawing.dart';
import '../../domain/repositories/gallery_repository.dart';

final galleryRepositoryProvider = Provider<GalleryRepository>((ref) {
  return LocalGalleryRepository();
});

final galleryProvider = FutureProvider.autoDispose<List<Drawing>>((ref) async {
  final repository = ref.watch(galleryRepositoryProvider);
  return repository.getDrawings();
});

final categoriesProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final repository = ref.watch(galleryRepositoryProvider);
  final drawings = await repository.getDrawings();
  return drawings.map((d) => d.category).toSet().toList();
});

final selectedCategoryProvider =
    StateProvider.autoDispose<String?>((ref) => null);

final filteredDrawingsProvider =
    FutureProvider.autoDispose<List<Drawing>>((ref) async {
  final drawings = await ref.watch(galleryProvider.future);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  if (selectedCategory == null || selectedCategory.isEmpty) {
    return drawings;
  }

  return drawings
      .where((drawing) => drawing.category == selectedCategory)
      .toList();
});
