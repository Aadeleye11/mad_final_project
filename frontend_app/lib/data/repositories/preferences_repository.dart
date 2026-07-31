import 'package:shared_preferences/shared_preferences.dart';

/// Local, offline-first storage for user preferences.
/// Keys are scoped per user email so multiple accounts on one
/// device each get their own first-time interest selection.
class PreferencesRepository {
  final SharedPreferences _prefs;

  PreferencesRepository(this._prefs);

  String _interestsKey(String email) => 'interests_$email';
  String _completedKey(String email) => 'interests_completed_$email';

  bool hasSelectedInterests(String email) {
    return _prefs.getBool(_completedKey(email)) ?? false;
  }

  List<String> getInterests(String email) {
    return _prefs.getStringList(_interestsKey(email)) ?? const [];
  }

  Future<void> saveInterests(String email, List<String> interests) async {
    await _prefs.setStringList(_interestsKey(email), interests);
    await _prefs.setBool(_completedKey(email), true);
  }
}
