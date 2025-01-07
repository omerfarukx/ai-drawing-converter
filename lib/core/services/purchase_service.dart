import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:yapayzeka_cizim/core/services/user_service.dart';

class PurchaseService {
  static const String _credits10Id = 'credits_10';
  static const String _credits25Id = 'credits_25';
  static const String _credits50Id = 'credits_50';
  static const String _premiumId = 'premium_membership';
  static const double _firstPurchaseDiscountPercent = 0.20;

  static String getProductId(int credits) {
    switch (credits) {
      case 10:
        return _credits10Id;
      case 25:
        return _credits25Id;
      case 50:
        return _credits50Id;
      default:
        throw Exception('Invalid credit amount');
    }
  }

  final InAppPurchase _iap;
  final UserService _userService;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final StreamController<PurchaseDetails> _purchaseController =
      StreamController<PurchaseDetails>.broadcast();

  // Singleton pattern
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;

  PurchaseService._internal()
      : _iap = InAppPurchase.instance,
        _userService = UserService() {
    _subscription = _iap.purchaseStream.listen(_handlePurchaseUpdates);
  }

  Future<double> _calculateDiscountedPrice(ProductDetails product) async {
    double price =
        double.parse(product.price.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (await _userService.isFirstPurchase()) {
      price = price * (1 - _firstPurchaseDiscountPercent);
    }
    return price;
  }

  Future<List<ProductDetails>> getProducts(
      {bool includeSpecialOffers = false}) async {
    try {
      final bool available = await _iap.isAvailable();
      if (!available) {
        return [];
      }

      final Set<String> ids = {
        _credits10Id,
        _credits25Id,
        _credits50Id,
        _premiumId,
      };

      final ProductDetailsResponse response =
          await _iap.queryProductDetails(ids);
      final products = response.productDetails;

      if (includeSpecialOffers && await _userService.shouldShowSpecialOffer()) {
        await _userService.markSpecialOfferShown();

        for (var product in products) {
          await _calculateDiscountedPrice(product);
        }
      }

      return products;
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        if (await _userService.isFirstPurchase()) {
          await _userService.markFirstPurchaseUsed();
        }

        // Kredi satın alımlarını işle
        if (purchaseDetails.productID.contains('credits')) {
          final credits = _getCreditsFromProductId(purchaseDetails.productID);
          await _userService.addCredits(credits);
        }

        _purchaseController.add(purchaseDetails);
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await _iap.completePurchase(purchaseDetails);
      }
    }
  }

  int _getCreditsFromProductId(String productId) {
    switch (productId) {
      case _credits10Id:
        return 10;
      case _credits25Id:
        return 25;
      case _credits50Id:
        return 50 + 5; // 5 bonus kredi
      default:
        return 0;
    }
  }

  Future<bool> buyCredits(String productId) async {
    try {
      final bool available = await _iap.isAvailable();
      if (!available) {
        return false;
      }

      final ProductDetailsResponse response =
          await _iap.queryProductDetails({productId});
      if (response.notFoundIDs.isNotEmpty) {
        return false;
      }

      final productDetails = response.productDetails.first;
      final purchaseParam = PurchaseParam(productDetails: productDetails);

      return await _iap.buyConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      print('Error buying credits: $e');
      return false;
    }
  }

  Future<bool> buyPremium() async {
    try {
      final bool available = await _iap.isAvailable();
      if (!available) {
        return false;
      }

      final ProductDetailsResponse response =
          await _iap.queryProductDetails({_premiumId});
      if (response.notFoundIDs.isNotEmpty) {
        return false;
      }

      final productDetails = response.productDetails.first;
      final purchaseParam = PurchaseParam(productDetails: productDetails);

      return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      print('Error buying premium: $e');
      return false;
    }
  }

  Future<bool> isPremium() async {
    try {
      final purchases = await _iap.purchaseStream.first;
      return purchases.any((purchase) =>
          purchase.productID == _premiumId &&
          purchase.status == PurchaseStatus.purchased);
    } catch (e) {
      print('Error checking premium status: $e');
      return false;
    }
  }

  Stream<PurchaseDetails> get purchaseStream => _purchaseController.stream;

  void dispose() {
    _subscription.cancel();
    _purchaseController.close();
  }
}
