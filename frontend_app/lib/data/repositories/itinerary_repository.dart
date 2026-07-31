import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/discover/domain/entities/attraction.dart';
import '../../features/discover/domain/repositories/attraction_repository.dart';
import '../../logic/services/itinerary_generator.dart';
import '../models/trip.dart';

/// The plan is written to Firestore and mirrored into SharedPreferences.
///
/// Firestore applies writes to its local cache immediately and syncs them when
/// the network returns, so nothing here awaits the server — a plan created on a
/// bus with no signal is usable straight away. The mirror covers the one case
/// Firestore's own cache can't: a cold install that has never been online.
class ItineraryRepository {
  final SharedPreferences _prefs;
  final AttractionRepository _attractions;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ItineraryRepository({
    required SharedPreferences prefs,
    required AttractionRepository attractions,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _prefs = prefs,
       _attractions = attractions,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  static const String cacheKey = 'cached_trip';
  static const Duration _readTimeout = Duration(seconds: 8);

  CollectionReference<Map<String, dynamic>> get _trips =>
      _firestore.collection('trips');

  String? get _uid => _auth.currentUser?.uid;

  Future<Trip?> getCurrentTrip() async {
    final uid = _uid;
    if (uid == null) return _cachedTrip();

    try {
      final snapshot = await _trips
          .where('ownerId', isEqualTo: uid)
          .get()
          .timeout(_readTimeout);

      if (snapshot.docs.isEmpty) return _cachedTrip();

      // Sorted here rather than in the query so no composite index is needed.
      final trips = snapshot.docs.map(Trip.fromFirestore).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      await _cache(trips.first);
      return trips.first;
    } catch (_) {
      return _cachedTrip();
    }
  }

  /// Builds an itinerary from the traveller's interests and saves it as the
  /// active plan, replacing any previous one.
  Future<Trip> createPlan({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required int groupSize,
    required double budget,
    required List<String> interests,
  }) async {
    final previous = _cachedTrip();

    final trip = Trip(
      // Client-side id, so creating a plan offline doesn't wait on the server.
      id: _trips.doc().id,
      ownerId: _uid ?? '',
      title: title,
      startDate: startDate,
      endDate: endDate,
      groupSize: groupSize,
      budget: budget,
      interests: interests,
      status: 'active',
      shareCode: _generateShareCode(),
      days: ItineraryGenerator.build(
        startDate: startDate,
        endDate: endDate,
        interests: interests,
        catalogue: await _catalogue(),
      ),
      updatedAt: DateTime.now(),
    );

    await _cache(trip);
    _push(_trips.doc(trip.id).set(trip.toMap()));
    if (previous != null && previous.id != trip.id) {
      _push(_trips.doc(previous.id).delete());
    }
    return trip;
  }

  /// Persists an edited plan. Returns the trip with its new `updatedAt`.
  Future<Trip> saveTrip(Trip trip) async {
    final updated = trip.copyWith(updatedAt: DateTime.now());
    await _cache(updated);
    _push(_trips.doc(updated.id).set(updated.toMap()));
    return updated;
  }

  Future<void> deletePlan(Trip trip) async {
    await _prefs.remove(cacheKey);
    _push(_trips.doc(trip.id).delete());
  }

  Future<List<Attraction>> _catalogue() async {
    final result = await _attractions.getAttractions();
    return result.getOrElse(() => const []);
  }

  /// Fire-and-forget: the local write has already happened, and a sync failure
  /// must not surface as an error the traveller can't act on.
  void _push(Future<void> write) {
    unawaited(write.catchError((Object _) {}));
  }

  Trip? _cachedTrip() {
    final raw = _prefs.getString(cacheKey);
    if (raw == null) return null;
    try {
      return Trip.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // A mirror written by an older build shouldn't break the Plan tab.
      return null;
    }
  }

  Future<void> _cache(Trip trip) async {
    await _prefs.setString(cacheKey, jsonEncode(trip.toJson()));
  }

  String _generateShareCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }
}
