import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/attraction.dart';
import '../bloc/discover_bloc.dart';
import '../widgets/attraction_image.dart';

/// Detail view for one attraction, resolved from state the BLoC already holds
/// so it renders instantly and works with no connectivity.
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                attraction.name,
                style: const TextStyle(fontSize: 16),
              ),
              background: AttractionImage(imageUrl: attraction.imageUrl),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.list(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text(attraction.category.label)),
                    Chip(label: Text(attraction.district)),
                    Chip(
                      avatar: const Icon(Icons.star, size: 16),
                      label: Text(attraction.rating.toStringAsFixed(1)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(attraction.description, style: theme.textTheme.bodyMedium),
                if (attraction.localTip != null) ...[
                  const SizedBox(height: 20),
                  _LocalTip(tip: attraction.localTip!),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => _showAddedDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add to my plan'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Placeholder until the trips slice exposes its "add stop" use case.
  /// Wiring happens through that contract, not by reaching into its code.
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
}

/// The local knowledge that generic travel platforms miss — the differentiator
/// the user interviews kept pointing at.
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
