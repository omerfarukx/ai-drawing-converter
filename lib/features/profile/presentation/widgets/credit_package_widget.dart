import 'package:flutter/material.dart';

class _CreditPackage extends StatelessWidget {
  final int credits;
  final String price;
  final bool isPopular;
  final VoidCallback onTap;

  const _CreditPackage({
    required this.credits,
    required this.price,
    this.isPopular = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPopular
                ? [const Color(0xFFFFA726), const Color(0xFFFFB74D)]
                : [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05)
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPopular
                ? const Color(0xFFFFA726).withOpacity(0.5)
                : Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            if (isPopular)
              BoxShadow(
                color: const Color(0xFFFFA726).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$credits',
                style: TextStyle(
                  color:
                      isPopular ? Colors.white : Colors.white.withOpacity(0.9),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kredi',
              style: TextStyle(
                color: isPopular ? Colors.white : Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: TextStyle(
                color: isPopular ? Colors.white : Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isPopular) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'En İyi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
