import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/attraction.dart';

class SpotCard extends StatelessWidget {
  final Attraction attraction;
  final VoidCallback? onTap;

  const SpotCard({super.key, required this.attraction, this.onTap});

  static IconData categoryIcon(String category) {
    switch (category) {
      case 'Gorillas & Wildlife':
        return Icons.pets;
      case 'Culture & Art':
        return Icons.palette_outlined;
      case 'Food & Markets':
        return Icons.storefront_outlined;
      case 'History':
        return Icons.account_balance_outlined;
      case 'Lakes & Nature':
        return Icons.water_outlined;
      case 'Adventure Sports':
        return Icons.hiking;
      default:
        return Icons.place_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 168,
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: AppColors.surface,
        elevation: 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder until real photos are bundled as assets
              // (offline-first: avoid depending on network images).
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primaryLight, AppColors.primary],
                    ),
                  ),
                  child: Icon(
                    categoryIcon(attraction.category),
                    size: 40,
                    color: Colors.white70,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attraction.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          attraction.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
