import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/discover/discover_injection.dart';

final sl = GetIt.instance;

/// Shared registrations plus one call per feature.
///
/// Do not register feature dependencies here — put them in your own
/// `<feature>_injection.dart` so this file never causes merge conflicts.
Future<void> init() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  initDiscover(sl);
  // initTrips(sl);
  // initAuth(sl);
}
