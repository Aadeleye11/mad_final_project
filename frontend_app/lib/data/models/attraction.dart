import 'package:equatable/equatable.dart';

class Attraction extends Equatable {
  final String id;
  final String name;
  final String category;
  final double rating;
  final String location;
  final String description;

  const Attraction({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.location,
    this.description = '',
  });

  factory Attraction.fromJson(Map<String, dynamic> json) {
    return Attraction(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      rating: (json['rating'] as num).toDouble(),
      location: json['location'] as String,
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'rating': rating,
        'location': location,
        'description': description,
      };

  @override
  List<Object> get props => [id, name, category, rating, location, description];
}
