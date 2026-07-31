import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/attraction.dart';
import '../../../data/models/trip.dart';
import '../../../data/repositories/attractions_repository.dart';
import '../../../data/repositories/itinerary_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AttractionsRepository _attractionsRepository;
  final ItineraryRepository _itineraryRepository;

  HomeBloc(this._attractionsRepository, this._itineraryRepository)
    : super(const HomeState()) {
    on<HomeStarted>(_onStarted);
  }

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final results = await Future.wait([
        _itineraryRepository.getCurrentTrip(),
        _attractionsRepository.getFeaturedSpots(),
      ]);
      emit(
        state.copyWith(
          status: HomeStatus.ready,
          trip: results[0] as Trip?,
          featuredSpots: results[1] as List<Attraction>,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: HomeStatus.failure));
    }
  }
}
