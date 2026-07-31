import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/itinerary.dart';
import '../../../data/repositories/itinerary_repository.dart';

part 'plan_event.dart';
part 'plan_state.dart';

class PlanBloc extends Bloc<PlanEvent, PlanState> {
  final ItineraryRepository _itineraryRepository;

  PlanBloc(this._itineraryRepository) : super(const PlanState()) {
    on<PlanStarted>(_onStarted);
    on<PlanDaySelected>(_onDaySelected);
  }

  Future<void> _onStarted(PlanStarted event, Emitter<PlanState> emit) async {
    emit(state.copyWith(status: PlanStatus.loading));
    try {
      final days = await _itineraryRepository.getItinerary();
      emit(state.copyWith(status: PlanStatus.ready, days: days));
    } catch (_) {
      emit(state.copyWith(status: PlanStatus.failure));
    }
  }

  void _onDaySelected(PlanDaySelected event, Emitter<PlanState> emit) {
    emit(state.copyWith(selectedDayIndex: event.dayIndex));
  }
}
