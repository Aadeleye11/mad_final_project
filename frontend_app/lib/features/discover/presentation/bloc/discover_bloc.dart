import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/attraction.dart';
import '../../domain/usecases/get_attractions.dart';

part 'discover_event.dart';
part 'discover_state.dart';

/// Owns every piece of Discover state. No `setState` anywhere in this feature.
///
/// Filtering happens here rather than in the widget so the same rules can be
/// unit tested without pumping a widget tree.
class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  final GetAttractions getAttractions;

  DiscoverBloc({required this.getAttractions}) : super(const DiscoverState()) {
    on<DiscoverStarted>(_onLoad);
    on<DiscoverRefreshed>(_onLoad);
    on<DiscoverCategorySelected>(_onCategorySelected);
    on<DiscoverSearchChanged>(_onSearchChanged);
  }

  Future<void> _onLoad(DiscoverEvent event, Emitter<DiscoverState> emit) async {
    emit(state.copyWith(status: DiscoverStatus.loading));
    final result = await getAttractions(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: DiscoverStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (attractions) => emit(
        state.copyWith(
          status: DiscoverStatus.success,
          all: attractions,
          visible: _apply(attractions, state.selectedCategory, state.query),
        ),
      ),
    );
  }

  void _onCategorySelected(
    DiscoverCategorySelected event,
    Emitter<DiscoverState> emit,
  ) {
    emit(
      state.copyWith(
        selectedCategory: event.category,
        clearCategory: event.category == null,
        visible: _apply(state.all, event.category, state.query),
      ),
    );
  }

  void _onSearchChanged(
    DiscoverSearchChanged event,
    Emitter<DiscoverState> emit,
  ) {
    emit(
      state.copyWith(
        query: event.query,
        visible: _apply(state.all, state.selectedCategory, event.query),
      ),
    );
  }

  /// Category and search stack: picking "Food" then typing narrows within Food.
  static List<Attraction> _apply(
    List<Attraction> source,
    AttractionCategory? category,
    String query,
  ) {
    final needle = query.trim().toLowerCase();
    return source.where((a) {
      final matchesCategory = category == null || a.category == category;
      final matchesQuery =
          needle.isEmpty ||
          a.name.toLowerCase().contains(needle) ||
          a.district.toLowerCase().contains(needle) ||
          a.category.label.toLowerCase().contains(needle);
      return matchesCategory && matchesQuery;
    }).toList();
  }
}
