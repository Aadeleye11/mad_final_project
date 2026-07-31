import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/itinerary.dart';
import '../models/trip.dart';

class ItineraryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _generateShortId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  Future<void> createTripPlan({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required int groupSize,
    required double budget,
    required List<String> interests,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not authenticated");

    await _firestore.collection('trips').add({
      'ownerId': uid,
      'title': title,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'groupSize': groupSize,
      'budget': budget,
      'interests': interests,
      'status': 'draft',
      'shareCode': _generateShortId(),
    });
  }

  Future<Trip?> getCurrentTrip() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final snapshot = await _firestore
        .collection('trips')
        .where('ownerId', isEqualTo: uid)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return Trip.fromFirestore(snapshot.docs.first);
    }
    return null;
  }

  Stream<QuerySnapshot> getLegs(String tripId) {
    return _firestore
        .collection('trips')
        .doc(tripId)
        .collection('legs')
        .orderBy('order')
        .snapshots();
  }

  Stream<QuerySnapshot> getActivities(String tripId, String legId) {
    return _firestore
        .collection('trips')
        .doc(tripId)
        .collection('legs')
        .doc(legId)
        .collection('activities')
        .orderBy('time')
        .snapshots();
  }

  Future<List<ItineraryDay>> getItinerary() async {
    return [];
  }
}