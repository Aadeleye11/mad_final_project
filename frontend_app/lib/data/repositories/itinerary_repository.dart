import '../models/trip.dart';

/// Mock itinerary store. Will hold locally persisted trips once the
/// Build-a-Plan feature exists; for now it returns the demo trip.
class ItineraryRepository {
  Future<Trip?> getCurrentTrip() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Trip(
      id: 't1',
      name: 'Rwanda Trip',
      startDate: DateTime(2026, 6, 18),
      endDate: DateTime(2026, 6, 23),
      activitiesCount: 12,
    );
  }
}
