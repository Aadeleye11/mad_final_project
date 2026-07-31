import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/attraction.dart';
import '../bloc/discover_bloc.dart';
import '../widgets/attraction_image.dart';

const _weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

// Kept out of the domain entity, which must stay pure Dart.
IconData _categoryIcon(AttractionCategory category) => switch (category) {
  AttractionCategory.wildlife => Icons.pets,
  AttractionCategory.culture => Icons.palette_outlined,
  AttractionCategory.food => Icons.restaurant_outlined,
  AttractionCategory.history => Icons.account_balance_outlined,
  AttractionCategory.nature => Icons.landscape_outlined,
  AttractionCategory.adventure => Icons.hiking,
};

/// Reads from state the BLoC already holds, so it works offline.
class AttractionDetailPage extends StatelessWidget {
  final String attractionId;
  const AttractionDetailPage({super.key, required this.attractionId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoverBloc, DiscoverState>(
      builder: (context, state) {
        final matches = state.all.where((a) => a.id == attractionId);
        if (matches.isEmpty) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('That place is no longer listed.')),
          );
        }
        return _DetailBody(attraction: matches.first);
      },
    );
  }
}

class _DetailBody extends StatelessWidget {
  final Attraction attraction;
  const _DetailBody({required this.attraction});

  String get _bestDaysLabel {
    final days = attraction.bestDays.where((d) => d >= 1 && d <= 7).toList();
    if (days.isEmpty) return 'Any day';
    return days.map((d) => _weekdayNames[d - 1]).join(', ');
  }

  Future<void> _openInMaps(BuildContext context) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=${attraction.latitude},${attraction.longitude}',
    );
    final messenger = ScaffoldMessenger.of(context);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Could not open Maps.')));
    }
  }

  void _share() {
    SharePlus.instance.share(
      ShareParams(
        text:
            '${attraction.name} (${attraction.district}) — '
            '${attraction.description}\n\nDiscovered on RwandaGo.',
        subject: attraction.name,
      ),
    );
  }

  void _showAddedDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to plan'),
        content: Text(
          '${attraction.name} will be added once you have an active trip.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: _ScrimButton(
              icon: Icons.arrow_back,
              onTap: () => Navigator.of(context).pop(),
            ),
            actions: [
              _ScrimButton(icon: Icons.share_outlined, onTap: _share),
              const SizedBox(width: 8),
            ],
            // M3's expanded title ignores AppBarTheme, so color is set explicitly.
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: Text(
                attraction.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black87)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    position: DecorationPosition.foreground,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                        stops: [0.5, 1.0],
                      ),
                    ),
                    child: Hero(
                      tag: 'attraction-image-${attraction.id}',
                      child: AttractionImage(imageUrl: attraction.imageUrl),
                    ),
                  ),
                  Positioned(
                    top: 64,
                    right: 16,
                    child: _RatingPill(rating: attraction.rating),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: _categoryIcon(attraction.category),
                          label: 'Category',
                          value: attraction.category.label,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.place_outlined,
                          label: 'District',
                          value: attraction.district,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.event_outlined,
                          label: 'Best day',
                          value: _bestDaysLabel,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'About',
                    style: theme.textTheme.titleLarge?.copyWith(
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
                  if (attraction.localTip != null) ...[
                    const SizedBox(height: 20),
                    _LocalTip(tip: attraction.localTip!),
                  ],
                  const SizedBox(height: 28),
                  Text(
                    'Location',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _LocationCard(
                    attraction: attraction,
                    onDirections: () => _openInMaps(context),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size.fromHeight(52),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => _showAddedDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add to my plan'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dark backdrop guarantees contrast regardless of the photo behind it.
class _ScrimButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ScrimButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.black45,
        child: IconButton(
          constraints: const BoxConstraints.tightFor(width: 48, height: 48),
          icon: Icon(icon, color: Colors.white),
          onPressed: onTap,
        ),
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  final double rating;
  const _RatingPill({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 16, color: Color(0xFFF5A623)),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final Attraction attraction;
  final VoidCallback onDirections;

  const _LocationCard({required this.attraction, required this.onDirections});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryLight,
            child: Icon(Icons.map_outlined, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attraction.district,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${attraction.latitude.toStringAsFixed(4)}, '
                  '${attraction.longitude.toStringAsFixed(4)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
            onPressed: onDirections,
            icon: const Icon(Icons.directions_outlined, size: 18),
            label: const Text('Directions'),
          ),
        ],
      ),
    );
  }
}

/// The local knowledge generic travel platforms don't surface.
class _LocalTip extends StatelessWidget {
  final String tip;
  const _LocalTip({required this.tip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 20,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tip,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
