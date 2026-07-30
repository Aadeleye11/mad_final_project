import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/attraction.dart';
import '../../widgets/spot_card.dart';

/// Spot detail page, following the Figma design: photo hero with a
/// floating back button, teal title band (name, rating, distance),
/// About section, Key Information cards and a pill-shaped CTA.
/// Expects the [Attraction] via route arguments.
class AttractionDetailScreen extends StatelessWidget {
  const AttractionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final attraction =
        ModalRoute.of(context)!.settings.arguments as Attraction;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.42,
                        width: double.infinity,
                        child: SpotCard.spotImage(attraction, iconSize: 80),
                      ),
                      // Fade the bottom of the photo into the teal title
                      // band so they blend like in the design.
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 120,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.primary.withValues(alpha: 0),
                                AppColors.primary,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        left: 16,
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
                          child: BackButton(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Teal title band under the photo, like the design.
                  Container(
                    width: double.infinity,
                    color: AppColors.primary,
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attraction.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              attraction.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.place_outlined,
                              size: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              attraction.distance,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'About',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          attraction.description,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Key Information',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _KeyInfoCard(
                              icon: Icons.wb_sunny_outlined,
                              label: 'Best time',
                              value: attraction.bestTime,
                            ),
                            const SizedBox(width: 12),
                            _KeyInfoCard(
                              icon: Icons.confirmation_number_outlined,
                              label: 'Entry fee',
                              value: attraction.entryFee,
                            ),
                            const SizedBox(width: 12),
                            _KeyInfoCard(
                              icon: Icons.place_outlined,
                              label: 'Location',
                              value: attraction.location,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Trip planning coming soon'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                },
                child: const Text('Add to My Plan'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _KeyInfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primary,
              child: Icon(icon, size: 24, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
