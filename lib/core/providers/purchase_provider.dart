import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/purchase_service.dart';

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  return PurchaseService();
});

final productsProvider = FutureProvider<List<ProductDetails>>((ref) async {
  final purchaseService = ref.read(purchaseServiceProvider);
  return purchaseService.getProducts();
});
