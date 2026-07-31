import '../../domain/entities/attraction.dart';

/// Data-layer representation of [Attraction]. Knows about JSON and Firestore
/// so the domain entity does not have to.
class AttractionModel extends Attraction {
  const AttractionModel({
    required super.id,
    required super.name,
    required super.description,
    required super.category,
    required super.latitude,
    required super.longitude,
    required super.rating,
    required super.imageUrl,
    required super.district,
    super.localTip,
    super.bestDays,
  });

  factory AttractionModel.fromJson(Map<String, dynamic> json) {
    return AttractionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      category: AttractionCategory.fromString(
        json['category'] as String? ?? '',
      ),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
      district: json['district'] as String? ?? '',
      localTip: json['localTip'] as String?,
      bestDays: (json['bestDays'] as List<dynamic>? ?? [])
          .map((d) => (d as num).toInt())
          .toList(),
    );
  }

  /// Firestore documents carry the id outside the data map, so it is passed in.
  factory AttractionModel.fromFirestore(Map<String, dynamic> data, String id) {
    return AttractionModel.fromJson({...data, 'id': id});
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category.name,
    'latitude': latitude,
    'longitude': longitude,
    'rating': rating,
    'imageUrl': imageUrl,
    'district': district,
    'localTip': localTip,
    'bestDays': bestDays,
  };
}
