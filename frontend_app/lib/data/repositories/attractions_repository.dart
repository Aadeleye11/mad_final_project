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
      description:
          'Home of the endangered mountain gorillas and golden monkeys, '
          'set across five of the eight Virunga volcanoes. Gorilla trekking '
          'permits must be booked months in advance and treks are guided '
          'in small groups through bamboo forest.',
      bestTime: 'Jun – Sep',
      duration: 'Full day',
      entryFee: r'$1,500 permit',
      distance: '2h from Kigali',
      imageAsset: 'assets/images/a1_volcanoes.jpg',
    ),
    Attraction(
      id: 'a2',
      name: 'Lake Kivu',
      category: 'Lakes & Nature',
      rating: 4.7,
      location: 'Rubavu',
      description:
          'One of Africa\'s Great Lakes, ringed by green hills, beaches '
          'and hot springs. Kayak at sunrise, cycle the Congo Nile Trail, '
          'or take a boat trip between lakeside towns and islands.',
      bestTime: 'Year-round',
      duration: '1–2 days',
      entryFee: 'Free',
      distance: '3.5h from Kigali',
      imageAsset: 'assets/images/a2_lake_kivu.jpg',
    ),
    Attraction(
      id: 'a3',
      name: 'Kigali Genocide Memorial',
      category: 'History',
      rating: 4.9,
      location: 'Kigali',
      description:
          'The national memorial honouring the victims of the 1994 '
          'Genocide against the Tutsi. Moving exhibitions, gardens and '
          'an education centre make this an essential, sobering visit '
          'for understanding Rwanda\'s history.',
      bestTime: 'Weekday mornings',
      duration: '2–3 hours',
      entryFee: 'Free (donations)',
      distance: 'In Kigali',
      imageAsset: 'assets/images/a3_genocide_memorial.jpg',
    ),
    Attraction(
      id: 'a4',
      name: 'Nyungwe Forest',
      category: 'Gorillas & Wildlife',
      rating: 4.6,
      location: 'Rusizi',
      description:
          'One of Africa\'s oldest rainforests, famous for chimpanzee '
          'trekking, 13 primate species and East Africa\'s only canopy '
          'walkway suspended 60 metres above the forest floor.',
      bestTime: 'Jun – Sep',
      duration: 'Full day',
      entryFee: r'$100 – $250',
      distance: '5h from Kigali',
      imageAsset: 'assets/images/a4_nyungwe.jpg',
    ),
    Attraction(
      id: 'a5',
      name: 'Kimironko Market',
      category: 'Food & Markets',
      rating: 4.5,
      location: 'Kigali',
      description:
          'Kigali\'s largest and liveliest market — fresh produce, '
          'fabrics, crafts and tailors who can sew custom clothing in a '
          'day. Locals say Saturday morning is the best time to go.',
      bestTime: 'Saturday morning',
      duration: '1–2 hours',
      entryFee: 'Free',
      distance: 'In Kigali',
      imageAsset: 'assets/images/a5_kimironko.jpg',
    ),
    Attraction(
      id: 'a6',
      name: 'Inema Arts Center',
      category: 'Culture & Art',
      rating: 4.7,
      location: 'Kigali',
      description:
          'A contemporary art collective founded by two brothers, '
          'showcasing paintings, sculpture and dance from resident '
          'artists. Thursday evenings feature live music and open '
          'studios.',
      bestTime: 'Thu evenings',
      duration: '1–2 hours',
      entryFee: 'Free',
      distance: 'In Kigali',
      imageAsset: 'assets/images/a6_inema.jpg',
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
