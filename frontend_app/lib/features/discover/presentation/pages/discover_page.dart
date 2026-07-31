import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/discover_bloc.dart';
import '../widgets/attraction_card.dart';
import '../widgets/category_filter_bar.dart';
import 'attraction_detail_page.dart';

/// Discover tab: search, filter by category, browse a responsive grid.
class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover Rwanda')),
      body: BlocConsumer<DiscoverBloc, DiscoverState>(
        // Errors surface as a snack bar; the grid keeps whatever it already had.
        listenWhen: (previous, current) =>
            current.errorMessage != null &&
            previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        },
        builder: (context, state) {
          return Column(
            children: [
              const _SearchField(),
              CategoryFilterBar(
                selected: state.selectedCategory,
                onSelected: (category) => context.read<DiscoverBloc>().add(
                  DiscoverCategorySelected(category),
                ),
              ),
              Expanded(child: _Results(state: state)),
            ],
          );
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search places, districts or categories',
          prefixIcon: Icon(Icons.search),
        ),
        textInputAction: TextInputAction.search,
        onChanged: (value) =>
            context.read<DiscoverBloc>().add(DiscoverSearchChanged(value)),
      ),
    );
  }
}

class _Results extends StatelessWidget {
  final DiscoverState state;
  const _Results({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.status == DiscoverStatus.loading && state.visible.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.isEmpty) {
      return _EmptyState(query: state.query);
    }

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<DiscoverBloc>().add(const DiscoverRefreshed()),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive columns keep the grid from overflowing on rotation.
          final columns = (constraints.maxWidth ~/ 180).clamp(2, 4);
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.78,
            ),
            itemCount: state.visible.length,
            itemBuilder: (context, index) {
              final attraction = state.visible[index];
              return AttractionCard(
                attraction: attraction,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        AttractionDetailPage(attractionId: attraction.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.travel_explore_outlined,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              query.isEmpty
                  ? 'No places in this category yet.'
                  : 'Nothing matches "$query".',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Try a different category or search term.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
