import '../models/attraction.dart';

/// Mock attraction catalog. Later this becomes the offline-first
/// store synced from a backend (spots bundled for offline use).
class AttractionsRepository {
  static const List<Attraction> _attractions = [
    Attraction(
      id: 'a1',
      name: 'Volcanoes National Park',
      category: 'Gorillas & Wildlife',
      rating: 4.8,
      location: 'Musanze',
      description: 'Home of the mountain gorillas and golden monkeys.',
    ),
    Attraction(
      id: 'a2',
      name: 'Lake Kivu',
      category: 'Lakes & Nature',
      rating: 4.7,
      location: 'Rubavu',
      description: 'One of Africa\'s Great Lakes, with beaches and islands.',
    ),
    Attraction(
      id: 'a3',
      name: 'Kigali Genocide Memorial',
      category: 'History',
      rating: 4.9,
      location: 'Kigali',
      description: 'Memorial honouring the victims of the 1994 genocide.',
    ),
    Attraction(
      id: 'a4',
      name: 'Nyungwe Forest',
      category: 'Gorillas & Wildlife',
      rating: 4.6,
      location: 'Rusizi',
      description: 'Ancient rainforest with a canopy walkway and chimps.',
    ),
    Attraction(
      id: 'a5',
      name: 'Kimironko Market',
      category: 'Food & Markets',
      rating: 4.5,
      location: 'Kigali',
      description: 'Kigali\'s largest market — best on Saturday mornings.',
    ),
    Attraction(
      id: 'a6',
      name: 'Inema Arts Center',
      category: 'Culture & Art',
      rating: 4.7,
      location: 'Kigali',
      description: 'Contemporary art collective and gallery.',
    ),
  ];

  Future<List<Attraction>> getFeaturedSpots() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final sorted = List<Attraction>.from(_attractions)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(4).toList();
  }

  Future<List<Attraction>> getAllAttractions() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _attractions;
  }
}
