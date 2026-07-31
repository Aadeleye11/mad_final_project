import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

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
  });

  factory Trip.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Trip(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      title: data['title'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      groupSize: data['groupSize'] ?? 1,
      budget: (data['budget'] as num?)?.toDouble() ?? 0.0,
      interests: List<String>.from(data['interests'] ?? []),
      status: data['status'] ?? 'draft',
      shareCode: data['shareCode'] ?? '',
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
    };
  }

  int get durationDays => endDate.difference(startDate).inDays + 1;

  String get name => title;

  int get activitiesCount => 0;

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
      ];
}