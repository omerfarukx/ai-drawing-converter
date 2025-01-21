import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:yapayzeka_cizim/core/services/user_service.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();

  factory PurchaseService() {
    return _instance;
  }

  PurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];

  Future<void> initialize() async {
    if (!kDebugMode) {
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        debugPrint('Uygulama içi satın alma kullanılamıyor');
        return;
      }

      _subscription = _inAppPurchase.purchaseStream.listen(
        _handlePurchaseUpdates,
        onDone: () => _subscription?.cancel(),
        onError: (error) => debugPrint('Satın alma hatası: $error'),
      );
    }

    await getProducts();
  }

  Future<List<ProductDetails>> getProducts() async {
    if (kDebugMode) {
      // Debug modunda test ürünleri
      return [
        ProductDetails(
          id: 'credits_10',
          title: '10 AI Çizim Kredisi',
          description: 'AI ile çizim yapmak için 10 kredi',
          price: '₺29.99',
          rawPrice: 29.99,
          currencyCode: 'TRY',
        ),
        ProductDetails(
          id: 'credits_25',
          title: '25 AI Çizim Kredisi',
          description: 'AI ile çizim yapmak için 25 kredi',
          price: '₺59.99',
          rawPrice: 59.99,
          currencyCode: 'TRY',
        ),
        ProductDetails(
          id: 'credits_50',
          title: '50+5 AI Çizim Kredisi',
          description: 'AI ile çizim yapmak için 50+5 bonus kredi',
          price: '₺99.99',
          rawPrice: 99.99,
          currencyCode: 'TRY',
        ),
      ];
    }

    try {
      const Set<String> kIds = {
        'credits_10',
        'credits_25',
        'credits_50',
      };

      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(kIds);
      return response.productDetails;
    } catch (e) {
      debugPrint('Ürünler yüklenirken hata: $e');
      return [];
    }
  }

  Future<bool> buyProduct(String productId) async {
    if (kDebugMode) {
      // Debug modunda her zaman başarılı
      debugPrint('Debug modunda test satın alma: $productId');
      return true;
    }

    try {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails({productId});
      if (response.notFoundIDs.isNotEmpty) {
        return false;
      }

      final ProductDetails productDetails = response.productDetails.first;
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: productDetails);

      await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      return true;
    } catch (e) {
      debugPrint('Satın alma başlatılırken hata: $e');
      return false;
    }
  }

  Future<bool> isPremium() async {
    if (kDebugMode) {
      return true; // Debug modunda her zaman premium
    }

    try {
      final purchases = await _inAppPurchase.purchaseStream.first;
      return purchases.any((purchase) =>
          purchase.productID == 'premium_membership' &&
          purchase.status == PurchaseStatus.purchased);
    } catch (e) {
      print('Premium durumu kontrol edilirken hata: $e');
      return false;
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        debugPrint('Satın alma işlemi beklemede');
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        debugPrint('Satın alma hatası: ${purchaseDetails.error}');
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
    debugPrint('Satın alma başarılı: ${purchase.productID}');
  }

  void dispose() {
    _subscription?.cancel();
  }
}
