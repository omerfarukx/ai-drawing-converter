import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/purchase_service.dart';

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  final service = PurchaseService();
  service.initialize();
  ref.onDispose(() => service.dispose());
  return service;
});

final purchaseLoadingProvider = StateProvider<bool>((ref) => false);
