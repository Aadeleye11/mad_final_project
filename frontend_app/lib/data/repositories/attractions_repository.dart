import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/attraction.dart';

class AttractionsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Attraction>> getFeaturedSpots() async {
    final snapshot = await _firestore
        .collection('places')
        .where('featured', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) => Attraction.fromFirestore(doc)).toList();
  }

  Future<List<Attraction>> getAllAttractions() async {
    final snapshot = await _firestore.collection('places').get();
    return snapshot.docs.map((doc) => Attraction.fromFirestore(doc)).toList();
  }
}