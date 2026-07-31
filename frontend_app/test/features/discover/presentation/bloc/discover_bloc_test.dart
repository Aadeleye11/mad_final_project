import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend_app/core/error/failures.dart';
import 'package:frontend_app/core/usecases/usecase.dart';
import 'package:frontend_app/features/discover/domain/entities/attraction.dart';
import 'package:frontend_app/features/discover/domain/usecases/get_attractions.dart';
import 'package:frontend_app/features/discover/presentation/bloc/discover_bloc.dart';

class MockGetAttractions extends Mock implements GetAttractions {}

void main() {
  late MockGetAttractions getAttractions;

  const gorillas = Attraction(
    id: 'volcanoes-np',
    name: 'Volcanoes National Park',
    description: '',
    category: AttractionCategory.wildlife,
    latitude: 0,
    longitude: 0,
    rating: 4.8,
    imageUrl: '',
    district: 'Musanze',
  );

  const market = Attraction(
    id: 'kimironko-market',
    name: 'Kimironko Market',
    description: '',
    category: AttractionCategory.food,
    latitude: 0,
    longitude: 0,
    rating: 4.5,
    imageUrl: '',
    district: 'Gasabo',
  );

  setUp(() {
    getAttractions = MockGetAttractions();
    registerFallbackValue(const NoParams());
  });

  blocTest<DiscoverBloc, DiscoverState>(
    'emits loading then success with everything visible',
    build: () {
      when(
        () => getAttractions(any()),
      ).thenAnswer((_) async => const Right([gorillas, market]));
      return DiscoverBloc(getAttractions: getAttractions);
    },
    act: (bloc) => bloc.add(const DiscoverStarted()),
    expect: () => [
      const DiscoverState(status: DiscoverStatus.loading),
      const DiscoverState(
        status: DiscoverStatus.success,
        all: [gorillas, market],
        visible: [gorillas, market],
      ),
    ],
  );

  blocTest<DiscoverBloc, DiscoverState>(
    'filters the visible list down to the selected category',
    build: () {
      when(
        () => getAttractions(any()),
      ).thenAnswer((_) async => const Right([gorillas, market]));
      return DiscoverBloc(getAttractions: getAttractions);
    },
    act: (bloc) async {
      bloc.add(const DiscoverStarted());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const DiscoverCategorySelected(AttractionCategory.food));
    },
    skip: 2,
    expect: () => [
      const DiscoverState(
        status: DiscoverStatus.success,
        all: [gorillas, market],
        visible: [market],
        selectedCategory: AttractionCategory.food,
      ),
    ],
  );

  blocTest<DiscoverBloc, DiscoverState>(
    'search matches on district as well as name',
    build: () {
      when(
        () => getAttractions(any()),
      ).thenAnswer((_) async => const Right([gorillas, market]));
      return DiscoverBloc(getAttractions: getAttractions);
    },
    act: (bloc) async {
      bloc.add(const DiscoverStarted());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const DiscoverSearchChanged('musanze'));
    },
    skip: 2,
    expect: () => [
      const DiscoverState(
        status: DiscoverStatus.success,
        all: [gorillas, market],
        visible: [gorillas],
        query: 'musanze',
      ),
    ],
  );

  blocTest<DiscoverBloc, DiscoverState>(
    'surfaces a message when loading fails',
    build: () {
      when(
        () => getAttractions(any()),
      ).thenAnswer((_) async => const Left(CacheFailure('Nothing cached.')));
      return DiscoverBloc(getAttractions: getAttractions);
    },
    act: (bloc) => bloc.add(const DiscoverStarted()),
    expect: () => [
      const DiscoverState(status: DiscoverStatus.loading),
      const DiscoverState(
        status: DiscoverStatus.failure,
        errorMessage: 'Nothing cached.',
      ),
    ],
  );
}
