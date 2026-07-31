import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/itinerary.dart';
import '../../../data/models/trip.dart';
import '../../../data/repositories/itinerary_repository.dart';
import '../../services/itinerary_generator.dart';

part 'plan_event.dart';
part 'plan_state.dart';

/// Owns the active plan for the whole app — the Home summary, the Plan tab,
/// Saved Itineraries and the QR screen all read the trip from here, so an edit
/// in one place can never leave another showing stale numbers.
class PlanBloc extends Bloc<PlanEvent, PlanState> {
  final ItineraryRepository _itineraryRepository;

  PlanBloc(this._itineraryRepository) : super(const PlanState()) {
    on<PlanStarted>(_onStarted);
    on<PlanDaySelected>(_onDaySelected);
    on<PlanCreated>(_onCreated);
    on<PlanDetailsEdited>(_onDetailsEdited);
    on<PlanActivityAdded>(_onActivityAdded);
    on<PlanActivityEdited>(_onActivityEdited);
    on<PlanActivityRemoved>(_onActivityRemoved);
    on<PlanActivitiesReordered>(_onActivitiesReordered);
    on<PlanDeleted>(_onDeleted);
  }

  Future<void> _onStarted(PlanStarted event, Emitter<PlanState> emit) async {
    emit(state.copyWith(status: PlanStatus.loading));
    try {
      final trip = await _itineraryRepository.getCurrentTrip();
      emit(
        state.copyWith(
          status: PlanStatus.ready,
          trip: trip,
          clearTrip: trip == null,
          selectedDayIndex: 0,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: PlanStatus.failure,
          errorMessage: 'Could not load your plan. Reopen the tab to retry.',
        ),
      );
    }
  }

  void _onDaySelected(PlanDaySelected event, Emitter<PlanState> emit) {
    if (event.dayIndex < 0 || event.dayIndex >= state.days.length) return;
    emit(state.copyWith(selectedDayIndex: event.dayIndex));
  }

  Future<void> _onCreated(PlanCreated event, Emitter<PlanState> emit) async {
    emit(state.copyWith(status: PlanStatus.saving));
    try {
      final trip = await _itineraryRepository.createPlan(
        title: event.title,
        startDate: event.startDate,
        endDate: event.endDate,
        groupSize: event.groupSize,
        budget: event.budget,
        interests: event.interests,
      );
      emit(
        state.copyWith(
          status: PlanStatus.ready,
          trip: trip,
          selectedDayIndex: 0,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: PlanStatus.failure,
          errorMessage: 'Could not create your plan. Try again.',
        ),
      );
    }
  }

  Future<void> _onDetailsEdited(
    PlanDetailsEdited event,
    Emitter<PlanState> emit,
  ) {
    return _save(emit, (trip) {
      final dayCount = ItineraryGenerator.dayCountFor(
        event.startDate,
        event.endDate,
      );
      return trip.copyWith(
        title: event.title,
        startDate: event.startDate,
        endDate: event.endDate,
        groupSize: event.groupSize,
        budget: event.budget,
        days: ItineraryGenerator.resize(trip.days, dayCount),
      );
    });
  }

  Future<void> _onActivityAdded(
    PlanActivityAdded event,
    Emitter<PlanState> emit,
  ) {
    return _saveDay(
      emit,
      event.dayIndex,
      (activities) => [...activities, event.activity],
    );
  }

  Future<void> _onActivityEdited(
    PlanActivityEdited event,
    Emitter<PlanState> emit,
  ) {
    return _saveDay(
      emit,
      event.dayIndex,
      (activities) => [
        for (final a in activities)
          if (a.id == event.activity.id) event.activity else a,
      ],
    );
  }

  Future<void> _onActivityRemoved(
    PlanActivityRemoved event,
    Emitter<PlanState> emit,
  ) {
    return _saveDay(
      emit,
      event.dayIndex,
      (activities) =>
          activities.where((a) => a.id != event.activityId).toList(),
    );
  }

  Future<void> _onActivitiesReordered(
    PlanActivitiesReordered event,
    Emitter<PlanState> emit,
  ) {
    return _saveDay(emit, event.dayIndex, (activities) {
      if (event.oldIndex < 0 || event.oldIndex >= activities.length) {
        return activities;
      }
      final reordered = [...activities];
      final moved = reordered.removeAt(event.oldIndex);
      // ReorderableListView reports newIndex before the item is lifted out.
      var target = event.newIndex > event.oldIndex
          ? event.newIndex - 1
          : event.newIndex;
      if (target < 0) target = 0;
      if (target > reordered.length) target = reordered.length;
      reordered.insert(target, moved);
      return reordered;
    });
  }

  Future<void> _onDeleted(PlanDeleted event, Emitter<PlanState> emit) async {
    final trip = state.trip;
    if (trip == null) return;
    emit(state.copyWith(status: PlanStatus.saving));
    try {
      await _itineraryRepository.deletePlan(trip);
      emit(
        state.copyWith(
          status: PlanStatus.ready,
          clearTrip: true,
          selectedDayIndex: 0,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: PlanStatus.failure,
          errorMessage: 'Could not delete your plan. Try again.',
        ),
      );
    }
  }

  /// Applies [change], shows it immediately, then persists. The optimistic
  /// emit keeps drag-to-reorder from snapping back while the write lands.
  Future<void> _save(
    Emitter<PlanState> emit,
    Trip Function(Trip trip) change,
  ) async {
    final current = state.trip;
    if (current == null) return;

    final updated = change(current);
    // Trimming the trip can leave the selected day pointing past the end.
    final lastIndex = updated.days.isEmpty ? 0 : updated.days.length - 1;
    final dayIndex = state.selectedDayIndex > lastIndex
        ? lastIndex
        : state.selectedDayIndex;
    emit(
      state.copyWith(
        status: PlanStatus.saving,
        trip: updated,
        selectedDayIndex: dayIndex,
      ),
    );

    try {
      final saved = await _itineraryRepository.saveTrip(updated);
      emit(state.copyWith(status: PlanStatus.ready, trip: saved));
    } catch (_) {
      emit(
        state.copyWith(
          status: PlanStatus.failure,
          errorMessage: 'Could not save your change. Try again.',
        ),
      );
    }
  }

  Future<void> _saveDay(
    Emitter<PlanState> emit,
    int dayIndex,
    List<ItineraryActivity> Function(List<ItineraryActivity> activities) change,
  ) {
    return _save(emit, (trip) {
      if (dayIndex < 0 || dayIndex >= trip.days.length) return trip;
      final days = [...trip.days];
      days[dayIndex] = days[dayIndex].copyWith(
        activities: change(days[dayIndex].activities),
      );
      return trip.copyWith(days: days);
    });
  }
}
