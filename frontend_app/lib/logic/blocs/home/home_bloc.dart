import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/attraction.dart';
import '../../../data/repositories/attractions_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

/// Featured spots only. The trip summary the dashboard shows comes from
/// [PlanBloc], which owns the plan.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AttractionsRepository _attractionsRepository;

  HomeBloc(this._attractionsRepository) : super(const HomeState()) {
    on<HomeStarted>(_onStarted);
  }

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final spots = await _attractionsRepository.getFeaturedSpots();
      emit(state.copyWith(status: HomeStatus.ready, featuredSpots: spots));
    } catch (_) {
      emit(state.copyWith(status: HomeStatus.failure));
    }
  }
}
