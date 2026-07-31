import 'package:equatable/equatable.dart';

class ItineraryActivity extends Equatable {
  /// Stable across edits and reorders, so list widgets can key on it.
  final String id;

  /// Display label, e.g. "9:00 AM". Order within a day comes from the list
  /// position, not from this, so reordering never has to rewrite times.
  final String time;

  final String title;
  final String category;

  /// Set when the activity came from the attraction catalogue; empty for
  /// activities the traveller typed in themselves.
  final String attractionId;

  const ItineraryActivity({
    required this.id,
    required this.time,
    required this.title,
    required this.category,
    this.attractionId = '',
  });

  ItineraryActivity copyWith({String? time, String? title, String? category}) {
    return ItineraryActivity(
      id: id,
      time: time ?? this.time,
      title: title ?? this.title,
      category: category ?? this.category,
      attractionId: attractionId,
    );
  }

  factory ItineraryActivity.fromJson(Map<String, dynamic> json) {
    final time = json['time'] as String? ?? '';
    final title = json['title'] as String? ?? '';
    return ItineraryActivity(
      // Plans saved before activities carried ids still have to open.
      id: json['id'] as String? ?? '$time-$title',
      time: time,
      title: title,
      category: json['category'] as String? ?? '',
      attractionId: json['attractionId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'time': time,
    'title': title,
    'category': category,
    'attractionId': attractionId,
  };

  @override
  List<Object> get props => [id, time, title, category, attractionId];
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

  ItineraryDay copyWith({
    int? day,
    String? title,
    List<ItineraryActivity>? activities,
  }) {
    return ItineraryDay(
      day: day ?? this.day,
      title: title ?? this.title,
      activities: activities ?? this.activities,
    );
  }

  factory ItineraryDay.fromJson(Map<String, dynamic> json) {
    return ItineraryDay(
      day: (json['day'] as num?)?.toInt() ?? 1,
      title: json['title'] as String? ?? '',
      activities: (json['activities'] as List<dynamic>? ?? [])
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
