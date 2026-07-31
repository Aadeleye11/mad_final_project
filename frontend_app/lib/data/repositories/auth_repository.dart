import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../models/user.dart';

class AuthRepository {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) return null;
    return User(
      uid: fbUser.uid,
      name: fbUser.displayName ?? '',
      email: fbUser.email ?? '',
      defaultInterests: const [],
    );
  }

  Future<User> login({required String email, required String password}) async {
    try {
      final cred = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc =
          await _firestore.collection('users').doc(cred.user!.uid).get();
      if (doc.exists) {
        return User.fromFirestore(doc);
      }

      return User(
        uid: cred.user!.uid,
        name: cred.user!.displayName ?? email.split('@').first,
        email: email,
        defaultInterests: const [],
      );
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Authentication failed.');
    }
  }

  Future<User> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final newUser = User(
        uid: cred.user!.uid,
        name: name,
        email: email,
        defaultInterests: const [],
      );

      await _firestore
          .collection('users')
          .doc(cred.user!.uid)
          .set(newUser.toMap());

      return newUser;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Registration failed.');
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}