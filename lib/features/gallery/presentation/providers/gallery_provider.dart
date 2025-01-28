import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/drawing.dart';
import '../../domain/repositories/gallery_repository.dart';
import '../../domain/services/gallery_service.dart';
import '../../domain/models/shared_drawing.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/domain/models/user_profile.dart';

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

final galleryServiceProvider = Provider<GalleryService>((ref) {
  return GalleryService();
});

// Keşfet sayfası için tüm çizimleri getir
final allDrawingsProvider = StreamProvider<List<SharedDrawing>>((ref) {
  final galleryService = ref.watch(galleryServiceProvider);
  return galleryService.getDrawings();
});

// Kullanıcının çizimlerini getir
final userDrawingsProvider =
    StreamProvider.family<List<SharedDrawing>, String>((ref, userId) {
  final galleryService = ref.watch(galleryServiceProvider);
  return galleryService.getUserDrawings(userId);
});

final shareDrawingProvider = Provider.family<
    Future<void> Function({
      required String imageUrl,
      required String title,
      String? description,
    }),
    UserProfile>((ref, profile) {
  final galleryService = ref.watch(galleryServiceProvider);

  return ({
    required String imageUrl,
    required String title,
    String? description,
  }) async {
    await galleryService.shareDrawing(
      userId: profile.id,
      userName: profile.username,
      displayName: profile.displayName,
      userPhotoURL: profile.photoURL,
      imageUrl: imageUrl,
      title: title,
      description: description,
    );
  };
});
