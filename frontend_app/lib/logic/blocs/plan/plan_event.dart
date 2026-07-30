part of 'plan_bloc.dart';

abstract class PlanEvent extends Equatable {
  const PlanEvent();

  @override
  List<Object> get props => [];
}

class PlanStarted extends PlanEvent {
  const PlanStarted();
}

class PlanDaySelected extends PlanEvent {
  final int dayIndex;

  const PlanDaySelected(this.dayIndex);

  @override
  List<Object> get props => [dayIndex];
}
