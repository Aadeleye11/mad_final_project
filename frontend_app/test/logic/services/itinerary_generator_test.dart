import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_app/features/discover/domain/entities/attraction.dart';
import 'package:frontend_app/logic/services/itinerary_generator.dart';

Attraction attraction(
  String id,
  AttractionCategory category, {
  double rating = 4.0,
  String district = 'Kigali',
}) {
  return Attraction(
    id: id,
    name: id,
    description: '',
    category: category,
    latitude: 0,
    longitude: 0,
    rating: rating,
    imageUrl: '',
    district: district,
  );
}

void main() {
  final catalogue = [
    attraction('gorillas', AttractionCategory.wildlife, rating: 4.8,
        district: 'Musanze'),
    attraction('kivu', AttractionCategory.nature, rating: 4.7,
        district: 'Rubavu'),
    attraction('memorial', AttractionCategory.history, rating: 4.9),
    attraction('market', AttractionCategory.food, rating: 4.5),
    attraction('inema', AttractionCategory.culture, rating: 4.4),
  ];

  final start = DateTime(2026, 8, 1);

  group('dayCountFor', () {
    test('counts both ends of the range', () {
      expect(ItineraryGenerator.dayCountFor(start, start), 1);
      expect(
        ItineraryGenerator.dayCountFor(start, DateTime(2026, 8, 4)),
        4,
      );
    });

    test('ignores the time of day', () {
      expect(
        ItineraryGenerator.dayCountFor(
          DateTime(2026, 8, 1, 23, 30),
          DateTime(2026, 8, 2, 0, 15),
        ),
        2,
      );
    });

    test('clamps a range that would generate an unusable plan', () {
      expect(
        ItineraryGenerator.dayCountFor(start, DateTime(2027, 8, 1)),
        ItineraryGenerator.maxDays,
      );
      expect(
        ItineraryGenerator.dayCountFor(start, DateTime(2026, 7, 1)),
        1,
      );
    });
  });

  group('rank', () {
    test('keeps only the categories behind the chosen interests', () {
      final ranked = ItineraryGenerator.rank(['History', 'Food'], catalogue);

      expect(ranked.map((a) => a.id), ['memorial', 'market']);
    });

    test('orders by rating, best first', () {
      final ranked = ItineraryGenerator.rank(const [], catalogue);

      expect(ranked.first.id, 'memorial');
      expect(ranked.last.id, 'inema');
    });

    test('falls back to everything when no interest matches', () {
      final ranked = ItineraryGenerator.rank(['Not a category'], catalogue);

      expect(ranked, hasLength(catalogue.length));
    });
  });

  group('build', () {
    test('produces one day per date, numbered from one', () {
      final days = ItineraryGenerator.build(
        startDate: start,
        endDate: DateTime(2026, 8, 3),
        interests: const [],
        catalogue: catalogue,
      );

      expect(days, hasLength(3));
      expect(days.map((d) => d.day), [1, 2, 3]);
    });

    test('fills each day with three timed activities', () {
      final days = ItineraryGenerator.build(
        startDate: start,
        endDate: start,
        interests: const [],
        catalogue: catalogue,
      );

      expect(days.single.activities, hasLength(3));
      expect(
        days.single.activities.map((a) => a.time),
        ItineraryGenerator.slots,
      );
    });

    test('draws only on the chosen interests', () {
      final days = ItineraryGenerator.build(
        startDate: start,
        endDate: start,
        interests: ['Gorillas & Wildlife'],
        catalogue: catalogue,
      );

      expect(
        days.single.activities.every((a) => a.attractionId == 'gorillas'),
        isTrue,
      );
    });

    test('uses every matching place before repeating one', () {
      final days = ItineraryGenerator.build(
        startDate: start,
        endDate: start,
        interests: const [],
        catalogue: catalogue,
      );

      final ids = days.single.activities.map((a) => a.attractionId).toSet();
      expect(ids, hasLength(3));
    });

    test('gives every activity a unique id', () {
      final days = ItineraryGenerator.build(
        startDate: start,
        endDate: DateTime(2026, 8, 4),
        interests: const [],
        catalogue: catalogue,
      );

      final ids = days.expand((d) => d.activities).map((a) => a.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
    });

    test('is deterministic', () {
      List<String> run() => ItineraryGenerator.build(
        startDate: start,
        endDate: DateTime(2026, 8, 4),
        interests: const ['History', 'Food'],
        catalogue: catalogue,
      ).expand((d) => d.activities).map((a) => a.title).toList();

      expect(run(), run());
    });

    test('still returns days when the catalogue is empty', () {
      final days = ItineraryGenerator.build(
        startDate: start,
        endDate: DateTime(2026, 8, 2),
        interests: const [],
        catalogue: const [],
      );

      expect(days, hasLength(2));
      expect(days.every((d) => d.activities.isEmpty), isTrue);
      expect(days.first.title, 'Free day');
    });
  });

  group('resize', () {
    final days = ItineraryGenerator.build(
      startDate: start,
      endDate: DateTime(2026, 8, 3),
      interests: const [],
      catalogue: catalogue,
    );

    test('appends free days when the trip is extended', () {
      final resized = ItineraryGenerator.resize(days, 5);

      expect(resized, hasLength(5));
      expect(resized.take(3), days);
      expect(resized.last.activities, isEmpty);
      expect(resized.last.day, 5);
    });

    test('drops trailing days when the trip is shortened', () {
      final resized = ItineraryGenerator.resize(days, 2);

      expect(resized, hasLength(2));
      expect(resized, days.take(2));
    });

    test('leaves an unchanged range alone', () {
      expect(ItineraryGenerator.resize(days, 3), same(days));
    });
  });
}
