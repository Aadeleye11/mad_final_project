part of 'plan_bloc.dart';

abstract class PlanEvent extends Equatable {
  const PlanEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the active plan, from Firestore when reachable and the local mirror
/// otherwise.
class PlanStarted extends PlanEvent {
  const PlanStarted();
}

class PlanDaySelected extends PlanEvent {
  final int dayIndex;

  const PlanDaySelected(this.dayIndex);

  @override
  List<Object?> get props => [dayIndex];
}

/// Generates an itinerary from [interests] and saves it as the active plan.
class PlanCreated extends PlanEvent {
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final int groupSize;
  final double budget;
  final List<String> interests;

  const PlanCreated({
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.groupSize,
    required this.budget,
    required this.interests,
  });

  @override
  List<Object?> get props => [
    title,
    startDate,
    endDate,
    groupSize,
    budget,
    interests,
  ];
}

/// Trip-level edits. Changing the dates grows or trims the day list to match.
class PlanDetailsEdited extends PlanEvent {
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final int groupSize;
  final double budget;

  const PlanDetailsEdited({
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.groupSize,
    required this.budget,
  });

  @override
  List<Object?> get props => [title, startDate, endDate, groupSize, budget];
}

class PlanActivityAdded extends PlanEvent {
  final int dayIndex;
  final ItineraryActivity activity;

  const PlanActivityAdded({required this.dayIndex, required this.activity});

  @override
  List<Object?> get props => [dayIndex, activity];
}

/// Replaces the activity sharing [activity]'s id.
class PlanActivityEdited extends PlanEvent {
  final int dayIndex;
  final ItineraryActivity activity;

  const PlanActivityEdited({required this.dayIndex, required this.activity});

  @override
  List<Object?> get props => [dayIndex, activity];
}

class PlanActivityRemoved extends PlanEvent {
  final int dayIndex;
  final String activityId;

  const PlanActivityRemoved({required this.dayIndex, required this.activityId});

  @override
  List<Object?> get props => [dayIndex, activityId];
}

/// Indices arrive straight from `ReorderableListView`, whose `newIndex` counts
/// the dragged item as still in place. The bloc normalises them.
class PlanActivitiesReordered extends PlanEvent {
  final int dayIndex;
  final int oldIndex;
  final int newIndex;

  const PlanActivitiesReordered({
    required this.dayIndex,
    required this.oldIndex,
    required this.newIndex,
  });

  @override
  List<Object?> get props => [dayIndex, oldIndex, newIndex];
}

class PlanDeleted extends PlanEvent {
  const PlanDeleted();
}
