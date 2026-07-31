part of 'plan_bloc.dart';

enum PlanStatus { initial, loading, ready, failure }

class PlanState extends Equatable {
  final PlanStatus status;
  final List<ItineraryDay> days;
  final int selectedDayIndex;

  const PlanState({
    this.status = PlanStatus.initial,
    this.days = const [],
    this.selectedDayIndex = 0,
  });

  ItineraryDay? get selectedDay =>
      selectedDayIndex < days.length ? days[selectedDayIndex] : null;

  PlanState copyWith({
    PlanStatus? status,
    List<ItineraryDay>? days,
    int? selectedDayIndex,
  }) {
    return PlanState(
      status: status ?? this.status,
      days: days ?? this.days,
      selectedDayIndex: selectedDayIndex ?? this.selectedDayIndex,
    );
  }

  @override
  List<Object> get props => [status, days, selectedDayIndex];
}
