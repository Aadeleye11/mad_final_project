part of 'plan_bloc.dart';

enum PlanStatus { initial, loading, ready, saving, failure }

class PlanState extends Equatable {
  final PlanStatus status;

  /// The active plan, or null when the traveller hasn't created one yet.
  final Trip? trip;

  final int selectedDayIndex;
  final String? errorMessage;

  const PlanState({
    this.status = PlanStatus.initial,
    this.trip,
    this.selectedDayIndex = 0,
    this.errorMessage,
  });

  bool get hasPlan => trip != null;

  List<ItineraryDay> get days => trip?.days ?? const [];

  ItineraryDay? get selectedDay =>
      selectedDayIndex < days.length ? days[selectedDayIndex] : null;

  PlanState copyWith({
    PlanStatus? status,
    Trip? trip,
    bool clearTrip = false,
    int? selectedDayIndex,
    String? errorMessage,
  }) {
    return PlanState(
      status: status ?? this.status,
      trip: clearTrip ? null : (trip ?? this.trip),
      selectedDayIndex: selectedDayIndex ?? this.selectedDayIndex,
      // Not carried forward: an old message must not re-trigger a snack bar.
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, trip, selectedDayIndex, errorMessage];
}
