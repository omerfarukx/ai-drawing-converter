import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/purchase_service.dart';

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  final purchaseService = PurchaseService();
  ref.onDispose(() {
    purchaseService.dispose();
  });
  return purchaseService;
});
