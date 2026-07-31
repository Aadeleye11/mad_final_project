import '../models/itinerary.dart';
import '../models/trip.dart';

/// Mock store; returns the demo trip until Build-a-Plan persists real ones.
class ItineraryRepository {
  static const List<ItineraryDay> _days = [
    ItineraryDay(
      day: 1,
      title: 'Arrival & Kigali Exploration',
      activities: [
        ItineraryActivity(
          time: '9:00 AM',
          title: 'Kigali Genocide Memorial',
          category: 'History',
        ),
        ItineraryActivity(
          time: '12:00 PM',
          title: 'Inema Arts Center',
          category: 'Culture',
        ),
        ItineraryActivity(
          time: '3:00 PM',
          title: 'Kimironko Market',
          category: 'Food',
        ),
        ItineraryActivity(
          time: '6:00 PM',
          title: 'Heaven Restaurant',
          category: 'Food',
        ),
      ],
    ),
    ItineraryDay(
      day: 2,
      title: 'Volcanoes National Park',
      activities: [
        ItineraryActivity(
          time: '6:00 AM',
          title: 'Transfer to Musanze',
          category: 'Travel',
        ),
        ItineraryActivity(
          time: '9:00 AM',
          title: 'Gorilla Trekking',
          category: 'Wildlife',
        ),
        ItineraryActivity(
          time: '5:00 PM',
          title: 'Dinner at the lodge',
          category: 'Food',
        ),
      ],
    ),
    ItineraryDay(
      day: 3,
      title: 'Lake Kivu Relaxation',
      activities: [
        ItineraryActivity(
          time: '8:00 AM',
          title: 'Drive to Rubavu',
          category: 'Travel',
        ),
        ItineraryActivity(
          time: '11:00 AM',
          title: 'Boat trip on Lake Kivu',
          category: 'Nature',
        ),
        ItineraryActivity(
          time: '5:00 PM',
          title: 'Sunset kayaking',
          category: 'Adventure',
        ),
      ],
    ),
    ItineraryDay(
      day: 4,
      title: 'Departure',
      activities: [
        ItineraryActivity(
          time: '9:00 AM',
          title: 'Craft shopping at Caplaki',
          category: 'Culture',
        ),
        ItineraryActivity(
          time: '1:00 PM',
          title: 'Airport transfer',
          category: 'Travel',
        ),
      ],
    ),
  ];

  Future<Trip?> getCurrentTrip() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final activities = _days.fold<int>(
      0,
      (sum, d) => sum + d.activities.length,
    );
    return Trip(
      id: 't1',
      name: 'Rwanda Trip',
      startDate: DateTime(2026, 6, 18),
      endDate: DateTime(2026, 6, 23),
      activitiesCount: activities,
    );
  }

  Future<List<ItineraryDay>> getItinerary() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _days;
  }
}
