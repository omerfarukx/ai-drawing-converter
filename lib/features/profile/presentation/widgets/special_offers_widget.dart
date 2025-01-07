import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:yapayzeka_cizim/core/services/purchase_service.dart';
import 'package:yapayzeka_cizim/core/services/user_service.dart';

class SpecialOffersWidget extends StatelessWidget {
  final PurchaseService _purchaseService;
  final UserService _userService;

  const SpecialOffersWidget({
    Key? key,
    required PurchaseService purchaseService,
    required UserService userService,
  })  : _purchaseService = purchaseService,
        _userService = userService,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _userService.shouldShowSpecialOffer(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🎉 Özel Teklif!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                FutureBuilder<bool>(
                  future: _userService.isFirstPurchase(),
                  builder: (context, isFirstPurchase) {
                    if (isFirstPurchase.data ?? false) {
                      return const Text(
                        'İlk alışverişinize özel %20 indirim!',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.green,
                        ),
                      );
                    }
                    return const Text(
                      'Bu haftaya özel fırsatlar!',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.green,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<ProductDetails>>(
                  future:
                      _purchaseService.getProducts(includeSpecialOffers: true),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final product = snapshot.data![index];
                        return ListTile(
                          title: Text(product.title),
                          subtitle: Text(product.description),
                          trailing: ElevatedButton(
                            onPressed: () {
                              if (product.id.contains('credits')) {
                                _purchaseService.buyCredits(product.id);
                              } else {
                                _purchaseService.buyPremium();
                              }
                            },
                            child: Text(product.price),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _userService.inviteFriend(),
                  icon: const Icon(Icons.share),
                  label: const Text('Arkadaşını Davet Et (2 Kredi Kazan!)'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
