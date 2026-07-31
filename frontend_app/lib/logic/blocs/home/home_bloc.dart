import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/usecases/usecase.dart';
import '../../../features/discover/domain/entities/attraction.dart';
import '../../../features/discover/domain/usecases/get_attractions.dart';

part 'home_event.dart';
part 'home_state.dart';

/// Featured spots only. The trip summary the dashboard shows comes from
/// [PlanBloc], which owns the plan.
///
/// Sourced from the same Discover catalogue [DiscoverBloc] uses (Firestore ->
/// local cache -> bundled seed), so the dashboard gets real photos and works
/// offline instead of relying on its own separate Firestore query. There's no
/// explicit "featured" flag on the catalogue entity, so the top-rated places
/// stand in for it.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetAttractions _getAttractions;

  HomeBloc(this._getAttractions) : super(const HomeState()) {
    on<HomeStarted>(_onStarted);
  }

  static const _featuredCount = 6;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    final result = await _getAttractions(const NoParams());
    result.fold((failure) => emit(state.copyWith(status: HomeStatus.failure)), (
      attractions,
    ) {
      final featured = [...attractions]
        ..sort((a, b) => b.rating.compareTo(a.rating));
      emit(
        state.copyWith(
          status: HomeStatus.ready,
          featuredSpots: featured.take(_featuredCount).toList(),
        ),
      );
    });
  }
}
