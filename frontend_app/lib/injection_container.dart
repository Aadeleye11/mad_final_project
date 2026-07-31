import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/discover/discover_injection.dart';

final sl = GetIt.instance;

/// Shared registrations only; put feature deps in `<feature>_injection.dart`.
Future<void> init() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  initDiscover(sl);
  // initTrips(sl);
  // initAuth(sl);
}
