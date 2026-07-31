import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_app/data/models/itinerary.dart';
import 'package:frontend_app/data/models/trip.dart';
import 'package:frontend_app/data/repositories/itinerary_repository.dart';
import 'package:frontend_app/logic/blocs/plan/plan_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockItineraryRepository extends Mock implements ItineraryRepository {}

ItineraryActivity activity(String id, {String time = '9:00 AM'}) =>
    ItineraryActivity(id: id, time: time, title: id, category: 'History');

Trip tripWith(List<ItineraryDay> days, {DateTime? endDate}) => Trip(
  id: 't1',
  ownerId: 'u1',
  title: 'Rwanda run',
  startDate: DateTime(2026, 8, 1),
  endDate: endDate ?? DateTime(2026, 8, 2),
  groupSize: 2,
  budget: 250000,
  interests: const ['History'],
  status: 'active',
  shareCode: 'ABC123',
  days: days,
  updatedAt: DateTime(2026, 7, 1),
);

ItineraryDay day(int number, List<ItineraryActivity> activities) =>
    ItineraryDay(day: number, title: 'Around Kigali', activities: activities);

void main() {
  late MockItineraryRepository repository;

  final memorial = activity('memorial');
  final market = activity('market', time: '12:30 PM');
  final inema = activity('inema', time: '3:30 PM');

  final loadedTrip = tripWith([
    day(1, [memorial, market]),
    day(2, [inema]),
  ]);

  PlanState ready(Trip? trip, {int selectedDayIndex = 0}) => PlanState(
    status: PlanStatus.ready,
    trip: trip,
    selectedDayIndex: selectedDayIndex,
  );

  setUpAll(() {
    // mocktail's any() needs a fallback for every non-primitive type it stands
    // in for — here Trip, and createPlan's DateTime and List<String> arguments.
    registerFallbackValue(loadedTrip);
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    repository = MockItineraryRepository();
    // Saving echoes the trip back, the way the real repository does.
    when(() => repository.saveTrip(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments.first as Trip,
    );
    when(() => repository.deletePlan(any())).thenAnswer((_) async {});
  });

  group('loading', () {
    blocTest<PlanBloc, PlanState>(
      'emits loading then the saved plan',
      build: () {
        when(
          () => repository.getCurrentTrip(),
        ).thenAnswer((_) async => loadedTrip);
        return PlanBloc(repository);
      },
      act: (bloc) => bloc.add(const PlanStarted()),
      expect: () => [
        const PlanState(status: PlanStatus.loading),
        ready(loadedTrip),
      ],
    );

    blocTest<PlanBloc, PlanState>(
      'ends up ready with no plan when the traveller has never made one',
      build: () {
        when(() => repository.getCurrentTrip()).thenAnswer((_) async => null);
        return PlanBloc(repository);
      },
      act: (bloc) => bloc.add(const PlanStarted()),
      expect: () => [
        const PlanState(status: PlanStatus.loading),
        ready(null),
      ],
      verify: (bloc) => expect(bloc.state.hasPlan, isFalse),
    );

    blocTest<PlanBloc, PlanState>(
      'surfaces a message when the plan cannot be read',
      build: () {
        when(() => repository.getCurrentTrip()).thenThrow(Exception('offline'));
        return PlanBloc(repository);
      },
      act: (bloc) => bloc.add(const PlanStarted()),
      expect: () => [
        const PlanState(status: PlanStatus.loading),
        const PlanState(
          status: PlanStatus.failure,
          errorMessage: 'Could not load your plan. Reopen the tab to retry.',
        ),
      ],
    );
  });

  group('creating', () {
    blocTest<PlanBloc, PlanState>(
      'generates a plan and makes it the active one',
      build: () {
        when(
          () => repository.createPlan(
            title: any(named: 'title'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            groupSize: any(named: 'groupSize'),
            budget: any(named: 'budget'),
            interests: any(named: 'interests'),
          ),
        ).thenAnswer((_) async => loadedTrip);
        return PlanBloc(repository);
      },
      act: (bloc) => bloc.add(
        PlanCreated(
          title: 'Rwanda run',
          startDate: DateTime(2026, 8, 1),
          endDate: DateTime(2026, 8, 2),
          groupSize: 2,
          budget: 250000,
          interests: const ['History'],
        ),
      ),
      expect: () => [
        const PlanState(status: PlanStatus.saving),
        ready(loadedTrip),
      ],
    );
  });

  group('editing activities', () {
    blocTest<PlanBloc, PlanState>(
      'adds an activity to the end of the selected day',
      build: () => PlanBloc(repository),
      seed: () => ready(loadedTrip),
      act: (bloc) => bloc.add(
        PlanActivityAdded(dayIndex: 0, activity: activity('lunch')),
      ),
      expect: () {
        final updated = tripWith([
          day(1, [memorial, market, activity('lunch')]),
          day(2, [inema]),
        ]);
        return [
          PlanState(status: PlanStatus.saving, trip: updated),
          ready(updated),
        ];
      },
      verify: (_) => verify(() => repository.saveTrip(any())).called(1),
    );

    blocTest<PlanBloc, PlanState>(
      'replaces the activity that shares the edited id',
      build: () => PlanBloc(repository),
      seed: () => ready(loadedTrip),
      act: (bloc) => bloc.add(
        PlanActivityEdited(
          dayIndex: 0,
          activity: memorial.copyWith(time: '11:00 AM', title: 'Memorial tour'),
        ),
      ),
      expect: () {
        final updated = tripWith([
          day(1, [
            memorial.copyWith(time: '11:00 AM', title: 'Memorial tour'),
            market,
          ]),
          day(2, [inema]),
        ]);
        return [
          PlanState(status: PlanStatus.saving, trip: updated),
          ready(updated),
        ];
      },
    );

    blocTest<PlanBloc, PlanState>(
      'removes an activity by id',
      build: () => PlanBloc(repository),
      seed: () => ready(loadedTrip),
      act: (bloc) => bloc.add(
        const PlanActivityRemoved(dayIndex: 0, activityId: 'memorial'),
      ),
      expect: () {
        final updated = tripWith([
          day(1, [market]),
          day(2, [inema]),
        ]);
        return [
          PlanState(status: PlanStatus.saving, trip: updated),
          ready(updated),
        ];
      },
    );

    blocTest<PlanBloc, PlanState>(
      'leaves the plan alone when the day index is out of range',
      build: () => PlanBloc(repository),
      seed: () => ready(loadedTrip),
      act: (bloc) => bloc.add(
        const PlanActivityRemoved(dayIndex: 7, activityId: 'memorial'),
      ),
      expect: () => [
        PlanState(status: PlanStatus.saving, trip: loadedTrip),
        ready(loadedTrip),
      ],
    );
  });

  group('reordering', () {
    final three = tripWith([
      day(1, [memorial, market, inema]),
    ]);

    blocTest<PlanBloc, PlanState>(
      'moves an activity to the end, normalising the drag index',
      build: () => PlanBloc(repository),
      seed: () => ready(three),
      // ReorderableListView reports newIndex 3 for "drop after the last item".
      act: (bloc) => bloc.add(
        const PlanActivitiesReordered(dayIndex: 0, oldIndex: 0, newIndex: 3),
      ),
      expect: () {
        final updated = tripWith([
          day(1, [market, inema, memorial]),
        ]);
        return [
          PlanState(status: PlanStatus.saving, trip: updated),
          ready(updated),
        ];
      },
    );

    blocTest<PlanBloc, PlanState>(
      'moves an activity upwards without shifting the target',
      build: () => PlanBloc(repository),
      seed: () => ready(three),
      act: (bloc) => bloc.add(
        const PlanActivitiesReordered(dayIndex: 0, oldIndex: 2, newIndex: 0),
      ),
      expect: () {
        final updated = tripWith([
          day(1, [inema, memorial, market]),
        ]);
        return [
          PlanState(status: PlanStatus.saving, trip: updated),
          ready(updated),
        ];
      },
    );
  });

  group('trip details', () {
    blocTest<PlanBloc, PlanState>(
      'extending the dates appends free days',
      build: () => PlanBloc(repository),
      seed: () => ready(loadedTrip),
      act: (bloc) => bloc.add(
        PlanDetailsEdited(
          title: 'Longer run',
          startDate: DateTime(2026, 8, 1),
          endDate: DateTime(2026, 8, 4),
          groupSize: 4,
          budget: 400000,
        ),
      ),
      verify: (bloc) {
        final trip = bloc.state.trip!;
        expect(trip.title, 'Longer run');
        expect(trip.groupSize, 4);
        expect(trip.days, hasLength(4));
        expect(trip.days.last.activities, isEmpty);
        // The first two days keep everything that was already planned.
        expect(trip.days.first.activities, [memorial, market]);
      },
    );

    blocTest<PlanBloc, PlanState>(
      'shortening the dates drops the trailing days and reselects a valid one',
      build: () => PlanBloc(repository),
      seed: () => ready(loadedTrip, selectedDayIndex: 1),
      act: (bloc) => bloc.add(
        PlanDetailsEdited(
          title: 'Rwanda run',
          startDate: DateTime(2026, 8, 1),
          endDate: DateTime(2026, 8, 1),
          groupSize: 2,
          budget: 250000,
        ),
      ),
      verify: (bloc) {
        expect(bloc.state.trip!.days, hasLength(1));
        expect(bloc.state.selectedDayIndex, 0);
      },
    );
  });

  group('deleting', () {
    blocTest<PlanBloc, PlanState>(
      'clears the active plan',
      build: () => PlanBloc(repository),
      seed: () => ready(loadedTrip),
      act: (bloc) => bloc.add(const PlanDeleted()),
      expect: () => [
        PlanState(status: PlanStatus.saving, trip: loadedTrip),
        ready(null),
      ],
      verify: (_) => verify(() => repository.deletePlan(loadedTrip)).called(1),
    );

    blocTest<PlanBloc, PlanState>(
      'does nothing when there is no plan to delete',
      build: () => PlanBloc(repository),
      seed: () => ready(null),
      act: (bloc) => bloc.add(const PlanDeleted()),
      expect: () => <PlanState>[],
    );
  });

  group('day selection', () {
    blocTest<PlanBloc, PlanState>(
      'selects a day that exists',
      build: () => PlanBloc(repository),
      seed: () => ready(loadedTrip),
      act: (bloc) => bloc.add(const PlanDaySelected(1)),
      expect: () => [ready(loadedTrip, selectedDayIndex: 1)],
      verify: (bloc) => expect(bloc.state.selectedDay, loadedTrip.days[1]),
    );

    blocTest<PlanBloc, PlanState>(
      'ignores a day beyond the end of the plan',
      build: () => PlanBloc(repository),
      seed: () => ready(loadedTrip),
      act: (bloc) => bloc.add(const PlanDaySelected(9)),
      expect: () => <PlanState>[],
    );
  });
}
