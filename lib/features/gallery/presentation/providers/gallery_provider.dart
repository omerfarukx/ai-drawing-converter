import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/drawing.dart';
import '../../domain/repositories/gallery_repository.dart';
import '../../domain/services/gallery_service.dart';
import '../../domain/models/shared_drawing.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/domain/models/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  return galleryService.getDrawings(); // Tüm çizimleri getir
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
      required String description,
      required String category,
    }),
    UserProfile>((ref, profile) {
  final galleryService = ref.watch(galleryServiceProvider);

  return ({
    required String imageUrl,
    required String title,
    required String description,
    required String category,
  }) async {
    await galleryService.shareDrawing(
      userId: profile.id,
      userName: profile.username,
      userPhotoURL: profile.photoURL,
      imageUrl: imageUrl,
      title: title,
      description: description,
      category: category,
    );
  };
});

final sharedDrawingStreamProvider =
    StreamProvider.family.autoDispose<SharedDrawing, String>((ref, drawingId) {
  final firestore = FirebaseFirestore.instance;
  final authState = ref.read(authControllerProvider);
  final currentUserId = authState.maybeMap(
    authenticated: (state) => state.user.id,
    orElse: () => null,
  );

  print(
      'Debug: sharedDrawingStreamProvider - Stream başlatılıyor... DrawingId: $drawingId');

  // Ana doküman ve stats koleksiyonunu dinle
  return firestore
      .collection('shared_drawings')
      .doc(drawingId)
      .snapshots()
      .asyncMap((doc) async {
    if (!doc.exists) {
      print('Debug: sharedDrawingStreamProvider - Çizim bulunamadı!');
      throw Exception('Çizim bulunamadı');
    }

    print(
        'Debug: sharedDrawingStreamProvider - Çizim bulundu, stats ve beğeniler kontrol ediliyor...');

    final data = Map<String, dynamic>.from(doc.data()!);
    print('Debug: sharedDrawingStreamProvider - Ana veri: $data');

    // Stats ve kullanıcı etkileşimlerini dinle
    final statsDoc =
        await doc.reference.collection('stats').doc('interactions').get();
    print(
        'Debug: sharedDrawingStreamProvider - Stats dokümanı var mı: ${statsDoc.exists}');

    final likeDoc = currentUserId != null
        ? await doc.reference.collection('likes').doc(currentUserId).get()
        : null;
    print(
        'Debug: sharedDrawingStreamProvider - Beğeni durumu: ${likeDoc?.exists}');

    final saveDoc = currentUserId != null
        ? await doc.reference.collection('saves').doc(currentUserId).get()
        : null;

    // Ana dokümandaki eski alanları temizle
    data.remove('likes');
    data.remove('saves');
    data.remove('comments');

    if (statsDoc.exists) {
      final stats = statsDoc.data() as Map<String, dynamic>;
      data['likesCount'] = stats['likesCount'] ?? 0;
      data['savesCount'] = stats['savesCount'] ?? 0;
      data['commentsCount'] = stats['commentsCount'] ?? 0;
      print(
          'Debug: sharedDrawingStreamProvider - Stats güncellendi - Beğeni sayısı: ${data['likesCount']}');
    } else {
      data['likesCount'] = 0;
      data['savesCount'] = 0;
      data['commentsCount'] = 0;
      print(
          'Debug: sharedDrawingStreamProvider - Stats dokümanı yok, varsayılan değerler kullanıldı');
    }

    data['isLiked'] = likeDoc?.exists ?? false;
    data['isSaved'] = saveDoc?.exists ?? false;

    print('Debug: sharedDrawingStreamProvider - Son veri: $data');
    return SharedDrawing.fromFirestore(data, doc.id);
  });
});
