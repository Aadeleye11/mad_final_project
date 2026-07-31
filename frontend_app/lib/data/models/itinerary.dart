import 'package:equatable/equatable.dart';

class ItineraryActivity extends Equatable {
  final String time;
  final String title;
  final String category;

  const ItineraryActivity({
    required this.time,
    required this.title,
    required this.category,
  });

  factory ItineraryActivity.fromJson(Map<String, dynamic> json) {
    return ItineraryActivity(
      time: json['time'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'time': time,
    'title': title,
    'category': category,
  };

  @override
  List<Object> get props => [time, title, category];
}

class ItineraryDay extends Equatable {
  final int day;
  final String title;
  final List<ItineraryActivity> activities;

  const ItineraryDay({
    required this.day,
    required this.title,
    required this.activities,
  });

  factory ItineraryDay.fromJson(Map<String, dynamic> json) {
    return ItineraryDay(
      day: json['day'] as int,
      title: json['title'] as String,
      activities: (json['activities'] as List)
          .map((a) => ItineraryActivity.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'day': day,
    'title': title,
    'activities': activities.map((a) => a.toJson()).toList(),
  };

  @override
  List<Object> get props => [day, title, activities];
}
