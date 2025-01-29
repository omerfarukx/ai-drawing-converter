import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/shared_drawing_repository.dart';
import '../../domain/models/shared_drawing.dart';

final shareDrawingProvider =
    StateNotifierProvider<ShareDrawingNotifier, AsyncValue<SharedDrawing?>>(
        (ref) {
  return ShareDrawingNotifier(ref.watch(sharedDrawingRepositoryProvider));
});

class ShareDrawingNotifier extends StateNotifier<AsyncValue<SharedDrawing?>> {
  final SharedDrawingRepository _repository;

  ShareDrawingNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> shareDrawing({
    required String userId,
    required String userName,
    required String userProfileImage,
    required String imageUrl,
    required String title,
    String? description,
    String? category,
    bool isPublic = true,
  }) async {
    state = const AsyncValue.loading();

    try {
      if (!imageUrl.startsWith('http')) {
        throw 'Geçersiz resim URL\'i';
      }

      final drawing = await _repository.shareDrawing(
        userId: userId,
        userName: userName,
        userProfileImage: userProfileImage,
        imageUrl: imageUrl,
        title: title,
        description: description,
        category: category,
        isPublic: isPublic,
      );
      state = AsyncValue.data(drawing);
    } catch (error, stackTrace) {
      print('Debug: Paylaşma hatası - $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
