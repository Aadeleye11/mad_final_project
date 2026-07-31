import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'itinerary.dart';

class Trip extends Equatable {
  final String id;
  final String ownerId;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final int groupSize;
  final double budget;
  final List<String> interests;
  final String status;
  final String shareCode;

  /// The itinerary itself, embedded rather than kept in a subcollection: it is
  /// a handful of days, and one document means one offline read and one write.
  final List<ItineraryDay> days;

  /// Used to pick the most recent plan when a user has more than one.
  final DateTime updatedAt;

  const Trip({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.groupSize,
    required this.budget,
    required this.interests,
    required this.status,
    required this.shareCode,
    required this.updatedAt,
    this.days = const [],
  });

  /// Stand-in for plans written before `updatedAt` existed, so they sort last.
  static final DateTime _epoch = DateTime.utc(1970);

  Trip copyWith({
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    int? groupSize,
    double? budget,
    List<String>? interests,
    String? status,
    List<ItineraryDay>? days,
    DateTime? updatedAt,
  }) {
    return Trip(
      id: id,
      ownerId: ownerId,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      groupSize: groupSize ?? this.groupSize,
      budget: budget ?? this.budget,
      interests: interests ?? this.interests,
      status: status ?? this.status,
      shareCode: shareCode,
      days: days ?? this.days,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Trip.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Trip(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      title: data['title'] ?? '',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      groupSize: data['groupSize'] ?? 1,
      budget: (data['budget'] as num?)?.toDouble() ?? 0.0,
      interests: List<String>.from(data['interests'] ?? []),
      status: data['status'] ?? 'draft',
      shareCode: data['shareCode'] ?? '',
      days: (data['days'] as List<dynamic>? ?? [])
          .map((d) => ItineraryDay.fromJson(d as Map<String, dynamic>))
          .toList(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? _epoch,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'title': title,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'groupSize': groupSize,
      'budget': budget,
      'interests': interests,
      'status': status,
      'shareCode': shareCode,
      'days': days.map((d) => d.toJson()).toList(),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Plain JSON for the SharedPreferences mirror, which has no Timestamp type.
  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      startDate:
          DateTime.tryParse(json['startDate'] as String? ?? '') ??
          DateTime.now(),
      endDate:
          DateTime.tryParse(json['endDate'] as String? ?? '') ?? DateTime.now(),
      groupSize: (json['groupSize'] as num?)?.toInt() ?? 1,
      budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
      interests: List<String>.from(json['interests'] ?? []),
      status: json['status'] as String? ?? 'draft',
      shareCode: json['shareCode'] as String? ?? '',
      days: (json['days'] as List<dynamic>? ?? [])
          .map((d) => ItineraryDay.fromJson(d as Map<String, dynamic>))
          .toList(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? _epoch,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ownerId': ownerId,
    'title': title,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'groupSize': groupSize,
    'budget': budget,
    'interests': interests,
    'status': status,
    'shareCode': shareCode,
    'days': days.map((d) => d.toJson()).toList(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  int get durationDays => endDate.difference(startDate).inDays + 1;

  String get name => title;

  int get activitiesCount =>
      days.fold(0, (total, day) => total + day.activities.length);

  @override
  List<Object> get props => [
    id,
    ownerId,
    title,
    startDate,
    endDate,
    groupSize,
    budget,
    interests,
    status,
    shareCode,
    days,
    updatedAt,
  ];
}
