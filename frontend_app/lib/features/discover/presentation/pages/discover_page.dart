import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
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
      backgroundColor: AppColors.background,
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
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<DiscoverBloc>().add(const DiscoverRefreshed()),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _DiscoverHeader(resultCount: state.visible.length),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 4),
                    child: CategoryFilterBar(
                      selected: state.selectedCategory,
                      onSelected: (category) => context
                          .read<DiscoverBloc>()
                          .add(DiscoverCategorySelected(category)),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                _Results(state: state),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Gradient hero matching the look of the Home and Profile tabs, with the
/// search field sitting on it like a floating pill.
class _DiscoverHeader extends StatelessWidget {
  final int resultCount;
  const _DiscoverHeader({required this.resultCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Discover Rwanda',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            resultCount == 0
                ? 'Find your next adventure'
                : '$resultCount ${resultCount == 1 ? 'place' : 'places'} to explore',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 18),
          const _SearchField(),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search places, districts or categories',
          hintStyle: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (state.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _EmptyState(query: state.query),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          // Responsive columns keep the grid from overflowing on rotation.
          final columns = (constraints.crossAxisExtent ~/ 180).clamp(2, 4);
          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.78,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
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
            }, childCount: state.visible.length),
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
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.travel_explore_outlined,
                size: 34,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              query.isEmpty
                  ? 'No places in this category yet.'
                  : 'Nothing matches "$query".',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Try a different category or search term.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
