import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseService {
  static const String _creditPackId = 'ai_credits_10';
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  Future<void> initialize() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      print('Uygulama içi satın alma kullanılamıyor');
      return;
    }

    // Satın alma stream'ini dinle
    _subscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription?.cancel(),
      onError: (error) => print('Satın alma hatası: $error'),
    );

    // Ürünleri yükle
    await loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      final Set<String> ids = {_creditPackId};
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(ids);

      if (response.notFoundIDs.isNotEmpty) {
        print('Bulunamayan ürünler: ${response.notFoundIDs}');
      }

      if (response.productDetails.isEmpty) {
        print('Hiç ürün bulunamadı');
      }
    } catch (e) {
      print('Ürünler yüklenirken hata: $e');
    }
  }

  Future<void> buyCredits() async {
    try {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails({_creditPackId});

      if (response.productDetails.isEmpty) {
        print('Ürün bulunamadı');
        return;
      }

      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: response.productDetails.first);

      await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      print('Satın alma başlatılırken hata: $e');
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        print('Satın alma işlemi beklemede');
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        print('Satın alma hatası: ${purchaseDetails.error}');
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        _handleSuccessfulPurchase(purchaseDetails);
      }

      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchase) async {
    // Burada kredi ekleme işlemini yapacağız
    print('Satın alma başarılı: ${purchase.productID}');
  }

  void dispose() {
    _subscription?.cancel();
  }
}
