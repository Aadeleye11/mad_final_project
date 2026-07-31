import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

/// Keyed per user email, same pattern as PreferencesRepository, so multiple
/// accounts on one device each keep their own profile.
class ProfileRepository {
  final SharedPreferences _prefs;

  ProfileRepository(this._prefs);

  String _key(String email) => 'profile_$email';

  UserProfile getProfile(String email) {
    final raw = _prefs.getString(_key(email));
    if (raw == null) return const UserProfile();
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveProfile(String email, UserProfile profile) async {
    await _prefs.setString(_key(email), jsonEncode(profile.toJson()));
  }
}
