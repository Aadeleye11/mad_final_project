import 'package:go_router/go_router.dart';

import '../../features/discover/discover_routes.dart';

/// Spreads each feature's own route list. Add one line per feature; never add
/// individual routes here.
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/discover',
    routes: [
      ...discoverRoutes,
      // ...tripsRoutes,
      // ...authRoutes,
    ],
  );
}
