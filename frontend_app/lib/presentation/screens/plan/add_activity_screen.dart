import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/itinerary.dart';
import '../../../features/discover/presentation/bloc/discover_bloc.dart';
import '../../../features/discover/presentation/widgets/attraction_image.dart';
import 'activity_editor_sheet.dart';

/// Picks the next activity for a day, either from the attraction catalogue or
/// as a free-text entry. Pops with the chosen [ItineraryActivity], or null.
///
/// The catalogue comes from [DiscoverBloc], which has already resolved it from
/// Firestore, its cache, or the bundled seed — so this list works offline too.
class AddActivityScreen extends StatelessWidget {
  /// Time proposed for the new activity, based on how full the day already is.
  final String suggestedTime;

  const AddActivityScreen({super.key, required this.suggestedTime});

  ItineraryActivity _draft({
    required String title,
    required String category,
    String attractionId = '',
  }) {
    final stamp = DateTime.now().microsecondsSinceEpoch;
    return ItineraryActivity(
      id: attractionId.isEmpty ? 'custom-$stamp' : '$attractionId-$stamp',
      time: suggestedTime,
      title: title,
      category: category,
      attractionId: attractionId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add activity'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
      ),
      body: BlocBuilder<DiscoverBloc, DiscoverState>(
        builder: (context, state) {
          final attractions = state.all;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.edit_outlined, color: Colors.white),
                  ),
                  title: const Text('Write your own'),
                  subtitle: const Text('A meal, a transfer, anything else'),
                  onTap: () async {
                    final activity = await showActivityEditor(
                      context,
                      activity: _draft(title: '', category: 'Travel'),
                      heading: 'New activity',
                    );
                    if (activity != null && context.mounted) {
                      Navigator.of(context).pop(activity);
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                attractions.isEmpty
                    ? 'No places loaded yet — open Discover once to fill the '
                          'catalogue.'
                    : 'From the catalogue',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              for (final attraction in attractions)
                Card(
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
                    leading: SizedBox(
                      width: 56,
                      height: 56,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AttractionImage(imageUrl: attraction.imageUrl),
                      ),
                    ),
                    title: Text(
                      attraction.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '${attraction.category.label} · ${attraction.district}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () async {
                      final activity = await showActivityEditor(
                        context,
                        activity: _draft(
                          title: attraction.name,
                          category: attraction.category.label,
                          attractionId: attraction.id,
                        ),
                        heading: 'Add to your plan',
                      );
                      if (activity != null && context.mounted) {
                        Navigator.of(context).pop(activity);
                      }
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
