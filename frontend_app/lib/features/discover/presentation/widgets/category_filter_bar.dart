import 'package:flutter/material.dart';

import '../../domain/entities/attraction.dart';

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
      height: 48,
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
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(value),
        showCheckmark: false,
      ),
    );
  }
}
