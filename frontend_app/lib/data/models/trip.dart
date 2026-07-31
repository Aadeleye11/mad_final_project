import 'package:equatable/equatable.dart';

class Trip extends Equatable {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final int activitiesCount;

  const Trip({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.activitiesCount,
  });

  int get durationDays => endDate.difference(startDate).inDays + 1;

  @override
  List<Object> get props => [id, name, startDate, endDate, activitiesCount];
}
