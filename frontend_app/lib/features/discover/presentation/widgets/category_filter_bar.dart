import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/attraction.dart';

IconData _categoryIcon(AttractionCategory? category) => switch (category) {
  AttractionCategory.wildlife => Icons.pets,
  AttractionCategory.culture => Icons.palette_outlined,
  AttractionCategory.food => Icons.restaurant_outlined,
  AttractionCategory.history => Icons.account_balance_outlined,
  AttractionCategory.nature => Icons.landscape_outlined,
  AttractionCategory.adventure => Icons.hiking,
  null => Icons.apps_rounded,
};

/// Scrolls rather than wraps, so it never overflows in landscape.
class CategoryFilterBar extends StatelessWidget {
  final AttractionCategory? selected;
  final ValueChanged<AttractionCategory?> onSelected;

  const CategoryFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _chip(context, label: 'All', value: null),
          for (final category in AttractionCategory.values)
            _chip(context, label: category.label, value: category),
        ],
      ),
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required AttractionCategory? value,
  }) {
    final isSelected = selected == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        avatar: Icon(
          _categoryIcon(value),
          size: 16,
          color: isSelected ? Colors.white : AppColors.primary,
        ),
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(value),
        showCheckmark: false,
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        side: BorderSide(
          color: isSelected ? Colors.transparent : const Color(0xFFDDE3E1),
        ),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        elevation: isSelected ? 2 : 0,
        shadowColor: Colors.black26,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      ),
    );
  }
}
