import 'package:flutter/material.dart';

import '../../domain/entities/attraction.dart';
import 'attraction_image.dart';

/// Grid tile for one attraction: image, name, rating, district.
///
/// The image is a fixed aspect ratio and the text area flexible, so the card
/// cannot overflow when the grid reflows on rotation.
class AttractionCard extends StatelessWidget {
  final Attraction attraction;
  final VoidCallback onTap;

  const AttractionCard({
    super.key,
    required this.attraction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: AttractionImage(imageUrl: attraction.imageUrl),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      attraction.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          attraction.rating.toStringAsFixed(1),
                          style: theme.textTheme.labelMedium,
                        ),
                        const Spacer(),
                        Flexible(
                          child: Text(
                            attraction.district,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
