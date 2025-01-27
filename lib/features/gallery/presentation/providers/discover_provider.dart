import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/shared_drawing.dart';
import '../../domain/repositories/shared_drawing_repository.dart';

final class DiscoverNotifier
    extends StateNotifier<AsyncValue<List<SharedDrawing>>> {
  final SharedDrawingRepository _repository;
  String? _lastDocumentId;
  bool _isLoading = false;

  DiscoverNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    try {
      final drawings = await _repository.getSharedDrawings(limit: 10);
      if (drawings.isNotEmpty) {
        _lastDocumentId = drawings.last.id;
      }
      state = AsyncValue.data(drawings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || _lastDocumentId == null) return;
    if (state.value == null || state.value!.isEmpty) return;

    _isLoading = true;
    try {
      final moreDrawings = await _repository.getSharedDrawings(
        startAfterId: _lastDocumentId,
        limit: 10,
      );

      if (moreDrawings.isNotEmpty) {
        _lastDocumentId = moreDrawings.last.id;
        state = AsyncValue.data([...state.value!, ...moreDrawings]);
      }
    } catch (error, stackTrace) {
      // Hata durumunda mevcut state'i koruyoruz, sadece hata gösteriyoruz
      print('Daha fazla çizim yüklenirken hata: $error');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refresh() async {
    _lastDocumentId = null;
    state = const AsyncValue.loading();
    await loadInitial();
  }
}

final discoverProvider =
    StateNotifierProvider<DiscoverNotifier, AsyncValue<List<SharedDrawing>>>(
        (ref) {
  final repository = ref.watch(sharedDrawingRepositoryProvider);
  return DiscoverNotifier(repository);
});

// Sayfalama için son döküman ID'sini tutan provider
final lastDocumentIdProvider = StateProvider<String?>((ref) => null);

// Daha fazla yükleniyor durumunu tutan provider
final isLoadingMoreProvider = StateProvider<bool>((ref) => false);
