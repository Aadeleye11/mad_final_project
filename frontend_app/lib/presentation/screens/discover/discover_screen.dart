import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Placeholder for the Discover tab (browse & search attractions).
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover Rwanda')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_outlined, size: 64, color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Browse attractions coming soon',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
