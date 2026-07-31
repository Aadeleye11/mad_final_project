import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String uid;
  final String name;
  final String email;
  final List<String> defaultInterests;

  const User({
    required this.uid,
    required this.name,
    required this.email,
    required this.defaultInterests,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return User(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      defaultInterests: List<String>.from(data['defaultInterests'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'defaultInterests': defaultInterests,
    };
  }

  @override
  List<Object> get props => [uid, name, email, defaultInterests];
}