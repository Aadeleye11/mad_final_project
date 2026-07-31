import 'package:go_router/go_router.dart';

import 'presentation/pages/attraction_detail_page.dart';
import 'presentation/pages/discover_page.dart';

/// Discover routes. The shared router spreads this list.
final List<RouteBase> discoverRoutes = <RouteBase>[
  GoRoute(path: '/discover', builder: (context, state) => const DiscoverPage()),
  GoRoute(
    path: '/attraction/:poiId',
    builder: (context, state) =>
        AttractionDetailPage(attractionId: state.pathParameters['poiId']!),
  ),
];
