part of 'discover_bloc.dart';

enum DiscoverStatus { initial, loading, success, failure }

class DiscoverState extends Equatable {
  final DiscoverStatus status;

  /// Everything loaded, before filtering, so filtering never re-hits the network.
  final List<Attraction> all;

  /// What the grid actually renders.
  final List<Attraction> visible;

  final AttractionCategory? selectedCategory;
  final String query;
  final String? errorMessage;

  const DiscoverState({
    this.status = DiscoverStatus.initial,
    this.all = const [],
    this.visible = const [],
    this.selectedCategory,
    this.query = '',
    this.errorMessage,
  });

  bool get isEmpty => status == DiscoverStatus.success && visible.isEmpty;

  DiscoverState copyWith({
    DiscoverStatus? status,
    List<Attraction>? all,
    List<Attraction>? visible,
    AttractionCategory? selectedCategory,
    bool clearCategory = false,
    String? query,
    String? errorMessage,
  }) {
    return DiscoverState(
      status: status ?? this.status,
      all: all ?? this.all,
      visible: visible ?? this.visible,
      selectedCategory: clearCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      query: query ?? this.query,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    all,
    visible,
    selectedCategory,
    query,
    errorMessage,
  ];
}
