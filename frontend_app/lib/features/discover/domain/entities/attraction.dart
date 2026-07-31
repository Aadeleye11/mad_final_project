import 'package:equatable/equatable.dart';

/// A single point of interest. Pure Dart — no Firebase, no Flutter — so it is
/// cheap to unit test and safe to cache offline.
class Attraction extends Equatable {
  final String id;
  final String name;
  final String description;
  final AttractionCategory category;
  final double latitude;
  final double longitude;
  final double rating;
  final String imageUrl;
  final String district;

  /// Free text like "Best on Saturday mornings" — the local knowledge the
  /// user interviews said generic platforms never surface.
  final String? localTip;

  /// Days this place is worth visiting, 1 = Monday. Empty means any day.
  final List<int> bestDays;

  const Attraction({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.imageUrl,
    required this.district,
    this.localTip,
    this.bestDays = const [],
  });

  @override
  List<Object?> get props => [id, name, category, latitude, longitude, rating];
}

enum AttractionCategory {
  wildlife,
  culture,
  food,
  history,
  nature,
  adventure;

  String get label => switch (this) {
    AttractionCategory.wildlife => 'Wildlife',
    AttractionCategory.culture => 'Culture',
    AttractionCategory.food => 'Food',
    AttractionCategory.history => 'History',
    AttractionCategory.nature => 'Nature',
    AttractionCategory.adventure => 'Adventure',
  };

  static AttractionCategory fromString(String value) =>
      AttractionCategory.values.firstWhere(
        (c) => c.name == value,
        orElse: () => AttractionCategory.culture,
      );
}
