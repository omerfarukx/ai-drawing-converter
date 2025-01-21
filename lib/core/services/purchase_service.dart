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
    if (kDebugMode) {
      print('Debug modunda satın alma sistemi başlatıldı');
      return;
    }

    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      print('Uygulama içi satın alma kullanılamıyor');
      return;
    }

    _subscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription?.cancel(),
      onError: (error) => print('Satın alma hatası: $error'),
    );

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
          price: '₺34,99',
          rawPrice: 34.99,
          currencyCode: 'TRY',
        ),
        ProductDetails(
          id: 'credits_25',
          title: '25 AI Çizim Kredisi',
          description: 'AI ile çizim yapmak için 25 kredi',
          price: '₺50,00',
          rawPrice: 50.00,
          currencyCode: 'TRY',
        ),
        ProductDetails(
          id: 'credits_50',
          title: '50+5 AI Çizim Kredisi',
          description: 'AI ile çizim yapmak için 50+5 bonus kredi',
          price: '₺99,00',
          rawPrice: 99.00,
          currencyCode: 'TRY',
        ),
        ProductDetails(
          id: 'credits_100',
          title: '100+15 AI Çizim Kredisi',
          description: 'AI ile çizim yapmak için 100+15 bonus kredi',
          price: '₺200,00',
          rawPrice: 200.00,
          currencyCode: 'TRY',
        ),
      ];
    }

    try {
      final Set<String> ids = {
        'credits_10',
        'credits_25',
        'credits_50',
        'credits_100',
        'premium_membership',
      };

      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(ids);

      if (response.notFoundIDs.isNotEmpty) {
        print('Bulunamayan ürünler: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      return _products;
    } catch (e) {
      print('Ürünler yüklenirken hata: $e');
      return [];
    }
  }

  Future<bool> buyProduct(ProductDetails product) async {
    if (kDebugMode) {
      print('Debug modunda test satın alma: ${product.id}');
      return true;
    }

    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );

      if (product.id == 'premium_membership') {
        return await _inAppPurchase.buyNonConsumable(
          purchaseParam: purchaseParam,
        );
      } else {
        return await _inAppPurchase.buyConsumable(
          purchaseParam: purchaseParam,
        );
      }
    } catch (e) {
      print('Satın alma başlatılırken hata: $e');
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
    print('Satın alma başarılı: ${purchase.productID}');
  }

  void dispose() {
    _subscription?.cancel();
  }
}
