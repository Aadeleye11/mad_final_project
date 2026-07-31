import 'package:equatable/equatable.dart';

class Attraction extends Equatable {
  final String id;
  final String name;
  final String category;
  final double rating;
  final String location;
  final String description;
  final String bestTime;
  final String duration;
  final String entryFee;

  /// Travel time from Kigali, e.g. "2h from Kigali" or "In Kigali".
  final String distance;

  /// Bundled asset path, e.g. "assets/images/a1_volcanoes.jpg".
  final String imageAsset;

  const Attraction({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.location,
    this.description = '',
    this.bestTime = '',
    this.duration = '',
    this.entryFee = '',
    this.distance = '',
    this.imageAsset = '',
  });

  factory Attraction.fromJson(Map<String, dynamic> json) {
    return Attraction(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      rating: (json['rating'] as num).toDouble(),
      location: json['location'] as String,
      description: json['description'] as String? ?? '',
      bestTime: json['bestTime'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      entryFee: json['entryFee'] as String? ?? '',
      distance: json['distance'] as String? ?? '',
      imageAsset: json['imageAsset'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'rating': rating,
    'location': location,
    'description': description,
    'bestTime': bestTime,
    'duration': duration,
    'entryFee': entryFee,
    'distance': distance,
    'imageAsset': imageAsset,
  };

  @override
  List<Object> get props => [
    id,
    name,
    category,
    rating,
    location,
    description,
    bestTime,
    duration,
    entryFee,
    distance,
    imageAsset,
  ];
}
