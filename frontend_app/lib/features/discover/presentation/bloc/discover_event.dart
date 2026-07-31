part of 'discover_bloc.dart';

sealed class DiscoverEvent extends Equatable {
  const DiscoverEvent();
  @override
  List<Object?> get props => [];
}

/// Fired once when the Discover tab opens.
class DiscoverStarted extends DiscoverEvent {
  const DiscoverStarted();
}

/// Pull to refresh — bypasses nothing, just re-runs the load.
class DiscoverRefreshed extends DiscoverEvent {
  const DiscoverRefreshed();
}

class DiscoverCategorySelected extends DiscoverEvent {
  /// null means "All".
  final AttractionCategory? category;
  const DiscoverCategorySelected(this.category);

  @override
  List<Object?> get props => [category];
}

class DiscoverSearchChanged extends DiscoverEvent {
  final String query;
  const DiscoverSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}
