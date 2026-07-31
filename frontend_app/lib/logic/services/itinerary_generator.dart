import '../../data/models/itinerary.dart';
import '../../features/discover/domain/entities/attraction.dart';

/// Turns a date range plus the traveller's interests into a day-by-day
/// itinerary drawn from the attraction catalogue.
///
/// Pure Dart and deterministic — the same inputs always produce the same plan,
/// so it can be unit tested without Firebase or a widget tree.
class ItineraryGenerator {
  ItineraryGenerator._();

  /// Interest labels shown during onboarding, mapped onto catalogue categories.
  static const Map<String, AttractionCategory> interestCategories = {
    'Gorillas & Wildlife': AttractionCategory.wildlife,
    'Culture & Art': AttractionCategory.culture,
    'Food & Markets': AttractionCategory.food,
    'History': AttractionCategory.history,
    'Lakes & Nature': AttractionCategory.nature,
    'Adventure Sports': AttractionCategory.adventure,
  };

  /// Three stops a day leaves room to travel between districts.
  static const List<String> slots = ['9:00 AM', '12:30 PM', '3:30 PM'];

  /// A generated plan past two weeks stops being useful and starts repeating.
  static const int maxDays = 14;

  static List<ItineraryDay> build({
    required DateTime startDate,
    required DateTime endDate,
    required List<String> interests,
    required List<Attraction> catalogue,
  }) {
    final dayCount = dayCountFor(startDate, endDate);
    final picks = rank(interests, catalogue);

    final days = <ItineraryDay>[];
    var next = 0;

    for (var dayIndex = 0; dayIndex < dayCount; dayIndex++) {
      final chosen = <Attraction>[];
      for (var slot = 0; slot < slots.length && picks.isNotEmpty; slot++) {
        // Wrapping only repeats a place once every other one has been used.
        chosen.add(picks[next % picks.length]);
        next++;
      }

      days.add(
        ItineraryDay(
          day: dayIndex + 1,
          title: _dayTitle(chosen),
          activities: [
            for (var i = 0; i < chosen.length; i++)
              ItineraryActivity(
                id: '${chosen[i].id}-d$dayIndex-s$i',
                time: slots[i],
                title: chosen[i].name,
                category: chosen[i].category.label,
                attractionId: chosen[i].id,
              ),
          ],
        ),
      );
    }

    return days;
  }

  /// Inclusive of both ends, clamped so a mis-typed date can't build 400 days.
  static int dayCountFor(DateTime startDate, DateTime endDate) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    final span = end.difference(start).inDays + 1;
    if (span < 1) return 1;
    return span > maxDays ? maxDays : span;
  }

  /// Attractions matching the chosen interests, best rated first. Falls back to
  /// the whole catalogue so an unmatched interest never yields an empty plan.
  static List<Attraction> rank(
    List<String> interests,
    List<Attraction> catalogue,
  ) {
    final wanted = interests
        .map((i) => interestCategories[i])
        .whereType<AttractionCategory>()
        .toSet();

    var matching = wanted.isEmpty
        ? catalogue
        : catalogue.where((a) => wanted.contains(a.category)).toList();
    if (matching.isEmpty) matching = catalogue;

    // Name breaks rating ties so the output is stable across runs.
    return [...matching]..sort((a, b) {
      final byRating = b.rating.compareTo(a.rating);
      return byRating != 0 ? byRating : a.name.compareTo(b.name);
    });
  }

  /// Keeps the plan in step with its date range when the trip is re-dated:
  /// adds free days, or drops trailing ones.
  static List<ItineraryDay> resize(List<ItineraryDay> days, int dayCount) {
    if (days.length == dayCount) return days;
    if (days.length > dayCount) return days.take(dayCount).toList();
    return [
      ...days,
      for (var i = days.length; i < dayCount; i++)
        ItineraryDay(day: i + 1, title: 'Free day', activities: const []),
    ];
  }

  static String _dayTitle(List<Attraction> chosen) {
    if (chosen.isEmpty) return 'Free day';
    final districts = <String>{
      for (final a in chosen)
        if (a.district.isNotEmpty) a.district,
    }.toList();
    if (districts.isEmpty) return chosen.first.name;
    if (districts.length == 1) return 'Around ${districts.first}';
    return districts.take(2).join(' & ');
  }
}
