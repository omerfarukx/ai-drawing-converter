import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/drawing.dart';
import '../../domain/repositories/gallery_repository.dart';

final galleryRepositoryProvider = Provider((ref) => GalleryRepository());

final drawingsProvider = FutureProvider<List<Drawing>>((ref) async {
  final repository = ref.watch(galleryRepositoryProvider);
  return repository.getDrawings();
});

final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(galleryRepositoryProvider);
  return repository.getCategories();
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final filteredDrawingsProvider = FutureProvider<List<Drawing>>((ref) async {
  final drawings = await ref.watch(drawingsProvider.future);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  if (selectedCategory == null) {
    return drawings;
  }

  return drawings
      .where((drawing) => drawing.category == selectedCategory)
      .toList();
});
